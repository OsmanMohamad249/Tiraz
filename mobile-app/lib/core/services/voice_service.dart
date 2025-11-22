import 'package:flutter_tts/flutter_tts.dart';

/// خدمة التوجيه الصوتي (Text-to-Speech)
/// 
/// تدعم اللغة العربية والإنجليزية مع إمكانية التبديل الديناميكي
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isArabic = true;

  /// تهيئة خدمة الصوت
  Future<void> initialize({bool isArabic = true}) async {
    if (_isInitialized) return;

    _isArabic = isArabic;

    try {
      // إعدادات عامة
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5); // سرعة معتدلة
      await _flutterTts.setPitch(1.0);

      // اختيار اللغة
      await setLanguage(isArabic);

      // iOS specific settings
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );

      _isInitialized = true;
    } catch (e) {
      print('⚠️ Voice Service initialization error: $e');
    }
  }

  /// تغيير اللغة
  Future<void> setLanguage(bool isArabic) async {
    _isArabic = isArabic;
    
    if (isArabic) {
      // العربية السعودية (أفضل جودة للعربية)
      await _flutterTts.setLanguage("ar-SA");
    } else {
      // الإنجليزية الأمريكية
      await _flutterTts.setLanguage("en-US");
    }
  }

  /// نطق نص
  /// 
  /// يتوقف عن أي نطق سابق ويبدأ النطق الجديد
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize(isArabic: _isArabic);
    }

    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      print('⚠️ Voice Service speak error: $e');
    }
  }

  /// إيقاف النطق الحالي
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('⚠️ Voice Service stop error: $e');
    }
  }

  /// إيقاف مؤقت
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print('⚠️ Voice Service pause error: $e');
    }
  }

  /// التحقق من حالة النطق
  Future<bool> get isSpeaking async {
    try {
      final status = await _flutterTts.synthesizeToFile("", "temp.wav");
      return status == 1;
    } catch (e) {
      return false;
    }
  }

  /// تنظيف الموارد
  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
