// Example: Using Android Native MediaPipe with Flutter Camera
// This file demonstrates how to integrate the native Android implementation
// with Flutter's camera plugin to perform real-time pose detection.

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:qeyafa/core/services/vision_service.dart';
import 'package:qeyafa/core/models/pose_landmark.dart';

class NativePoseDetectionExample extends StatefulWidget {
  const NativePoseDetectionExample({Key? key}) : super(key: key);

  @override
  State<NativePoseDetectionExample> createState() =>
      _NativePoseDetectionExampleState();
}

class _NativePoseDetectionExampleState
    extends State<NativePoseDetectionExample> {
  CameraController? _cameraController;
  List<PoseLandmark> _currentPose = [];
  bool _isProcessing = false;
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // 1. Get available cameras
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // 2. Initialize camera controller
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Balance between quality and performance
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // 3. Initialize MediaPipe native code
      await VisionService.instance.initialize();

      // 4. Start listening to pose stream
      VisionService.instance.poseStream.listen(
        (landmarks) {
          setState(() {
            _currentPose = landmarks;
            _statusMessage = landmarks.isEmpty
                ? 'No pose detected'
                : '${landmarks.length} landmarks detected';
          });
        },
        onError: (error) {
          setState(() {
            _statusMessage = 'Error: $error';
          });
        },
      );

      // 5. Start camera stream (NOTE: This requires additional implementation)
      // See implementation note below
      // _startCameraStream();

      setState(() {
        _statusMessage = 'Ready';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Initialization failed: $e';
      });
      print('❌ Failed to initialize: $e');
    }
  }

  // NOTE: Camera frame processing requires additional implementation.
  // The native code is ready via the 'processFrame' method, but you need to:
  // 1. Capture camera frames as byte arrays
  // 2. Call MethodChannel.invokeMethod('processFrame', {imageData, width, height})
  // 3. Receive results via EventChannel (already set up)
  //
  // Example (pseudo-code):
  /*
  void _startCameraStream() async {
    _cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessing) return;
      _isProcessing = true;

      try {
        // Convert CameraImage to JPEG bytes (requires image conversion)
        final bytes = await _convertCameraImageToJPEG(image);
        
        // Call native processFrame method
        await MethodChannel('com.qeyafa.app/vision').invokeMethod(
          'processFrame',
          {
            'imageData': bytes,
            'width': image.width,
            'height': image.height,
            'rotation': 0,
          },
        );
      } catch (e) {
        print('Frame processing error: $e');
      } finally {
        _isProcessing = false;
      }
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Pose Detection'),
      ),
      body: Column(
        children: [
          // Camera preview
          Expanded(
            child: _cameraController?.value.isInitialized ?? false
                ? CameraPreview(_cameraController!)
                : const Center(child: CircularProgressIndicator()),
          ),

          // Status bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $_statusMessage',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Landmarks: ${_currentPose.length}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),

          // Landmark visualization (optional)
          if (_currentPose.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _currentPose.length,
                itemBuilder: (context, index) {
                  final landmark = _currentPose[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      'Landmark $index',
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      'x: ${landmark.x.toStringAsFixed(3)}, '
                      'y: ${landmark.y.toStringAsFixed(3)}, '
                      'z: ${landmark.z.toStringAsFixed(3)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: Text(
                      '${(landmark.visibility * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: landmark.visibility > 0.5
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    VisionService.instance.dispose();
    super.dispose();
  }
}

// IMPLEMENTATION NOTES:
// ======================
//
// 1. CURRENT STATE:
//    ✅ Native Android code ready (PoseDetectorHelper + MainActivity)
//    ✅ Platform Channels configured (MethodChannel + EventChannel)
//    ✅ VisionService ready to receive pose landmarks
//    ⚠️ Camera frame processing needs implementation
//
// 2. MISSING PIECE - Camera Frame Processing:
//    The native 'processFrame' method is implemented but not called yet.
//    You need to:
//    a) Capture camera frames using CameraController.startImageStream()
//    b) Convert CameraImage to JPEG/PNG bytes
//    c) Call MethodChannel.invokeMethod('processFrame', {imageData, ...})
//    d) Results automatically arrive via EventChannel (VisionService.poseStream)
//
// 3. ALTERNATIVE APPROACH - Native Camera Handling:
//    For better performance, consider implementing camera capture natively:
//    - Android: Use CameraX directly in PoseDetectorHelper
//    - This avoids slow Flutter ↔ Native byte array transfers
//    - Requires more native code but achieves 30+ FPS
//
// 4. IMAGE CONVERSION HELPER:
//    You'll need a package like `image` to convert CameraImage to bytes:
//    
//    import 'package:image/image.dart' as img;
//    
//    Future<Uint8List> _convertCameraImageToJPEG(CameraImage image) async {
//      // Convert YUV420 (Android) to RGB
//      final imgLib = img.Image.fromBytes(
//        image.width,
//        image.height,
//        image.planes[0].bytes,
//      );
//      
//      // Encode as JPEG
//      return Uint8List.fromList(img.encodeJpg(imgLib));
//    }
//
// 5. PERFORMANCE TIPS:
//    - Use ResolutionPreset.medium (not high) for 30 FPS
//    - Skip frames if already processing (_isProcessing flag)
//    - Consider downscaling images before sending to native
//    - Monitor memory usage (bitmap allocation on native side)
//
// 6. NEXT STEPS:
//    a) Implement camera frame capture
//    b) Add image conversion utility
//    c) Call native processFrame method
//    d) Test on physical device
//    e) Optimize frame rate and quality
//    f) Add UI overlay to draw skeleton on camera preview
