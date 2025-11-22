import 'dart:math' as math;
import 'package:qeyafa/core/models/pose_landmark.dart';
import 'package:qeyafa/features/measurement/data/measurement_result.dart';

/// حاسبة قياسات الجسم من MediaPipe Pose Landmarks
/// 
/// تستخدم الرياضيات الدقيقة لحساب القياسات الحقيقية بالسنتيمتر
/// مع دعم وضعي معايرة:
/// 1. معايرة يدوية بإدخال الطول
/// 2. معايرة بجسم مرجعي (بطاقة 8.56 سم)
class BodyCalculator {
  // ثوابت القياس
  static const double _standardCardWidthCm = 8.56; // عرض بطاقة ائتمان قياسي
  static const double _headEstimationFactor = 2.5; // معامل تقدير قمة الرأس
  static const double _zScaleFactor = 1.0; // معامل تصحيح محور Z

  /// حساب قياسات الجسم من landmarks
  /// 
  /// المعايرة:
  /// - إذا كان `cardPixelWidth` موجود: استخدم معايرة البطاقة المرجعية
  /// - وإلا إذا كان `userManualHeightCm` موجود: استخدم معايرة الطول اليدوية
  /// - إذا لم يكن أي منهما موجود: ترجع null
  /// 
  /// [landmarks] - قائمة 33 نقطة من MediaPipe Pose
  /// [userManualHeightCm] - طول المستخدم الفعلي بالسم (للمعايرة)
  /// [cardPixelWidth] - عرض البطاقة المرجعية بالبكسل (للمعايرة)
  static MeasurementResult? calculateMeasurements({
    required List<PoseLandmark> landmarks,
    double? userManualHeightCm,
    double? cardPixelWidth,
  }) {
    // التحقق من صحة البيانات
    if (landmarks.length < 33) {
      throw ArgumentError(
        'Invalid landmarks: expected 33, got ${landmarks.length}',
      );
    }

    // التحقق من وجود معايرة
    if (userManualHeightCm == null && cardPixelWidth == null) {
      return null; // لا توجد معايرة
    }

    try {
      // الخطوة 1: حساب نسبة التحويل (Pixel to CM Ratio)
      final calibrationResult = _calculateCalibrationRatio(
        landmarks: landmarks,
        userManualHeightCm: userManualHeightCm,
        cardPixelWidth: cardPixelWidth,
      );

      final ratio = calibrationResult.ratio;
      final calibrationType = calibrationResult.type;

      // الخطوة 2: حساب القياسات الخام (بوحدات النموذج)
      final rawHeight = _calculateRawBodyHeight(landmarks);
      final rawShoulderWidth = _calculateRawShoulderWidth(landmarks);
      final rawChestGirth = _calculateRawChestCircumference(landmarks);
      final rawWaistGirth = _calculateRawWaistCircumference(landmarks);
      final rawHipGirth = _calculateRawHipCircumference(landmarks);
      final rawArmLength = _calculateRawArmLength(landmarks);
      final rawInseam = _calculateRawInseam(landmarks);

      // الخطوة 3: تطبيق نسبة التحويل
      return MeasurementResult(
        totalHeight: rawHeight * ratio,
        shoulderWidth: rawShoulderWidth * ratio,
        chestCircumference: rawChestGirth * ratio,
        waistCircumference: rawWaistGirth * ratio,
        hipCircumference: rawHipGirth * ratio,
        armLength: rawArmLength * ratio,
        inseam: rawInseam * ratio,
        pixelToCmRatio: ratio,
        calibrationType: calibrationType,
      );
    } catch (e) {
      // في حالة وجود مشكلة في الحسابات
      return null;
    }
  }

  // ==================== معايرة ====================

  /// حساب نسبة التحويل من البكسل إلى السنتيمتر
  static ({double ratio, CalibrationType type}) _calculateCalibrationRatio({
    required List<PoseLandmark> landmarks,
    double? userManualHeightCm,
    double? cardPixelWidth,
  }) {
    // أولوية المعايرة بالبطاقة المرجعية (أدق)
    if (cardPixelWidth != null && cardPixelWidth > 0) {
      final ratio = _standardCardWidthCm / cardPixelWidth;
      return (ratio: ratio, type: CalibrationType.referenceObject);
    }

    // معايرة بالطول اليدوي
    if (userManualHeightCm != null && userManualHeightCm > 0) {
      final rawBodyHeight = _calculateRawBodyHeight(landmarks);
      if (rawBodyHeight <= 0) {
        throw StateError('Invalid body height calculation');
      }
      final ratio = userManualHeightCm / rawBodyHeight;
      return (ratio: ratio, type: CalibrationType.manualHeight);
    }

    throw StateError('No calibration method available');
  }

  // ==================== حسابات المسافات ====================

  /// حساب المسافة الإقليدية ثلاثية الأبعاد بين نقطتين
  static double _distance3D(PoseLandmark p1, PoseLandmark p2) {
    final dx = p2.x - p1.x;
    final dy = p2.y - p1.y;
    final dz = (p2.z - p1.z) * _zScaleFactor; // تطبيق معامل تصحيح Z

    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  /// حساب المسافة ثنائية الأبعاد (X, Y فقط)
  static double _distance2D(PoseLandmark p1, PoseLandmark p2) {
    final dx = p2.x - p1.x;
    final dy = p2.y - p1.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// حساب نقطة منتصف بين نقطتين
  static PoseLandmark _midpoint(PoseLandmark p1, PoseLandmark p2) {
    return PoseLandmark(
      x: (p1.x + p2.x) / 2,
      y: (p1.y + p2.y) / 2,
      z: (p1.z + p2.z) / 2,
      visibility: math.min(p1.visibility, p2.visibility),
    );
  }

  // ==================== حساب المحيطات (Girth) ====================

  /// حساب محيط قطع ناقص باستخدام تقريب Ramanujan
  /// 
  /// [width] - نصف القطر الأفقي (a)
  /// [depth] - نصف القطر الأمامي/الخلفي (b)
  static double _calculateEllipseGirth(double width, double depth) {
    final a = width / 2; // نصف المحور الأفقي
    final b = depth / 2; // نصف المحور العمودي

    // تقريب Ramanujan للمحيط: π * (3(a+b) - sqrt((3a+b)(a+3b)))
    final sum = a + b;
    final term1 = 3 * a + b;
    final term2 = a + 3 * b;
    final sqrtTerm = math.sqrt(term1 * term2);

    return math.pi * (3 * sum - sqrtTerm);
  }

  // ==================== حسابات القياسات الخام ====================

  /// حساب الطول الكامل للجسم (من قمة الرأس المقدّرة إلى الكعب)
  static double _calculateRawBodyHeight(List<PoseLandmark> landmarks) {
    // نقاط رئيسية
    final nose = landmarks[0]; // الأنف
    final leftEye = landmarks[2]; // العين اليسرى
    final rightEye = landmarks[5]; // العين اليمنى
    final leftHeel = landmarks[29]; // كعب القدم الأيسر
    final rightHeel = landmarks[30]; // كعب القدم الأيمن

    // حساب منتصف العينين
    final midEye = _midpoint(leftEye, rightEye);

    // تقدير قمة الرأس
    // المسافة من الأنف إلى منتصف العينين
    final noseToEyeDist = _distance3D(nose, midEye);

    // قمة الرأس = منتصف العينين + (مسافة الأنف-العين × معامل التقدير) للأعلى
    final estimatedVertex = PoseLandmark(
      x: midEye.x,
      y: midEye.y - (noseToEyeDist * _headEstimationFactor), // Y للأعلى سالب
      z: midEye.z,
      visibility: midEye.visibility,
    );

    // حساب منتصف الكعبين
    final midHeel = _midpoint(leftHeel, rightHeel);

    // الطول الكامل
    return _distance3D(estimatedVertex, midHeel);
  }

  /// حساب عرض الكتفين
  static double _calculateRawShoulderWidth(List<PoseLandmark> landmarks) {
    final leftShoulder = landmarks[11];
    final rightShoulder = landmarks[12];

    return _distance3D(leftShoulder, rightShoulder);
  }

  /// حساب محيط الصدر
  static double _calculateRawChestCircumference(List<PoseLandmark> landmarks) {
    final leftShoulder = landmarks[11];
    final rightShoulder = landmarks[12];

    // العرض = المسافة بين الكتفين
    final width = _distance2D(leftShoulder, rightShoulder);

    // تقدير العمق من فرق Z
    // نستخدم متوسط Z للكتفين كمرجع
    final avgShoulderZ = (leftShoulder.z + rightShoulder.z) / 2;

    // نفترض أن العمق يساوي 60% من العرض (نسبة تشريحية معتادة)
    // يمكن تحسين ذلك باستخدام نقاط إضافية إذا توفرت
    final depth = width * 0.6;

    return _calculateEllipseGirth(width, depth);
  }

  /// حساب محيط الخصر (عند مستوى الورك)
  static double _calculateRawWaistCircumference(List<PoseLandmark> landmarks) {
    final leftHip = landmarks[23];
    final rightHip = landmarks[24];

    // العرض = المسافة بين الوركين
    final width = _distance2D(leftHip, rightHip);

    // تقدير العمق (نسبة تشريحية: 70% من العرض)
    final depth = width * 0.7;

    return _calculateEllipseGirth(width, depth);
  }

  /// حساب محيط الأرداف
  static double _calculateRawHipCircumference(List<PoseLandmark> landmarks) {
    final leftHip = landmarks[23];
    final rightHip = landmarks[24];

    // الأرداف أعرض من الخصر
    final width = _distance2D(leftHip, rightHip);

    // نسبة تشريحية: العمق = 80% من العرض
    final depth = width * 0.8;

    return _calculateEllipseGirth(width, depth);
  }

  /// حساب طول الذراع (من الكتف إلى المعصم)
  static double _calculateRawArmLength(List<PoseLandmark> landmarks) {
    // نستخدم الذراع الأيمن
    final shoulder = landmarks[12]; // الكتف الأيمن
    final elbow = landmarks[14]; // الكوع الأيمن
    final wrist = landmarks[16]; // المعصم الأيمن

    // طول العضد (Shoulder to Elbow)
    final upperArm = _distance3D(shoulder, elbow);

    // طول الساعد (Elbow to Wrist)
    final forearm = _distance3D(elbow, wrist);

    return upperArm + forearm;
  }

  /// حساب طول الساق الداخلي (Inseam)
  /// من منتصف الورك إلى الكعب (45-48% من الطول الكلي)
  static double _calculateRawInseam(List<PoseLandmark> landmarks) {
    final leftHip = landmarks[23];
    final rightHip = landmarks[24];
    final leftHeel = landmarks[29];
    final rightHeel = landmarks[30];

    // منتصف الوركين (نقطة الانطلاق للساق الداخلي)
    final hipMid = _midpoint(leftHip, rightHip);

    // منتصف الكعبين (نقطة النهاية على الأرض)
    final heelMid = _midpoint(leftHeel, rightHeel);

    // المسافة المباشرة من منتصف الورك إلى الأرض
    return _distance3D(hipMid, heelMid);
  }

  // ==================== وظائف مساعدة ====================

  /// التحقق من جودة القياسات بناءً على visibility
  static bool isGoodQuality(List<PoseLandmark> landmarks) {
    // نقاط حرجة يجب أن تكون مرئية
    final criticalIndices = [
      0, // الأنف
      11, 12, // الكتفين
      23, 24, // الوركين
      29, 30, // الكعبين
    ];

    const minVisibility = 0.5;

    for (final index in criticalIndices) {
      if (landmarks[index].visibility < minVisibility) {
        return false;
      }
    }

    return true;
  }
}
