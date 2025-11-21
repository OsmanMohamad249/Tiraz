import 'dart:async';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import '../models/pose_landmark.dart';

/// Singleton service that bridges Flutter to Native MediaPipe implementation.
///
/// This service communicates with Android (Kotlin) and iOS (Swift) native code
/// through Platform Channels to perform real-time pose detection using MediaPipe.
class VisionService {
  VisionService._();
  static final VisionService instance = VisionService._();

  // Platform Channels
  static const MethodChannel _methodChannel = MethodChannel('com.qeyafa.app/vision');
  static const EventChannel _eventChannel = EventChannel('com.qeyafa.app/vision_stream');

  Stream<List<PoseLandmark>>? _poseStream;
  bool _isInitialized = false;
  bool _isProcessing = false;
  int _frameCount = 0;
  int _processedFrameCount = 0;

  /// Initializes the native MediaPipe Pose Landmarker.
  ///
  /// Must be called before using [poseStream].
  /// Throws [PlatformException] if initialization fails.
  Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ VisionService already initialized');
      return;
    }

    try {
      print('🚀 Initializing native MediaPipe...');
      await _methodChannel.invokeMethod('init');
      _isInitialized = true;
      print('✅ MediaPipe initialized successfully');
    } on PlatformException catch (e) {
      print('❌ Failed to initialize MediaPipe: ${e.message}');
      print('   Code: ${e.code}, Details: ${e.details}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error during initialization: $e');
      rethrow;
    }
  }

  /// Stream of pose detection results.
  ///
  /// Each emission contains a list of 33 [PoseLandmark] objects representing
  /// the full body pose in 3D space.
  ///
  /// Call [initialize] before accessing this stream.
  Stream<List<PoseLandmark>> get poseStream {
    if (!_isInitialized) {
      throw StateError('VisionService must be initialized before accessing poseStream');
    }

    _poseStream ??= _eventChannel.receiveBroadcastStream().map((event) {
      try {
        if (event == null) {
          print('⚠️ Received null event from native');
          return <PoseLandmark>[];
        }

        // Event should be a List of Maps
        final List<dynamic> landmarkMaps = event as List<dynamic>;
        
        final landmarks = landmarkMaps
            .map((map) => PoseLandmark.fromMap(map as Map<dynamic, dynamic>))
            .toList();

        print('📍 Received ${landmarks.length} landmarks');
        return landmarks;
      } catch (e) {
        print('❌ Error parsing pose data: $e');
        return <PoseLandmark>[];
      }
    });

    return _poseStream!;
  }

  /// Stops the pose detection stream and releases native resources.
  Future<void> dispose() async {
    try {
      await _methodChannel.invokeMethod('dispose');
      _isInitialized = false;
      _poseStream = null;
      _isProcessing = false;
      _frameCount = 0;
      _processedFrameCount = 0;
      print('🛑 VisionService disposed');
    } on PlatformException catch (e) {
      print('⚠️ Error disposing VisionService: ${e.message}');
    }
  }

  /// Process a camera frame for pose detection.
  ///
  /// Optimized for high-performance with frame throttling to prevent UI jank.
  /// Converts CameraImage to byte array efficiently and sends to native code.
  ///
  /// **Performance optimizations:**
  /// - Skip frames if previous frame is still processing (prevents backlog)
  /// - Process every 2nd frame to maintain ~15 FPS (adjustable)
  /// - Send raw YUV planes directly to native (fast in Dart, conversion on native GPU)
  ///
  /// **Usage:**
  /// ```dart
  /// cameraController.startImageStream((CameraImage image) {
  ///   VisionService.instance.processFrameFromCamera(image);
  /// });
  /// ```
  Future<void> processFrameFromCamera(
    CameraImage image, {
    int rotation = 0,
    int frameSkip = 2, // Process every Nth frame (2 = 15fps, 1 = 30fps)
  }) async {
    if (!_isInitialized) {
      print('⚠️ VisionService not initialized. Call initialize() first.');
      return;
    }

    // Frame throttling: Skip frames if still processing previous one
    if (_isProcessing) {
      return;
    }

    // FPS limiter: Process every Nth frame
    _frameCount++;
    if (_frameCount % frameSkip != 0) {
      return;
    }

    _isProcessing = true;

    try {
      // Convert CameraImage to byte array efficiently
      // For Android YUV_420_888 format, concatenate all planes
      final Uint8List bytes = _concatenatePlanes(image.planes);

      // Send frame to native code for processing
      await _methodChannel.invokeMethod('processFrame', {
        'imageData': bytes,
        'width': image.width,
        'height': image.height,
        'rotation': rotation,
      });

      _processedFrameCount++;

      // Log performance metrics every 30 frames
      if (_processedFrameCount % 30 == 0) {
        final fps = (_processedFrameCount / _frameCount * 30).toStringAsFixed(1);
        print('📊 Processed $_processedFrameCount frames (Effective FPS: ~$fps)');
      }
    } on PlatformException catch (e) {
      print('❌ Failed to process frame: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error processing frame: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Efficiently concatenate all YUV420 planes into a single byte array.
  ///
  /// **Android YUV_420_888 format:**
  /// - Plane 0: Y (luminance) - width × height bytes
  /// - Plane 1: U (chroma) - (width × height) / 4 bytes
  /// - Plane 2: V (chroma) - (width × height) / 4 bytes
  ///
  /// Total size ≈ 1.5 × width × height
  ///
  /// The native code (PoseDetectorHelper.kt) will decode this back to Bitmap.
  Uint8List _concatenatePlanes(List<Plane> planes) {
    // Calculate total buffer size
    int totalSize = 0;
    for (final plane in planes) {
      totalSize += plane.bytes.length;
    }

    // Allocate buffer and concatenate all planes
    final Uint8List allBytes = Uint8List(totalSize);
    int offset = 0;

    for (final plane in planes) {
      allBytes.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }

    return allBytes;
  }

  /// Checks if the service is initialized.
  bool get isInitialized => _isInitialized;

  /// Checks if a frame is currently being processed.
  bool get isProcessing => _isProcessing;

  /// Get total number of frames received from camera.
  int get totalFrames => _frameCount;

  /// Get number of frames actually processed (after throttling).
  int get processedFrames => _processedFrameCount;

  /// Get current effective frames per second.
  double get effectiveFps {
    if (_frameCount == 0) return 0.0;
    return (_processedFrameCount / _frameCount) * 30.0;
  }

  /// Reset frame counters (useful for performance monitoring).
  void resetCounters() {
    _frameCount = 0;
    _processedFrameCount = 0;
  }
}
