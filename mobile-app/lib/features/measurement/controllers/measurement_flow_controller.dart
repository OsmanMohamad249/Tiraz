import '../../../core/models/pose_landmark.dart';
import '../data/measurement_result.dart';
import '../logic/body_calculator.dart';
import '../../../core/services/voice_service.dart';

/// خطوات جلسة القياس المتعدد
enum MeasurementStep {
  front,      // وضعية أمامية
  sideRight,  // وضعية جانبية يمين
  back,       // وضعية خلفية
  sideLeft,   // وضعية جانبية يسار
  calibration, // مرحلة المعايرة والحساب
  done,       // انتهت الجلسة
}

/// بيانات خطوة واحدة من الجلسة
class StepData {
  final MeasurementStep step;
  final List<PoseLandmark> landmarks;
  final DateTime capturedAt;

  StepData({
    required this.step,
    required this.landmarks,
    required this.capturedAt,
  });
}

/// متحكم جلسة القياس المتعدد مع التوجيه الصوتي
class MeasurementFlowController {
  final VoiceService _voiceService = VoiceService();
  final bool isArabic;

  MeasurementStep _currentStep = MeasurementStep.front;
  final Map<MeasurementStep, StepData> _capturedSteps = {};
  double? _userHeightCm;

  MeasurementFlowController({this.isArabic = true});

  /// الخطوة الحالية
  MeasurementStep get currentStep => _currentStep;

  /// عدد الخطوات المكتملة
  int get completedSteps => _capturedSteps.length;

  /// إجمالي الخطوات المطلوبة
  int get totalSteps => 4;

  /// نسبة الإكمال (0.0 - 1.0)
  double get progress => completedSteps / totalSteps;

  /// هل تم إكمال جميع الخطوات؟
  bool get isSessionComplete => completedSteps >= totalSteps;

  /// بدء جلسة جديدة
  Future<void> startSession({double? userHeightCm}) async {
    _currentStep = MeasurementStep.front;
    _capturedSteps.clear();
    _userHeightCm = userHeightCm;

    await _voiceService.initialize(isArabic: isArabic);
    await _speakInstruction(_currentStep);
  }

  /// التقاط خطوة حالية والانتقال للتالية
  Future<bool> captureStep(List<PoseLandmark> landmarks) async {
    // التحقق من جودة البيانات
    if (!BodyCalculator.isGoodQuality(landmarks)) {
      await _voiceService.speak(
        isArabic 
          ? 'الوضعية غير واضحة، حاول مرة أخرى'
          : 'Pose not clear, please try again'
      );
      return false;
    }

    // حفظ البيانات
    _capturedSteps[_currentStep] = StepData(
      step: _currentStep,
      landmarks: landmarks,
      capturedAt: DateTime.now(),
    );

    // صوت تأكيد
    await _voiceService.speak(
      isArabic ? 'ممتاز!' : 'Great!'
    );

    // الانتقال للخطوة التالية
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!isSessionComplete) {
      _moveToNextStep();
      await _speakInstruction(_currentStep);
      return true;
    } else {
      _currentStep = MeasurementStep.calibration;
      return true;
    }
  }

  /// الانتقال للخطوة التالية
  void _moveToNextStep() {
    switch (_currentStep) {
      case MeasurementStep.front:
        _currentStep = MeasurementStep.sideRight;
        break;
      case MeasurementStep.sideRight:
        _currentStep = MeasurementStep.back;
        break;
      case MeasurementStep.back:
        _currentStep = MeasurementStep.sideLeft;
        break;
      case MeasurementStep.sideLeft:
        _currentStep = MeasurementStep.done;
        break;
      default:
        break;
    }
  }

  /// نطق تعليمات الخطوة
  Future<void> _speakInstruction(MeasurementStep step) async {
    final instruction = _getStepInstruction(step);
    await _voiceService.speak(instruction);
  }

  /// الحصول على تعليمات الخطوة
  String _getStepInstruction(MeasurementStep step) {
    if (isArabic) {
      switch (step) {
        case MeasurementStep.front:
          return 'قف أمام الكاميرا بشكل مستقيم';
        case MeasurementStep.sideRight:
          return 'الآن استدر لليمين، منظر جانبي';
        case MeasurementStep.back:
          return 'ممتاز، الآن استدر للخلف';
        case MeasurementStep.sideLeft:
          return 'رائع، آخر وضعية، استدر لليسار';
        default:
          return 'جاري الحساب';
      }
    } else {
      switch (step) {
        case MeasurementStep.front:
          return 'Stand in front of the camera';
        case MeasurementStep.sideRight:
          return 'Now turn right, side view';
        case MeasurementStep.back:
          return 'Great, now turn to the back';
        case MeasurementStep.sideLeft:
          return 'Perfect, last pose, turn left';
        default:
          return 'Calculating measurements';
      }
    }
  }

  /// الحصول على اسم الخطوة للعرض
  String getStepName(MeasurementStep step) {
    if (isArabic) {
      switch (step) {
        case MeasurementStep.front:
          return 'أمامي';
        case MeasurementStep.sideRight:
          return 'جانب أيمن';
        case MeasurementStep.back:
          return 'خلفي';
        case MeasurementStep.sideLeft:
          return 'جانب أيسر';
        case MeasurementStep.calibration:
          return 'جاري الحساب';
        case MeasurementStep.done:
          return 'تم';
      }
    } else {
      switch (step) {
        case MeasurementStep.front:
          return 'Front';
        case MeasurementStep.sideRight:
          return 'Right Side';
        case MeasurementStep.back:
          return 'Back';
        case MeasurementStep.sideLeft:
          return 'Left Side';
        case MeasurementStep.calibration:
          return 'Calculating';
        case MeasurementStep.done:
          return 'Done';
      }
    }
  }

  /// دمج النتائج من جميع الوضعيات وحساب القياسات النهائية
  Future<MeasurementResult?> calculateFinalMeasurements() async {
    if (!isSessionComplete) return null;

    // نستخدم الوضعية الأمامية للحسابات الأساسية
    final frontData = _capturedSteps[MeasurementStep.front];
    if (frontData == null) return null;

    // حساب القياسات باستخدام البيانات الأمامية
    final result = BodyCalculator.calculateMeasurements(
      landmarks: frontData.landmarks,
      userManualHeightCm: _userHeightCm,
    );

    if (result != null) {
      _currentStep = MeasurementStep.done;
    }

    return result;
  }

  /// إعادة التقاط خطوة معينة
  Future<void> retakeStep(MeasurementStep step) async {
    _capturedSteps.remove(step);
    _currentStep = step;
    await _speakInstruction(step);
  }

  /// إيقاف التوجيه الصوتي
  Future<void> stopVoice() async {
    await _voiceService.stop();
  }

  /// تنظيف الموارد
  Future<void> dispose() async {
    await _voiceService.dispose();
  }
}
