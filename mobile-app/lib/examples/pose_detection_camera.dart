import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:qeyafa/core/services/vision_service.dart';
import 'package:qeyafa/core/models/pose_landmark.dart';

/// Example: Real-time Pose Detection with Camera
///
/// This widget demonstrates the complete integration of:
/// - Flutter Camera
/// - VisionService (Dart)
/// - PoseDetectorHelper (Android Native)
/// - MediaPipe Pose Landmarker
class PoseDetectionCamera extends StatefulWidget {
  const PoseDetectionCamera({Key? key}) : super(key: key);

  @override
  State<PoseDetectionCamera> createState() => _PoseDetectionCameraState();
}

class _PoseDetectionCameraState extends State<PoseDetectionCamera> {
  CameraController? _cameraController;
  List<PoseLandmark> _currentPose = [];
  bool _isInitialized = false;
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeSystem();
  }

  /// Initialize camera and MediaPipe
  Future<void> _initializeSystem() async {
    try {
      // 1. Initialize MediaPipe native code
      setState(() => _statusMessage = 'Initializing MediaPipe...');
      await VisionService.instance.initialize();
      
      // 2. Start listening to pose stream
      VisionService.instance.poseStream.listen(
        (landmarks) {
          if (mounted) {
            setState(() {
              _currentPose = landmarks;
              _statusMessage = landmarks.isEmpty
                  ? 'No pose detected'
                  : '${landmarks.length} landmarks detected';
            });
          }
        },
        onError: (error) {
          setState(() => _statusMessage = 'Detection error: $error');
        },
      );

      // 3. Get available cameras
      setState(() => _statusMessage = 'Initializing camera...');
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // 4. Initialize camera controller
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium, // Balance between quality and performance
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // Required for Android
      );

      await _cameraController!.initialize();

      // 5. Start camera stream
      _cameraController!.startImageStream((CameraImage image) {
        // Send frame to native code for processing
        VisionService.instance.processFrameFromCamera(
          image,
          rotation: 0, // Adjust based on camera orientation
          frameSkip: 2, // Process every 2nd frame (~15 FPS)
        );
      });

      setState(() {
        _isInitialized = true;
        _statusMessage = 'Ready';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Initialization failed: $e');
      debugPrint('❌ Failed to initialize: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pose Detection'),
        backgroundColor: Colors.black87,
        actions: [
          // Performance stats
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'FPS: ${VisionService.instance.effectiveFps.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isInitialized && _cameraController != null
          ? _buildCameraView()
          : _buildLoadingView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.greenAccent),
          const SizedBox(height: 16),
          Text(
            _statusMessage,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),

        // Pose overlay (draw skeleton)
        if (_currentPose.isNotEmpty)
          Positioned.fill(
            child: CustomPaint(
              painter: PosePainter(_currentPose),
            ),
          ),

        // Status bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${VisionService.instance.processedFrames}/${VisionService.instance.totalFrames}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: _currentPose.isEmpty ? 0.0 : 1.0,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _currentPose.isEmpty ? Colors.red : Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    VisionService.instance.dispose();
    super.dispose();
  }
}

/// Custom painter to draw pose skeleton on camera preview
class PosePainter extends CustomPainter {
  final List<PoseLandmark> landmarks;

  PosePainter(this.landmarks);

  // MediaPipe pose landmark indices
  static const List<List<int>> connections = [
    // Face
    [0, 1], [1, 2], [2, 3], [3, 7],
    [0, 4], [4, 5], [5, 6], [6, 8],
    // Torso
    [9, 10], // Mouth
    [11, 12], // Shoulders
    [11, 13], [13, 15], // Left arm
    [12, 14], [14, 16], // Right arm
    [11, 23], [12, 24], // Shoulders to hips
    [23, 24], // Hips
    // Left leg
    [23, 25], [25, 27], [27, 29], [29, 31],
    // Right leg
    [24, 26], [26, 28], [28, 30], [30, 32],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty || landmarks.length != 33) return;

    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Draw connections
    for (final connection in connections) {
      if (connection[0] >= landmarks.length || connection[1] >= landmarks.length) {
        continue;
      }

      final start = landmarks[connection[0]];
      final end = landmarks[connection[1]];

      // Only draw if both landmarks are visible
      if (start.visibility > 0.5 && end.visibility > 0.5) {
        canvas.drawLine(
          Offset(start.x * size.width, start.y * size.height),
          Offset(end.x * size.width, end.y * size.height),
          paint,
        );
      }
    }

    // Draw landmark points
    for (final landmark in landmarks) {
      if (landmark.visibility > 0.5) {
        canvas.drawCircle(
          Offset(landmark.x * size.width, landmark.y * size.height),
          4,
          pointPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return landmarks != oldDelegate.landmarks;
  }
}
