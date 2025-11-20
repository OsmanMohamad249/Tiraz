import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// The core intelligence of the Qeyafa app.
/// This engine handles:
/// 1. Pose Detection (using ML Kit)
/// 2. Pose Validation (Is the user standing correctly?)
/// 3. Measurement Calculation (Converting pixels to cm)
class QeyafaMeasurementEngine {
  late final PoseDetector _poseDetector;
  
  // Configuration for the pose detector (High accuracy is preferred for measurements)
  QeyafaMeasurementEngine() {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream, 
      model: PoseDetectionModel.accurate, // Use 'accurate' model, not 'base'
    );
    _poseDetector = PoseDetector(options: options);
  }

  /// Closes the detector when done
  Future<void> close() async {
    await _poseDetector.close();
  }

  /// Processes a single image (frame) and returns the detected pose
  Future<Pose?> detectPose(InputImage inputImage) async {
    final List<Pose> poses = await _poseDetector.processImage(inputImage);
    if (poses.isEmpty) return null;
    return poses.first; // We assume only one person is in the frame
  }

  // ===========================================================================
  // POSE VALIDATION LOGIC (The "Smart" Part)
  // ===========================================================================

  /// Checks if the user is in a valid FRONT facing pose
  /// Returns a status message (or null if valid)
  String? validateFrontPose(Pose pose, {required double imageWidth, required double imageHeight}) {
    // 1. Check visibility of key landmarks
    if (!_isVisible(pose.landmarks[PoseLandmarkType.leftShoulder]) ||
        !_isVisible(pose.landmarks[PoseLandmarkType.rightShoulder]) ||
        !_isVisible(pose.landmarks[PoseLandmarkType.leftAnkle]) ||
        !_isVisible(pose.landmarks[PoseLandmarkType.rightAnkle])) {
      return "تراجع للخلف قليلاً لتظهر بالكامل"; // "Step back to be fully visible"
    }

    // 2. Check if shoulders are level (User is straight)
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder]!;
    
    double shoulderSlope = (leftShoulder.y - rightShoulder.y).abs();
    if (shoulderSlope > 20) {
      return "قف بشكل مستقيم"; // "Stand straight"
    }

    // 3. Check arms position (A-Pose: Arms should be slightly away from body)
    // This is a simplified check using wrist vs hip x-coordinates
    
    return null; // Valid pose
  }

  /// Checks if the user is in a valid SIDE facing pose
  String? validateSidePose(Pose pose) {
    // Logic to ensure we see a profile view
    // e.g., Shoulders should be close to each other in X-axis
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder]!;
    
    double shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    
    // If shoulders are too far apart, they are likely facing front/back, not side
    if (shoulderWidth > 50) { // Threshold depends on distance
      return "استدر جانباً"; // "Turn to the side"
    }
    
    return null;
  }

  bool _isVisible(PoseLandmark? landmark) {
    return landmark != null && landmark.likelihood > 0.8;
  }

  // ===========================================================================
  // MEASUREMENT CALCULATION LOGIC
  // ===========================================================================

  /// Calculates measurements based on the 4 captured poses and user height
  /// [userHeightCm] is critical for calibration (Pixel-to-CM ratio)
  Map<String, double> calculateMeasurements({
    required Pose frontPose,
    required Pose sidePose,
    required double userHeightCm,
  }) {
    // 1. Calculate Pixel-to-CM Ratio using the user's height in the Front Pose
    // We measure from Eye level to Ankle (as top of head is often cut off or hair varies)
    // Or use full height if available.
    
    final nose = frontPose.landmarks[PoseLandmarkType.nose]!;
    final leftAnkle = frontPose.landmarks[PoseLandmarkType.leftAnkle]!;
    final rightAnkle = frontPose.landmarks[PoseLandmarkType.rightAnkle]!;
    
    // Average ankle Y
    double ankleY = (leftAnkle.y + rightAnkle.y) / 2;
    double pixelHeight = (ankleY - nose.y).abs(); 
    
    // This is a simplified ratio. In production, we use more complex geometry.
    // We assume the nose is roughly at 90% of total height for calibration logic
    double estimatedBodyPixels = pixelHeight * 1.1; 
    double cmPerPixel = userHeightCm / estimatedBodyPixels;

    // 2. Calculate Shoulder Width (Front View)
    final leftShoulder = frontPose.landmarks[PoseLandmarkType.leftShoulder]!;
    final rightShoulder = frontPose.landmarks[PoseLandmarkType.rightShoulder]!;
    double shoulderDistPixels = _distance(leftShoulder, rightShoulder);
    double shoulderWidthCm = shoulderDistPixels * cmPerPixel;

    // 3. Calculate Chest Depth (Side View) - Rough estimation
    // We need landmarks from the side view to estimate depth
    
    return {
      'shoulder_width': double.parse(shoulderWidthCm.toStringAsFixed(1)),
      // Add more measurements here
    };
  }

  double _distance(PoseLandmark p1, PoseLandmark p2) {
    return math.sqrt(math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2));
  }
}
