/// اختبار نظام القياس الكامل مع صور افتراضية
/// 
/// يقوم هذا السكريبت بـ:
/// 1. إنشاء 4 مجموعات بيانات landmarks افتراضية (وضعيات مختلفة)
/// 2. معايرة بالطول اليدوي (170 سم)
/// 3. حساب القياسات السبعة لكل وضعية
/// 4. عرض النتائج بشكل مفصل

import 'dart:math' as math;
import 'package:qeyafa/core/models/pose_landmark.dart';
import 'package:qeyafa/features/measurement/logic/body_calculator.dart';
import 'package:qeyafa/features/measurement/data/measurement_result.dart';

void main() {
  print('═══════════════════════════════════════════════════════════');
  print('🧍 نظام قياس الجسم - اختبار شامل');
  print('═══════════════════════════════════════════════════════════');
  print('');
  print('📊 بيانات الشخص:');
  print('   • الطول الفعلي: 170 سم');
  print('   • الوزن: 54 كجم');
  print('   • نوع المعايرة: يدوية (Manual Height Calibration)');
  print('');
  print('═══════════════════════════════════════════════════════════');
  print('');

  // إنشاء 4 وضعيات مختلفة
  final List<Map<String, dynamic>> testCases = [
    {
      'name': '📷 الصورة 1: وضعية واقفة مستقيمة - نظرة أمامية',
      'description': 'شخص واقف بشكل مستقيم، اليدين بجانب الجسم',
      'landmarks': _createFrontStandingPose(),
    },
    {
      'name': '📷 الصورة 2: وضعية واقفة - الذراعين ممدودين جانباً',
      'description': 'شخص واقف، الذراعين ممدودين أفقياً (T-Pose)',
      'landmarks': _createTPose(),
    },
    {
      'name': '📷 الصورة 3: وضعية جانبية - نظرة جانبية',
      'description': 'شخص واقف، منظر جانبي كامل',
      'landmarks': _createSidePose(),
    },
    {
      'name': '📷 الصورة 4: وضعية واقفة - يد واحدة مرفوعة',
      'description': 'شخص واقف، اليد اليمنى مرفوعة للأعلى',
      'landmarks': _createOneArmUpPose(),
    },
  ];

  // معالجة كل وضعية
  for (var i = 0; i < testCases.length; i++) {
    final testCase = testCases[i];
    print('');
    print('─────────────────────────────────────────────────────────');
    print(testCase['name']);
    print('─────────────────────────────────────────────────────────');
    print('📝 الوصف: ${testCase['description']}');
    print('');

    final landmarks = testCase['landmarks'] as List<PoseLandmark>;
    
    // فحص جودة البيانات
    final isGoodQuality = BodyCalculator.isGoodQuality(landmarks);
    print('✓ فحص جودة البيانات: ${isGoodQuality ? "✅ جيدة" : "❌ ضعيفة"}');
    
    if (!isGoodQuality) {
      print('⚠️  تحذير: جودة البيانات ليست كافية للقياس الدقيق');
      print('');
      continue;
    }

    // حساب القياسات
    final result = BodyCalculator.calculateMeasurements(
      landmarks: landmarks,
      userManualHeightCm: 170.0, // الطول الفعلي
    );

    if (result == null) {
      print('❌ فشل حساب القياسات');
      print('');
      continue;
    }

    // عرض النتائج
    print('');
    print('📏 القياسات المحسوبة:');
    print('   ┌─────────────────────────────────────────┐');
    print('   │ 1️⃣  الطول الكلي:          ${_formatMeasurement(result.totalHeight)} سم │');
    print('   │ 2️⃣  عرض الكتفين:         ${_formatMeasurement(result.shoulderWidth)} سم │');
    print('   │ 3️⃣  محيط الصدر:          ${_formatMeasurement(result.chestCircumference)} سم │');
    print('   │ 4️⃣  محيط الخصر:          ${_formatMeasurement(result.waistCircumference)} سم │');
    print('   │ 5️⃣  محيط الوركين:        ${_formatMeasurement(result.hipCircumference)} سم │');
    print('   │ 6️⃣  طول الذراع:          ${_formatMeasurement(result.armLength)} سم │');
    print('   │ 7️⃣  المسافة الداخلية:     ${_formatMeasurement(result.inseam)} سم │');
    print('   └─────────────────────────────────────────┘');
    print('');
    print('📋 نوع المعايرة: ${result.calibrationType == CalibrationType.manualHeight ? "يدوية" : "بطاقة مرجعية"}');
    
    // حساب BMI تقريبي (للتحقق من المنطقية)
    final heightInMeters = result.totalHeight / 100;
    final bmi = 54 / (heightInMeters * heightInMeters);
    print('📊 مؤشر كتلة الجسم (BMI): ${bmi.toStringAsFixed(1)} (الوزن 54 كجم)');
    
    // تحليل النتائج
    _analyzeResults(result, i + 1);
    print('');
  }

  print('═══════════════════════════════════════════════════════════');
  print('✅ اكتمل الاختبار الشامل');
  print('═══════════════════════════════════════════════════════════');
}

/// تنسيق القياس لعرضه (مع محاذاة)
String _formatMeasurement(double value) {
  final formatted = value.toStringAsFixed(1);
  return formatted.padLeft(6); // محاذاة للأرقام
}

/// تحليل منطقية النتائج
void _analyzeResults(MeasurementResult result, int imageNumber) {
  print('');
  print('🔍 تحليل النتائج:');
  
  final issues = <String>[];
  
  // 1. فحص الطول (يجب أن يكون قريباً من 170 سم)
  if ((result.totalHeight - 170.0).abs() > 5.0) {
    issues.add('الطول المحسوب (${result.totalHeight.toStringAsFixed(1)} سم) بعيد عن المعايرة (170 سم)');
  } else {
    print('   ✓ الطول متطابق مع المعايرة (±5 سم)');
  }
  
  // 2. فحص نسبة عرض الكتفين إلى الطول (عادة 23-25% للبالغين)
  final shoulderRatio = (result.shoulderWidth / result.totalHeight) * 100;
  if (shoulderRatio >= 20 && shoulderRatio <= 28) {
    print('   ✓ نسبة عرض الكتفين طبيعية (${shoulderRatio.toStringAsFixed(1)}%)');
  } else {
    issues.add('نسبة عرض الكتفين غير طبيعية (${shoulderRatio.toStringAsFixed(1)}%)');
  }
  
  // 3. فحص نسبة الخصر إلى الوركين (عادة 0.7-0.9)
  final waistHipRatio = result.waistCircumference / result.hipCircumference;
  if (waistHipRatio >= 0.6 && waistHipRatio <= 1.0) {
    print('   ✓ نسبة الخصر/الوركين طبيعية (${waistHipRatio.toStringAsFixed(2)})');
  } else {
    issues.add('نسبة الخصر/الوركين غير طبيعية (${waistHipRatio.toStringAsFixed(2)})');
  }
  
  // 4. فحص طول الذراع (عادة 35-40% من الطول)
  final armRatio = (result.armLength / result.totalHeight) * 100;
  if (armRatio >= 30 && armRatio <= 45) {
    print('   ✓ طول الذراع متناسب (${armRatio.toStringAsFixed(1)}%)');
  } else {
    issues.add('طول الذراع غير متناسب (${armRatio.toStringAsFixed(1)}%)');
  }
  
  // 5. فحص المسافة الداخلية (عادة 40-50% من الطول)
  final inseamRatio = (result.inseam / result.totalHeight) * 100;
  if (inseamRatio >= 38 && inseamRatio <= 52) {
    print('   ✓ المسافة الداخلية متناسبة (${inseamRatio.toStringAsFixed(1)}%)');
  } else {
    issues.add('المسافة الداخلية غير متناسبة (${inseamRatio.toStringAsFixed(1)}%)');
  }
  
  // عرض التحذيرات
  if (issues.isNotEmpty) {
    print('');
    print('   ⚠️  تحذيرات:');
    for (final issue in issues) {
      print('      • $issue');
    }
  } else {
    print('   ✅ جميع النسب ضمن المعدلات الطبيعية');
  }
}

/// إنشاء وضعية واقفة مستقيمة - منظر أمامي
List<PoseLandmark> _createFrontStandingPose() {
  // شخص واقف 170 سم، منظر أمامي
  // النسب الأنثروبومترية القياسية
  
  return [
    // 0: Nose
    PoseLandmark(x: 0.5, y: 0.15, z: 0.0, visibility: 0.98),
    // 1: Left Eye Inner
    PoseLandmark(x: 0.48, y: 0.13, z: -0.02, visibility: 0.97),
    // 2: Left Eye
    PoseLandmark(x: 0.47, y: 0.13, z: -0.02, visibility: 0.98),
    // 3: Left Eye Outer
    PoseLandmark(x: 0.46, y: 0.13, z: -0.02, visibility: 0.97),
    // 4: Right Eye Inner
    PoseLandmark(x: 0.52, y: 0.13, z: -0.02, visibility: 0.97),
    // 5: Right Eye
    PoseLandmark(x: 0.53, y: 0.13, z: -0.02, visibility: 0.98),
    // 6: Right Eye Outer
    PoseLandmark(x: 0.54, y: 0.13, z: -0.02, visibility: 0.97),
    // 7: Left Ear
    PoseLandmark(x: 0.44, y: 0.14, z: -0.08, visibility: 0.85),
    // 8: Right Ear
    PoseLandmark(x: 0.56, y: 0.14, z: -0.08, visibility: 0.85),
    // 9: Mouth Left
    PoseLandmark(x: 0.48, y: 0.17, z: 0.0, visibility: 0.92),
    // 10: Mouth Right
    PoseLandmark(x: 0.52, y: 0.17, z: 0.0, visibility: 0.92),
    // 11: Left Shoulder
    PoseLandmark(x: 0.40, y: 0.30, z: 0.0, visibility: 0.95),
    // 12: Right Shoulder
    PoseLandmark(x: 0.60, y: 0.30, z: 0.0, visibility: 0.95),
    // 13: Left Elbow
    PoseLandmark(x: 0.38, y: 0.50, z: 0.02, visibility: 0.93),
    // 14: Right Elbow
    PoseLandmark(x: 0.62, y: 0.50, z: 0.02, visibility: 0.93),
    // 15: Left Wrist
    PoseLandmark(x: 0.37, y: 0.65, z: 0.03, visibility: 0.90),
    // 16: Right Wrist
    PoseLandmark(x: 0.63, y: 0.65, z: 0.03, visibility: 0.90),
    // 17: Left Pinky
    PoseLandmark(x: 0.365, y: 0.68, z: 0.04, visibility: 0.75),
    // 18: Right Pinky
    PoseLandmark(x: 0.635, y: 0.68, z: 0.04, visibility: 0.75),
    // 19: Left Index
    PoseLandmark(x: 0.375, y: 0.68, z: 0.04, visibility: 0.78),
    // 20: Right Index
    PoseLandmark(x: 0.625, y: 0.68, z: 0.04, visibility: 0.78),
    // 21: Left Thumb
    PoseLandmark(x: 0.380, y: 0.67, z: 0.03, visibility: 0.80),
    // 22: Right Thumb
    PoseLandmark(x: 0.620, y: 0.67, z: 0.03, visibility: 0.80),
    // 23: Left Hip
    PoseLandmark(x: 0.42, y: 0.62, z: 0.0, visibility: 0.94),
    // 24: Right Hip
    PoseLandmark(x: 0.58, y: 0.62, z: 0.0, visibility: 0.94),
    // 25: Left Knee
    PoseLandmark(x: 0.43, y: 0.82, z: 0.02, visibility: 0.92),
    // 26: Right Knee
    PoseLandmark(x: 0.57, y: 0.82, z: 0.02, visibility: 0.92),
    // 27: Left Ankle
    PoseLandmark(x: 0.44, y: 0.95, z: 0.0, visibility: 0.88),
    // 28: Right Ankle
    PoseLandmark(x: 0.56, y: 0.95, z: 0.0, visibility: 0.88),
    // 29: Left Heel
    PoseLandmark(x: 0.44, y: 0.98, z: -0.02, visibility: 0.82),
    // 30: Right Heel
    PoseLandmark(x: 0.56, y: 0.98, z: -0.02, visibility: 0.82),
    // 31: Left Foot Index
    PoseLandmark(x: 0.44, y: 0.99, z: 0.05, visibility: 0.75),
    // 32: Right Foot Index
    PoseLandmark(x: 0.56, y: 0.99, z: 0.05, visibility: 0.75),
  ];
}

/// إنشاء وضعية T-Pose (الذراعين ممدودين أفقياً)
List<PoseLandmark> _createTPose() {
  // نفس الوضعية السابقة لكن مع تمديد الذراعين
  final pose = _createFrontStandingPose();
  
  // تعديل مواضع الذراعين
  pose[13] = PoseLandmark(x: 0.20, y: 0.30, z: 0.0, visibility: 0.95); // Left Elbow
  pose[14] = PoseLandmark(x: 0.80, y: 0.30, z: 0.0, visibility: 0.95); // Right Elbow
  pose[15] = PoseLandmark(x: 0.05, y: 0.30, z: 0.0, visibility: 0.92); // Left Wrist
  pose[16] = PoseLandmark(x: 0.95, y: 0.30, z: 0.0, visibility: 0.92); // Right Wrist
  pose[17] = PoseLandmark(x: 0.02, y: 0.30, z: 0.01, visibility: 0.70); // Left Pinky
  pose[18] = PoseLandmark(x: 0.98, y: 0.30, z: 0.01, visibility: 0.70); // Right Pinky
  pose[19] = PoseLandmark(x: 0.03, y: 0.30, z: 0.01, visibility: 0.72); // Left Index
  pose[20] = PoseLandmark(x: 0.97, y: 0.30, z: 0.01, visibility: 0.72); // Right Index
  pose[21] = PoseLandmark(x: 0.04, y: 0.29, z: 0.0, visibility: 0.75); // Left Thumb
  pose[22] = PoseLandmark(x: 0.96, y: 0.29, z: 0.0, visibility: 0.75); // Right Thumb
  
  return pose;
}

/// إنشاء وضعية جانبية
List<PoseLandmark> _createSidePose() {
  return [
    // 0: Nose
    PoseLandmark(x: 0.50, y: 0.15, z: -0.25, visibility: 0.98),
    // 1: Left Eye Inner
    PoseLandmark(x: 0.50, y: 0.13, z: -0.24, visibility: 0.40), // غير مرئي من الجانب
    // 2: Left Eye
    PoseLandmark(x: 0.50, y: 0.13, z: -0.25, visibility: 0.95),
    // 3: Left Eye Outer
    PoseLandmark(x: 0.50, y: 0.13, z: -0.26, visibility: 0.90),
    // 4: Right Eye Inner (مخفي)
    PoseLandmark(x: 0.50, y: 0.13, z: -0.26, visibility: 0.20),
    // 5: Right Eye (مخفي)
    PoseLandmark(x: 0.50, y: 0.13, z: -0.27, visibility: 0.20),
    // 6: Right Eye Outer (مخفي)
    PoseLandmark(x: 0.50, y: 0.13, z: -0.28, visibility: 0.15),
    // 7: Left Ear
    PoseLandmark(x: 0.50, y: 0.14, z: -0.30, visibility: 0.92),
    // 8: Right Ear (مخفي)
    PoseLandmark(x: 0.50, y: 0.14, z: -0.20, visibility: 0.15),
    // 9: Mouth Left
    PoseLandmark(x: 0.50, y: 0.17, z: -0.23, visibility: 0.88),
    // 10: Mouth Right
    PoseLandmark(x: 0.50, y: 0.17, z: -0.27, visibility: 0.30),
    // 11: Left Shoulder
    PoseLandmark(x: 0.50, y: 0.30, z: -0.20, visibility: 0.96),
    // 12: Right Shoulder
    PoseLandmark(x: 0.50, y: 0.30, z: -0.30, visibility: 0.50),
    // 13: Left Elbow
    PoseLandmark(x: 0.50, y: 0.50, z: -0.18, visibility: 0.94),
    // 14: Right Elbow
    PoseLandmark(x: 0.50, y: 0.50, z: -0.32, visibility: 0.30),
    // 15: Left Wrist
    PoseLandmark(x: 0.50, y: 0.65, z: -0.17, visibility: 0.91),
    // 16: Right Wrist
    PoseLandmark(x: 0.50, y: 0.65, z: -0.33, visibility: 0.25),
    // 17-22: أصابع اليد
    PoseLandmark(x: 0.50, y: 0.68, z: -0.16, visibility: 0.75),
    PoseLandmark(x: 0.50, y: 0.68, z: -0.34, visibility: 0.20),
    PoseLandmark(x: 0.50, y: 0.68, z: -0.16, visibility: 0.78),
    PoseLandmark(x: 0.50, y: 0.68, z: -0.34, visibility: 0.22),
    PoseLandmark(x: 0.50, y: 0.67, z: -0.15, visibility: 0.80),
    PoseLandmark(x: 0.50, y: 0.67, z: -0.35, visibility: 0.23),
    // 23: Left Hip
    PoseLandmark(x: 0.50, y: 0.62, z: -0.22, visibility: 0.95),
    // 24: Right Hip
    PoseLandmark(x: 0.50, y: 0.62, z: -0.28, visibility: 0.45),
    // 25: Left Knee
    PoseLandmark(x: 0.50, y: 0.82, z: -0.20, visibility: 0.93),
    // 26: Right Knee
    PoseLandmark(x: 0.50, y: 0.82, z: -0.30, visibility: 0.35),
    // 27: Left Ankle
    PoseLandmark(x: 0.50, y: 0.95, z: -0.20, visibility: 0.89),
    // 28: Right Ankle
    PoseLandmark(x: 0.50, y: 0.95, z: -0.30, visibility: 0.30),
    // 29: Left Heel
    PoseLandmark(x: 0.50, y: 0.98, z: -0.22, visibility: 0.83),
    // 30: Right Heel
    PoseLandmark(x: 0.50, y: 0.98, z: -0.32, visibility: 0.25),
    // 31: Left Foot Index
    PoseLandmark(x: 0.50, y: 0.99, z: -0.15, visibility: 0.76),
    // 32: Right Foot Index
    PoseLandmark(x: 0.50, y: 0.99, z: -0.35, visibility: 0.20),
  ];
}

/// إنشاء وضعية يد واحدة مرفوعة
List<PoseLandmark> _createOneArmUpPose() {
  final pose = _createFrontStandingPose();
  
  // رفع اليد اليمنى للأعلى
  pose[12] = PoseLandmark(x: 0.60, y: 0.30, z: 0.0, visibility: 0.95); // Right Shoulder (كما هو)
  pose[14] = PoseLandmark(x: 0.62, y: 0.12, z: 0.0, visibility: 0.94); // Right Elbow (للأعلى)
  pose[16] = PoseLandmark(x: 0.63, y: 0.05, z: 0.0, visibility: 0.93); // Right Wrist (للأعلى)
  pose[18] = PoseLandmark(x: 0.635, y: 0.03, z: 0.01, visibility: 0.72); // Right Pinky
  pose[20] = PoseLandmark(x: 0.625, y: 0.03, z: 0.01, visibility: 0.75); // Right Index
  pose[22] = PoseLandmark(x: 0.620, y: 0.04, z: 0.0, visibility: 0.77); // Right Thumb
  
  return pose;
}
