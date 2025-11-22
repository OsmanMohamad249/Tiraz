import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../core/services/vision_service.dart';
import '../../../core/models/pose_landmark.dart';
import '../painters/silhouette_painter.dart';
import '../logic/body_calculator.dart';
import 'measurement_result_screen.dart';

/// Smart Camera Screen with AR Overlay for body measurement.
///
/// Features:
/// - Real-time camera preview
/// - Orientation detection (phone must be vertical)
/// - AR silhouette guide overlay
/// - Live pose landmark streaming from MediaPipe
class SmartCameraScreen extends StatefulWidget {
  const SmartCameraScreen({super.key});

  @override
  State<SmartCameraScreen> createState() => _SmartCameraScreenState();
}

class _SmartCameraScreenState extends State<SmartCameraScreen> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  bool _isPhoneVertical = true;
  List<PoseLandmark> _currentLandmarks = [];
  bool _isArabic = true; // Language preference (true = Arabic, false = English)
  
  // Auto-capture system
  int _matchedFramesCount = 0;
  int _requiredMatchedFrames = 30; // 2 seconds at 15 FPS
  bool _captureInProgress = false;
  int _countdownSeconds = 0;
  Timer? _countdownTimer;
  
  // Measurement system
  final TextEditingController _heightController = TextEditingController(text: '170');
  
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<List<PoseLandmark>>? _poseSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeVisionService();
    _startOrientationDetection();
  }

  /// Initialize camera with high resolution
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('❌ No cameras available');
        return;
      }

      // Use back camera for measurement
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium, // Balanced for performance (was 'high')
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // Required for native processing
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {});
        print('✅ Camera initialized: ${camera.name}');
        
        // Start streaming camera frames to VisionService
        _startCameraStream();
      }
    } catch (e) {
      print('❌ Camera initialization failed: $e');
    }
  }

  /// Initialize VisionService for MediaPipe pose detection
  Future<void> _initializeVisionService() async {
    try {
      await VisionService.instance.initialize();
      
      // Subscribe to pose landmark stream
      _poseSubscription = VisionService.instance.poseStream.listen(
        (landmarks) {
          if (mounted && !_isProcessing) {
            setState(() {
              _currentLandmarks = landmarks;
            });
            
            // Check for auto-capture
            _checkForAutoCapture(landmarks);
          }
        },
        onError: (error) {
          print('❌ Pose stream error: $error');
        },
      );
      
      print('✅ VisionService initialized and streaming');
    } catch (e) {
      print('❌ VisionService initialization failed: $e');
    }
  }

  /// Start camera stream and feed frames to VisionService
  void _startCameraStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print('⚠️ Cannot start camera stream - controller not ready');
      return;
    }

    try {
      _cameraController!.startImageStream((CameraImage image) {
        // Feed camera frames to VisionService for real-time pose detection
        // VisionService handles frame throttling and native processing
        VisionService.instance.processFrameFromCamera(
          image,
          rotation: 0, // Adjust based on camera orientation if needed
          frameSkip: 2, // Process every 2nd frame (~15 FPS) for balanced performance
        );
      });
      
      print('✅ Camera stream started - feeding frames to VisionService');
    } catch (e) {
      print('❌ Failed to start camera stream: $e');
    }
  }

  /// Monitor phone orientation using accelerometer
  void _startOrientationDetection() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        // Y-axis gravity when phone is vertical (portrait): ~9.8 m/s²
        // Allow ±2.0 tolerance for slight tilts
        final isVertical = event.y > 7.8 && event.y < 11.8;
        
        if (_isPhoneVertical != isVertical) {
          setState(() {
            _isPhoneVertical = isVertical;
          });
        }
      },
    );
  }

  /// Check if pose is stable and matches guide for auto-capture
  void _checkForAutoCapture(List<PoseLandmark> landmarks) {
    if (_captureInProgress) return;
    
    // Check if pose matches guide (25+ landmarks visible with >70% confidence)
    final poseMatches = landmarks.length == 33 &&
        landmarks.where((l) => l.visibility > 0.7).length >= 25;
    
    if (poseMatches && _isPhoneVertical) {
      _matchedFramesCount++;
      
      // Start countdown when half-way to required frames
      if (_matchedFramesCount == _requiredMatchedFrames ~/ 2) {
        _startCountdown();
      }
      
      // Trigger capture when requirement met
      if (_matchedFramesCount >= _requiredMatchedFrames) {
        _triggerAutoCapture();
      }
    } else {
      // Reset if pose doesn't match
      _matchedFramesCount = 0;
      _cancelCountdown();
    }
  }
  
  /// Start countdown animation
  void _startCountdown() {
    if (_countdownTimer != null) return;
    
    setState(() {
      _countdownSeconds = 3;
    });
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _countdownSeconds--;
      });
      
      if (_countdownSeconds <= 0) {
        timer.cancel();
        _countdownTimer = null;
      }
    });
  }
  
  /// Cancel countdown
  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    
    if (_countdownSeconds > 0) {
      setState(() {
        _countdownSeconds = 0;
      });
    }
  }
  
  /// Trigger automatic photo capture
  Future<void> _triggerAutoCapture() async {
    if (_captureInProgress) return;
    
    setState(() {
      _captureInProgress = true;
      _matchedFramesCount = 0;
    });
    
    _cancelCountdown();
    
    try {
      // Stop image stream temporarily
      await _cameraController?.stopImageStream();
      
      // Take the photo
      final XFile photo = await _cameraController!.takePicture();
      
      print('📸 Auto-captured photo: ${photo.path}');
      
      // Process measurements using current landmarks
      if (_currentLandmarks.isNotEmpty && mounted) {
        final userHeight = double.tryParse(_heightController.text);
        
        if (userHeight != null && userHeight > 100 && userHeight < 250) {
          final measurement = BodyCalculator.calculateMeasurements(
            landmarks: _currentLandmarks,
            userManualHeightCm: userHeight,
          );
          
          if (measurement != null && mounted) {
            // Navigate to result screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MeasurementResultScreen(result: measurement),
              ),
            );
          } else {
            _showErrorSnackbar(_isArabic 
              ? '❌ فشل حساب القياسات - تأكد من وضوح الصورة' 
              : '❌ Failed to calculate measurements');
          }
        } else {
          _showErrorSnackbar(_isArabic 
            ? '⚠️ الرجاء إدخال طول صحيح (100-250 سم)' 
            : '⚠️ Please enter valid height (100-250 cm)');
        }
      }
      
      if (mounted) {
        // Wait a bit before restarting stream
        await Future.delayed(const Duration(seconds: 1));
      }
      
      // Restart image stream
      if (mounted && _cameraController != null) {
        _startCameraStream();
      }
    } catch (e) {
      print('❌ Auto-capture failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isArabic ? '❌ فشل التقاط الصورة' : '❌ Failed to capture photo',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _captureInProgress = false;
        });
      }
    }
  }
  
  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    // Cancel timers
    _countdownTimer?.cancel();
    
    // Dispose text controller
    _heightController.dispose();
    
    // Stop camera stream before disposing
    try {
      _cameraController?.stopImageStream();
      print('🛑 Camera stream stopped');
    } catch (e) {
      print('⚠️ Error stopping camera stream: $e');
    }
    
    _accelerometerSubscription?.cancel();
    _poseSubscription?.cancel();
    _cameraController?.dispose();
    VisionService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background: Camera Preview
          _buildCameraPreview(),
          
          // Middle: AR Silhouette Guide Overlay
          _buildAROverlay(),
          
          // Countdown overlay (when auto-capture is imminent)
          if (_countdownSeconds > 0) _buildCountdownOverlay(),
          
          // Capture progress indicator
          if (_captureInProgress) _buildCaptureProgressOverlay(),
          
          // Foreground: Debug Info & Status
          _buildDebugInfo(),
          
          // Top: Instructions
          _buildInstructions(),
          
          // Height input field (top-right)
          _buildHeightInput(),
        ],
      ),
    );
  }

  /// Camera preview layer
  Widget _buildCameraPreview() {
    return CameraPreview(_cameraController!);
  }

  /// AR overlay with silhouette guide
  Widget _buildAROverlay() {
    return CustomPaint(
      painter: SilhouettePainter(
        isPhoneVertical: _isPhoneVertical,
        landmarks: _currentLandmarks,
      ),
    );
  }

  /// Debug information overlay
  Widget _buildDebugInfo() {
    // Get nose landmark (index 0) for reference Z-depth
    final noseZDepth = _currentLandmarks.isNotEmpty && _currentLandmarks.isNotEmpty
        ? _currentLandmarks[0].z
        : 0.0;

    // Check if pose matches guide (all landmarks visible with good confidence)
    final poseMatches = _currentLandmarks.length == 33 &&
        _currentLandmarks.where((l) => l.visibility > 0.7).length >= 25;

    // Calculate progress towards auto-capture
    final captureProgress = _matchedFramesCount / _requiredMatchedFrames;

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusChip(
                  'Status',
                  poseMatches ? 'Match' : (_currentLandmarks.isNotEmpty ? 'Partial' : 'Waiting'),
                  poseMatches ? Colors.green : (_currentLandmarks.isNotEmpty ? Colors.orange : Colors.grey),
                ),
                _buildStatusChip(
                  'Nose Z',
                  noseZDepth.toStringAsFixed(3),
                  noseZDepth.abs() < 0.5 ? Colors.green : Colors.blue,
                ),
                _buildStatusChip(
                  'Landmarks',
                  '${_currentLandmarks.length}/33',
                  _currentLandmarks.length == 33 ? Colors.green : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Performance stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.speed,
                  color: Colors.white60,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'FPS: ${VisionService.instance.effectiveFps.toStringAsFixed(1)} | '
                  'Processed: ${VisionService.instance.processedFrames}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            // Auto-capture progress bar
            if (poseMatches && !_captureInProgress) ...[
              const SizedBox(height: 8),
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isArabic ? 'التقاط تلقائي...' : 'Auto-capture...',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(captureProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: captureProgress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 6,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Status chip widget
  Widget _buildStatusChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: 1),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Instructions overlay
  Widget _buildInstructions() {
    final instructionText = _isPhoneVertical
        ? (_isArabic 
            ? 'جيد! استمر في الوقوف بشكل مستقيم'
            : 'Good! Keep standing straight')
        : (_isArabic
            ? 'الرجاء حمل الهاتف بشكل عمودي'
            : 'Please hold the phone vertically');
    
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: _isPhoneVertical 
              ? Colors.green.withValues(alpha: 0.8) 
              : Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _isPhoneVertical ? Icons.check_circle : Icons.warning,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    instructionText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!_isPhoneVertical) ...[
                    const SizedBox(height: 4),
                    Text(
                      _isArabic
                          ? 'Hold the phone vertically'
                          : 'الرجاء حمل الهاتف بشكل عمودي',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            // Language toggle button
            IconButton(
              icon: Icon(
                _isArabic ? Icons.translate : Icons.language,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isArabic = !_isArabic;
                });
              },
              tooltip: _isArabic ? 'Switch to English' : 'التبديل للعربية',
            ),
          ],
        ),
      ),
    );
  }

  /// Countdown overlay (3, 2, 1...)
  Widget _buildCountdownOverlay() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$_countdownSeconds',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Capture in progress overlay
  Widget _buildCaptureProgressOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.green,
              strokeWidth: 6,
            ),
            const SizedBox(height: 24),
            Text(
              _isArabic ? 'جاري التقاط الصورة...' : 'Capturing photo...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Height input field
  Widget _buildHeightInput() {
    return Positioned(
      top: 140,
      right: 16,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.height, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  _isArabic ? 'الطول' : 'Height',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                suffixText: _isArabic ? 'سم' : 'cm',
                suffixStyle: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
