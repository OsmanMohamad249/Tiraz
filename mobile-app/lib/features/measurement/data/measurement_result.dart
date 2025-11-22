/// نتائج قياسات الجسم المحسوبة من landmarks
/// 
/// جميع القياسات بالسنتيمتر (cm)
class MeasurementResult {
  /// الطول الكامل من قمة الرأس (المقدّر) إلى كعب القدم
  final double totalHeight;

  /// عرض الكتفين (المسافة بين نقطتي الكتف الأيمن والأيسر)
  final double shoulderWidth;

  /// محيط الصدر (مُحسوب باستخدام تقريب Ramanujan للقطع الناقص)
  final double chestCircumference;

  /// محيط الخصر (عند مستوى الورك العلوي)
  final double waistCircumference;

  /// محيط الأرداف (عند أوسع نقطة)
  final double hipCircumference;

  /// طول الذراع (من الكتف إلى المعصم)
  final double armLength;

  /// طول الساق الداخلي (inseam) من الورك إلى الكاحل
  final double inseam;

  /// معامل التحويل المستخدم (بكسل/سم)
  final double pixelToCmRatio;

  /// نوع المعايرة المستخدمة
  final CalibrationType calibrationType;

  const MeasurementResult({
    required this.totalHeight,
    required this.shoulderWidth,
    required this.chestCircumference,
    required this.waistCircumference,
    required this.hipCircumference,
    required this.armLength,
    required this.inseam,
    required this.pixelToCmRatio,
    required this.calibrationType,
  });

  /// تحويل إلى Map للتخزين أو الإرسال
  Map<String, dynamic> toJson() => {
        'totalHeight': totalHeight,
        'shoulderWidth': shoulderWidth,
        'chestCircumference': chestCircumference,
        'waistCircumference': waistCircumference,
        'hipCircumference': hipCircumference,
        'armLength': armLength,
        'inseam': inseam,
        'pixelToCmRatio': pixelToCmRatio,
        'calibrationType': calibrationType.toString(),
      };

  /// إنشاء من Map
  factory MeasurementResult.fromJson(Map<String, dynamic> json) {
    return MeasurementResult(
      totalHeight: json['totalHeight'] as double,
      shoulderWidth: json['shoulderWidth'] as double,
      chestCircumference: json['chestCircumference'] as double,
      waistCircumference: json['waistCircumference'] as double,
      hipCircumference: json['hipCircumference'] as double,
      armLength: json['armLength'] as double,
      inseam: json['inseam'] as double,
      pixelToCmRatio: json['pixelToCmRatio'] as double,
      calibrationType: CalibrationType.values.firstWhere(
        (e) => e.toString() == json['calibrationType'],
        orElse: () => CalibrationType.manualHeight,
      ),
    );
  }

  @override
  String toString() {
    return 'MeasurementResult(\n'
        '  Height: ${totalHeight.toStringAsFixed(1)} cm\n'
        '  Shoulders: ${shoulderWidth.toStringAsFixed(1)} cm\n'
        '  Chest: ${chestCircumference.toStringAsFixed(1)} cm\n'
        '  Waist: ${waistCircumference.toStringAsFixed(1)} cm\n'
        '  Hips: ${hipCircumference.toStringAsFixed(1)} cm\n'
        '  Arm: ${armLength.toStringAsFixed(1)} cm\n'
        '  Inseam: ${inseam.toStringAsFixed(1)} cm\n'
        '  Ratio: ${pixelToCmRatio.toStringAsFixed(4)} px/cm\n'
        '  Calibration: $calibrationType\n'
        ')';
  }
}

/// أنواع المعايرة المدعومة
enum CalibrationType {
  /// معايرة يدوية: المستخدم يُدخل طوله الفعلي
  manualHeight,

  /// معايرة بجسم مرجعي: استخدام بطاقة أو جسم معروف العرض
  referenceObject,
}
