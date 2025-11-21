# Android Native MediaPipe Implementation

## Overview
This document describes the Android native implementation for MediaPipe Pose Detection in Qeyafa, bridging native Kotlin code with Flutter via Platform Channels.

## Architecture

### Components

1. **MainActivity.kt** (`com.qeyafa.mobile.MainActivity`)
   - Entry point for the Flutter app
   - Configures Platform Channels (MethodChannel + EventChannel)
   - Manages PoseDetectorHelper lifecycle
   - Bridges data between native and Flutter layers

2. **PoseDetectorHelper.kt** (`com.qeyafa.mobile.PoseDetectorHelper`)
   - Encapsulates MediaPipe Pose Landmarker logic
   - Runs in LIVE_STREAM mode for real-time processing
   - Handles frame processing with automatic throttling
   - Converts MediaPipe results to Flutter-compatible format

3. **MediaPipePlugin.kt** (Legacy - different channel names)
   - Existing plugin using `com.qeyafa/mediapipe` channels
   - Can coexist but not used by VisionService

## Platform Channels

### MethodChannel: `com.qeyafa.app/vision`
Commands from Flutter to Android:

- **`init`**: Initialize MediaPipe Pose Landmarker
  - Sets up GPU delegate for performance
  - Loads `models/pose_landmarker_heavy.task` from Flutter assets
  - Configures LIVE_STREAM mode with result callbacks
  - Returns: `true` on success, throws `PlatformException` on error

- **`dispose`**: Clean up MediaPipe resources
  - Closes PoseLandmarker
  - Shuts down executor thread pool
  - Clears event listeners
  - Returns: `true` on success

### EventChannel: `com.qeyafa.app/vision_stream`
Streams pose detection results from Android to Flutter:

- **Data Format**: `List<Map<String, Double>>`
  - Each map represents one landmark with keys:
    - `x`: Normalized X coordinate (0.0 - 1.0)
    - `y`: Normalized Y coordinate (0.0 - 1.0)
    - `z`: 3D depth relative to hips
    - `visibility`: Confidence score (0.0 - 1.0)
  
- **33 Landmarks** per frame (MediaPipe body model)
- Empty list `[]` when no pose detected

## Dependencies

### build.gradle
```gradle
dependencies {
    implementation 'com.google.mediapipe:tasks-vision:0.10.14'
}

android {
    defaultConfig {
        minSdkVersion 24  // Required for MediaPipe
    }
}
```

### AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
```

## MediaPipe Configuration

### Model
- **File**: `assets/models/pose_landmarker_heavy.task`
- **Type**: Heavy model (highest accuracy, slower)
- **Path in Android**: `models/pose_landmarker_heavy.task` (Flutter asset key)

### Detection Parameters
```kotlin
minPoseDetectionConfidence = 0.5f
minPosePresenceConfidence = 0.5f
minTrackingConfidence = 0.5f
numPoses = 1  // Single person tracking
delegate = Delegate.GPU  // Hardware acceleration
runningMode = RunningMode.LIVE_STREAM
```

## Data Flow

### Initialization Flow
```
Flutter (VisionService.initialize())
  ↓ MethodChannel.invokeMethod('init')
  ↓
Android (MainActivity.initializePoseDetector())
  ↓
PoseDetectorHelper.initialize()
  ↓ Creates PoseLandmarker with LIVE_STREAM mode
  ✓ Returns success to Flutter
```

### Detection Flow
```
Camera Frame (Flutter camera plugin)
  ↓ Byte Array
  ↓
PoseDetectorHelper.detectFromBytes()
  ↓ Decode to Bitmap
  ↓ Convert to MPImage
  ↓ PoseLandmarker.detectAsync()
  ↓
MediaPipe Result Callback
  ↓ Extract landmarks + world landmarks
  ↓ Convert to List<Map<String, Double>>
  ↓
MainActivity.sendLandmarksToFlutter()
  ↓ EventChannel.EventSink.success()
  ↓
Flutter (VisionService.poseStream)
  ↓ Parse to List<PoseLandmark>
  ✓ UI updates with pose data
```

## Threading Model

- **Main Thread**: 
  - Platform Channel communication
  - EventSink emissions (required by Flutter)
  
- **Background Thread**:
  - Frame decoding (BitmapFactory)
  - Image conversion (MPImage creation)
  - MediaPipe detection (async on internal thread)

- **Executor**: Single-threaded scheduled executor for frame throttling

## Error Handling

### Initialization Errors
- Model file not found → `INIT_ERROR` with stack trace
- Insufficient memory → `INIT_ERROR` with message
- Invalid configuration → `INIT_ERROR`

### Runtime Errors
- Frame processing errors → Logged, sent via EventChannel error
- MediaPipe internal errors → Propagated via error listener
- Timestamp conflicts → Silently dropped (prevents stale data)

## Performance Optimizations

1. **Frame Throttling**: Skip frames if still processing previous one
2. **GPU Acceleration**: Uses Delegate.GPU for hardware acceleration
3. **Async Processing**: Non-blocking detection with callbacks
4. **Bitmap Recycling**: Immediate cleanup after conversion to MPImage
5. **Monotonic Timestamps**: Prevents out-of-order results

## Testing Checklist

- [ ] `flutter pub get` succeeds
- [ ] Android build compiles without errors
- [ ] Camera permissions granted at runtime
- [ ] `VisionService.initialize()` completes successfully
- [ ] Pose landmarks stream updates continuously
- [ ] 33 landmarks received per detection
- [ ] `x, y, z, visibility` fields all present
- [ ] App gracefully handles no-pose scenarios (empty list)
- [ ] `VisionService.dispose()` cleans up resources
- [ ] No memory leaks after repeated init/dispose cycles

## Integration with Flutter

### Flutter Side (VisionService)
```dart
// Initialize
await VisionService.instance.initialize();

// Listen to pose stream
VisionService.instance.poseStream.listen((landmarks) {
  print('Received ${landmarks.length} landmarks');
  for (var landmark in landmarks) {
    print('x: ${landmark.x}, y: ${landmark.y}, z: ${landmark.z}');
  }
});

// Clean up
await VisionService.instance.dispose();
```

### Required Flutter Assets
Add to `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/models/
```

## Known Limitations

1. **Single Pose Only**: Currently configured for `numPoses = 1`
2. **Byte Array Transfer**: Slower than native camera handling (future optimization)
3. **No iOS Implementation Yet**: Only Android supported currently
4. **Heavy Model Only**: No runtime model switching

## Future Enhancements

- [ ] Add native camera handling (bypass Flutter camera plugin)
- [ ] Support multi-person tracking (numPoses > 1)
- [ ] Add model selection (lite/full/heavy)
- [ ] Implement iOS native code (Swift/Objective-C)
- [ ] Add confidence thresholds as runtime parameters
- [ ] Optimize byte array transfer (use texture/pixel buffer)
- [ ] Add frame rate monitoring and diagnostics

## Troubleshooting

### "Model not found" Error
- Verify `pose_landmarker_heavy.task` exists in `assets/models/`
- Check `pubspec.yaml` includes `assets/models/` in assets list
- Run `flutter clean && flutter pub get`

### "Failed to initialize MediaPipe"
- Check minSdkVersion is >= 24
- Verify device has sufficient memory
- Check Gradle dependency resolved correctly

### Empty Landmark Stream
- Verify camera permissions granted
- Check camera is actually capturing frames
- Enable debug logs to see frame processing
- Verify lighting conditions (poor lighting → no detection)

### Memory Leaks
- Always call `VisionService.dispose()` when done
- Don't create multiple VisionService instances
- Check PoseDetectorHelper.dispose() is called

## File Structure
```
android/app/src/main/kotlin/com/qeyafa/mobile/
├── MainActivity.kt              # Main entry point, Platform Channels setup
├── PoseDetectorHelper.kt        # MediaPipe wrapper, core detection logic
└── MediaPipePlugin.kt           # Legacy plugin (different channels)

android/app/build.gradle         # MediaPipe dependency, minSdkVersion
android/app/src/main/AndroidManifest.xml  # Camera permissions

assets/models/
└── pose_landmarker_heavy.task   # MediaPipe model file (90MB)
```

## References

- [MediaPipe Pose Landmarker](https://developers.google.com/mediapipe/solutions/vision/pose_landmarker)
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)
- [MediaPipe Tasks Vision API](https://developers.google.com/mediapipe/api/solutions/java/com/google/mediapipe/tasks/vision)

---

**Status**: ✅ Implementation Complete
**Last Updated**: November 21, 2025
**Implemented By**: Senior Android Engineer (AI Assistant)
