import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qeyafa/features/measurement/controllers/measurement_flow_controller.dart';
import 'package:qeyafa/core/models/pose_landmark.dart';

void main() {
  // Initialize Flutter bindings for TTS
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MeasurementFlowController Tests', () {
    late MeasurementFlowController controller;

    setUp(() {
      controller = MeasurementFlowController(isArabic: true);
    });

    test('Initial state should be front step', () {
      expect(controller.currentStep, MeasurementStep.front);
      expect(controller.completedSteps, 0);
      expect(controller.totalSteps, 4);
      expect(controller.progress, 0.0);
      expect(controller.isSessionComplete, false);
    });

    test('Step names should be in Arabic', () {
      final controllerAr = MeasurementFlowController(isArabic: true);
      expect(controllerAr.getStepName(MeasurementStep.front), 'أمامي');
      expect(controllerAr.getStepName(MeasurementStep.sideRight), 'جانب أيمن');
      expect(controllerAr.getStepName(MeasurementStep.back), 'خلفي');
      expect(controllerAr.getStepName(MeasurementStep.sideLeft), 'جانب أيسر');
    });

    test('Step names should be in English', () {
      final controllerEn = MeasurementFlowController(isArabic: false);
      expect(controllerEn.getStepName(MeasurementStep.front), 'Front');
      expect(controllerEn.getStepName(MeasurementStep.sideRight), 'Right Side');
      expect(controllerEn.getStepName(MeasurementStep.back), 'Back');
      expect(controllerEn.getStepName(MeasurementStep.sideLeft), 'Left Side');
    });

    test('Progress should update correctly after each step', () async {
      // Create mock landmarks with good quality
      final mockLandmarks = _createMockLandmarks();

      await controller.startSession(userHeightCm: 170.0);
      expect(controller.progress, 0.0);

      // Capture step 1
      await controller.captureStep(mockLandmarks);
      expect(controller.completedSteps, 1);
      expect(controller.progress, 0.25);

      // Capture step 2
      await controller.captureStep(mockLandmarks);
      expect(controller.completedSteps, 2);
      expect(controller.progress, 0.5);

      // Capture step 3
      await controller.captureStep(mockLandmarks);
      expect(controller.completedSteps, 3);
      expect(controller.progress, 0.75);

      // Capture step 4
      await controller.captureStep(mockLandmarks);
      expect(controller.completedSteps, 4);
      expect(controller.progress, 1.0);
      expect(controller.isSessionComplete, true);
    });

    test('Should reject poor quality landmarks', () async {
      // Create landmarks with low visibility
      final poorLandmarks = List.generate(
        33,
        (i) => PoseLandmark(
          x: 0.5,
          y: 0.5,
          z: 0.0,
          visibility: 0.3, // Low visibility
        ),
      );

      await controller.startSession(userHeightCm: 170.0);
      final result = await controller.captureStep(poorLandmarks);
      
      expect(result, false);
      expect(controller.completedSteps, 0);
    });

    test('Calculate final measurements after all steps', () async {
      final mockLandmarks = _createMockLandmarks();

      await controller.startSession(userHeightCm: 170.0);
      
      // Complete all 4 steps
      for (int i = 0; i < 4; i++) {
        await controller.captureStep(mockLandmarks);
      }

      expect(controller.isSessionComplete, true);

      final result = await controller.calculateFinalMeasurements();
      expect(result, isNotNull);
      expect(result!.totalHeight, closeTo(170.0, 5.0));
    });
  });
}

/// Create mock landmarks for testing
List<PoseLandmark> _createMockLandmarks() {
  return [
    // 0: Nose
    PoseLandmark(x: 0.5, y: 0.15, z: 0.0, visibility: 0.98),
    // 1-10: Face landmarks
    ...List.generate(
      10,
      (i) => PoseLandmark(x: 0.5, y: 0.15, z: 0.0, visibility: 0.9),
    ),
    // 11: Left Shoulder
    PoseLandmark(x: 0.40, y: 0.30, z: 0.0, visibility: 0.95),
    // 12: Right Shoulder
    PoseLandmark(x: 0.60, y: 0.30, z: 0.0, visibility: 0.95),
    // 13-22: Arms and hands
    ...List.generate(
      10,
      (i) => PoseLandmark(x: 0.5, y: 0.5, z: 0.0, visibility: 0.9),
    ),
    // 23: Left Hip
    PoseLandmark(x: 0.42, y: 0.62, z: 0.0, visibility: 0.94),
    // 24: Right Hip
    PoseLandmark(x: 0.58, y: 0.62, z: 0.0, visibility: 0.94),
    // 25-28: Legs
    ...List.generate(
      4,
      (i) => PoseLandmark(x: 0.5, y: 0.8, z: 0.0, visibility: 0.9),
    ),
    // 29: Left Heel
    PoseLandmark(x: 0.44, y: 0.98, z: -0.02, visibility: 0.82),
    // 30: Right Heel
    PoseLandmark(x: 0.56, y: 0.98, z: -0.02, visibility: 0.82),
    // 31-32: Feet
    ...List.generate(
      2,
      (i) => PoseLandmark(x: 0.5, y: 0.99, z: 0.05, visibility: 0.75),
    ),
  ];
}
