import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../services/qeyafa_measurement_engine.dart';

enum MeasurementStep { front, rightSide, back, leftSide, finished }

class SmartCameraScreen extends StatefulWidget {
  const SmartCameraScreen({super.key});

  @override
  State<SmartCameraScreen> createState() => _SmartCameraScreenState();
}

class _SmartCameraScreenState extends State<SmartCameraScreen> {
  CameraController? _cameraController;
  late QeyafaMeasurementEngine _measurementEngine;
  late FlutterTts _flutterTts;
  
  MeasurementStep _currentStep = MeasurementStep.front;
  bool _isProcessing = false;
  bool _isDetecting = false;
  String _feedbackMessage = "جاري تهيئة الكاميرا...";
  
  // Stability check variables
  int _stableFrames = 0;
  static const int _requiredStableFrames = 30; // ~1-2 seconds of stability

  @override
  void initState() {
    super.initState();
    _initializeSystem();
  }

  Future<void> _initializeSystem() async {
    // 1. Initialize AI Engine
    _measurementEngine = QeyafaMeasurementEngine();

    // 2. Initialize TTS (Voice)
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("ar-SA"); // Arabic voice
    await _flutterTts.setSpeechRate(0.5); // Slower pace for clarity

    // 3. Initialize Camera
    final cameras = await availableCameras();
    // Prefer front camera for selfie mode, or back if someone else is taking photo
    // For auto-capture standing alone, front camera is usually used.
    final firstCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();
    if (!mounted) return;

    // Start Image Stream for AI processing
    await _cameraController!.startImageStream(_processCameraImage);
    
    setState(() {
      _feedbackMessage = "قف أمام الكاميرا لتظهر بالكامل";
    });
    _speak(_feedbackMessage);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _measurementEngine.close();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || _currentStep == MeasurementStep.finished) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) return;

      final pose = await _measurementEngine.detectPose(inputImage);
      
      if (pose != null) {
        _validateAndGuideUser(pose, image.width.toDouble(), image.height.toDouble());
      } else {
        // No person detected
        _updateFeedback("لا يوجد شخص أمام الكاميرا", resetStability: true);
      }
    } catch (e) {
      print("Error processing image: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _validateAndGuideUser(Pose pose, double width, double height) {
    String? validationError;

    // Check based on current step
    switch (_currentStep) {
      case MeasurementStep.front:
      case MeasurementStep.back:
        validationError = _measurementEngine.validateFrontPose(pose, imageWidth: width, imageHeight: height);
        break;
      case MeasurementStep.rightSide:
      case MeasurementStep.leftSide:
        validationError = _measurementEngine.validateSidePose(pose);
        break;
      default:
        break;
    }

    if (validationError != null) {
      // User is doing something wrong
      _updateFeedback(validationError, resetStability: true);
    } else {
      // Pose is valid! Count stability frames
      _stableFrames++;
      if (_stableFrames < _requiredStableFrames) {
        if (_stableFrames % 10 == 0) {
           _updateFeedback("ممتاز.. اثبت مكانك", speak: false);
        }
      } else {
        // Stable enough! Take photo
        _captureAndAdvance();
      }
    }
  }

  Future<void> _captureAndAdvance() async {
    // Stop processing temporarily
    _isProcessing = true; 
    _stableFrames = 0;
    
    // 1. Feedback
    await _speak("تم الالتقاط!");
    
    // 2. Capture logic would go here (save image/keypoints)
    // await _cameraController!.takePicture(); 

    // 3. Move to next step
    setState(() {
      switch (_currentStep) {
        case MeasurementStep.front:
          _currentStep = MeasurementStep.rightSide;
          _feedbackMessage = "الآن.. استدر لليمين";
          break;
        case MeasurementStep.rightSide:
          _currentStep = MeasurementStep.back;
          _feedbackMessage = "الآن.. أعطنا ظهرك";
          break;
        case MeasurementStep.back:
          _currentStep = MeasurementStep.leftSide;
          _feedbackMessage = "الآن.. استدر لليسار";
          break;
        case MeasurementStep.leftSide:
          _currentStep = MeasurementStep.finished;
          _feedbackMessage = "تم الانتهاء بنجاح! جاري حساب القياسات..";
          break;
        case MeasurementStep.finished:
          break;
      }
    });
    
    await _speak(_feedbackMessage);
    
    // Wait a bit before resuming to let user move
    await Future.delayed(const Duration(seconds: 3));
    _isProcessing = false;
  }

  void _updateFeedback(String message, {bool resetStability = false, bool speak = true}) {
    if (resetStability) _stableFrames = 0;
    
    // Only update/speak if message changed significantly to avoid spamming
    if (_feedbackMessage != message) {
      setState(() {
        _feedbackMessage = message;
      });
      if (speak) _speak(message);
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Helper to convert CameraImage to InputImage (Boilerplate for ML Kit)
  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    // This conversion logic is standard for ML Kit but verbose.
    // For brevity in this snippet, I'm simplifying. 
    // In production, we need full rotation/format handling.
    final allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    const InputImageRotation imageRotation = InputImageRotation.rotation270deg; // Adjust based on device
    const InputImageFormat inputImageFormat = InputImageFormat.nv21; // Android default

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Camera Feed
          SizedBox.expand(
            child: CameraPreview(_cameraController!),
          ),
          
          // 2. Overlay Guide (Silhouette)
          Center(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                _currentStep == MeasurementStep.rightSide || _currentStep == MeasurementStep.leftSide
                    ? 'assets/images/guide_side.png' // You'll need these assets
                    : 'assets/images/guide_front.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if images are missing
                  return const Icon(Icons.accessibility_new, size: 300, color: Colors.white24);
                },
              ),
            ),
          ),

          // 3. Status & Feedback UI
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _feedbackMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_currentStep != MeasurementStep.finished)
                    LinearProgressIndicator(
                      value: _stableFrames / _requiredStableFrames,
                      backgroundColor: Colors.grey,
                      color: Colors.greenAccent,
                    ),
                ],
              ),
            ),
          ),
          
          // 4. Close Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
