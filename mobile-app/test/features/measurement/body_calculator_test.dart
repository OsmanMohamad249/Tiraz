import 'package:flutter_test/flutter_test.dart';
import 'package:qeyafa/core/models/pose_landmark.dart';
import 'package:qeyafa/features/measurement/logic/body_calculator.dart';
import 'package:qeyafa/features/measurement/data/measurement_result.dart';

void main() {
  group('BodyCalculator Tests', () {
    // بيانات اختبار: شخص بطول 170 سم
    final mockLandmarks = _createMockLandmarks();

    test('Manual Height Calibration - Should calculate correct measurements', () {
      final result = BodyCalculator.calculateMeasurements(
        landmarks: mockLandmarks,
        userManualHeightCm: 170.0,
      );

      expect(result, isNotNull);
      expect(result!.totalHeight, closeTo(170.0, 5.0)); // ±5cm tolerance
      expect(result.shoulderWidth, greaterThan(30.0));
      expect(result.shoulderWidth, lessThan(60.0));
      expect(result.chestCircumference, greaterThan(70.0));
      expect(result.calibrationType, CalibrationType.manualHeight);
    });

    test('Reference Card Calibration - Should calculate correct measurements', () {
      // فرض: عرض البطاقة في الصورة = 100 بكسل
      // البطاقة الحقيقية = 8.56 سم
      // إذن النسبة = 8.56 / 100 = 0.0856 سم/بكسل
      final result = BodyCalculator.calculateMeasurements(
        landmarks: mockLandmarks,
        cardPixelWidth: 100.0,
      );

      expect(result, isNotNull);
      expect(result!.calibrationType, CalibrationType.referenceObject);
      expect(result.pixelToCmRatio, closeTo(0.0856, 0.001));
    });

    test('No Calibration - Should return null', () {
      final result = BodyCalculator.calculateMeasurements(
        landmarks: mockLandmarks,
      );

      expect(result, isNull);
    });

    test('Quality Check - Should validate landmark visibility', () {
      final isGood = BodyCalculator.isGoodQuality(mockLandmarks);
      expect(isGood, isTrue);

      // اختبار مع landmarks منخفضة الجودة
      final poorLandmarks = mockLandmarks.map((lm) {
        return PoseLandmark(
          x: lm.x,
          y: lm.y,
          z: lm.z,
          visibility: 0.3, // منخفضة جدًا
        );
      }).toList();

      final isPoor = BodyCalculator.isGoodQuality(poorLandmarks);
      expect(isPoor, isFalse);
    });

    test('MeasurementResult - JSON serialization', () {
      final result = MeasurementResult(
        totalHeight: 170.0,
        shoulderWidth: 45.0,
        chestCircumference: 95.0,
        waistCircumference: 80.0,
        hipCircumference: 100.0,
        armLength: 60.0,
        inseam: 80.0,
        pixelToCmRatio: 0.1,
        calibrationType: CalibrationType.manualHeight,
      );

      final json = result.toJson();
      final restored = MeasurementResult.fromJson(json);

      expect(restored.totalHeight, result.totalHeight);
      expect(restored.shoulderWidth, result.shoulderWidth);
      expect(restored.calibrationType, result.calibrationType);
    });
  });
}

/// إنشاء بيانات landmarks وهمية لشخص واقف
List<PoseLandmark> _createMockLandmarks() {
  // نموذج مبسط لشخص بطول نسبي = 1.0 في إحداثيات النموذج
  // سنضع القيم بحيث تعطي نتائج منطقية
  
  final landmarks = List<PoseLandmark>.filled(
    33,
    PoseLandmark(x: 0, y: 0, z: 0, visibility: 1.0),
  );

  // الرأس والوجه (0-10)
  landmarks[0] = PoseLandmark(x: 0.5, y: 0.1, z: 0.0, visibility: 0.95); // Nose
  landmarks[2] = PoseLandmark(x: 0.48, y: 0.08, z: 0.0, visibility: 0.95); // Left Eye
  landmarks[5] = PoseLandmark(x: 0.52, y: 0.08, z: 0.0, visibility: 0.95); // Right Eye

  // الكتفين (11-12)
  landmarks[11] = PoseLandmark(x: 0.4, y: 0.25, z: 0.0, visibility: 0.95); // Left Shoulder
  landmarks[12] = PoseLandmark(x: 0.6, y: 0.25, z: 0.0, visibility: 0.95); // Right Shoulder

  // الذراع الأيمن (14, 16)
  landmarks[14] = PoseLandmark(x: 0.65, y: 0.4, z: 0.0, visibility: 0.9); // Right Elbow
  landmarks[16] = PoseLandmark(x: 0.68, y: 0.55, z: 0.0, visibility: 0.9); // Right Wrist

  // الوركين (23-24)
  landmarks[23] = PoseLandmark(x: 0.45, y: 0.55, z: 0.0, visibility: 0.95); // Left Hip
  landmarks[24] = PoseLandmark(x: 0.55, y: 0.55, z: 0.0, visibility: 0.95); // Right Hip

  // الساق اليمنى (26, 28)
  landmarks[26] = PoseLandmark(x: 0.56, y: 0.75, z: 0.0, visibility: 0.9); // Right Knee
  landmarks[28] = PoseLandmark(x: 0.57, y: 0.92, z: 0.0, visibility: 0.9); // Right Ankle

  // الكعبين (29-30)
  landmarks[29] = PoseLandmark(x: 0.48, y: 0.98, z: 0.0, visibility: 0.85); // Left Heel
  landmarks[30] = PoseLandmark(x: 0.52, y: 0.98, z: 0.0, visibility: 0.85); // Right Heel

  return landmarks;
}
