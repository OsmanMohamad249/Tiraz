# 📱 دليل بناء APK لتطبيق Qeyafa

## 🎯 الطرق المتاحة لإنشاء APK

---

## ✅ **الطريقة 1: GitHub Actions (آلي وسهل)** ⭐ الأفضل

### الخطوات:
1. **ادفع الكود** إلى GitHub:
   ```bash
   git add .
   git commit -m "Ready to build APK"
   git push origin main
   ```

2. **انتظر 5-10 دقائق** حتى ينتهي البناء

3. **حمّل APK**:
   - افتح: https://github.com/OsmanMohamad249/Qeyafa/actions
   - اضغط على أحدث run ناجح (✅)
   - ستجد في "Artifacts":
     - `qeyafa-debug.apk` (للتجربة)
     - `qeyafa-release.apk` (للإنتاج)
   - أو انتقل إلى [Releases](https://github.com/OsmanMohamad249/Qeyafa/releases)

### المميزات:
- ✅ لا يتطلب تثبيت أي شيء
- ✅ بناء آلي عند كل تحديث
- ✅ تخزين APK لمدة 30 يوم
- ✅ إنشاء Release تلقائي

---

## 🖥️ **الطريقة 2: بناء محلي على جهازك**

### المتطلبات:
- **نظام التشغيل:** Windows, macOS, أو Linux
- **الأدوات:**
  1. Flutter SDK
  2. Android Studio
  3. Java JDK 17

### خطوات التثبيت:

#### 1️⃣ تثبيت Flutter
```bash
# Linux/macOS
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# أو حمّل من: https://docs.flutter.dev/get-started/install
```

#### 2️⃣ تثبيت Android Studio
- حمّل من: https://developer.android.com/studio
- افتح Android Studio → SDK Manager
- ثبّت:
  - ✅ Android SDK Platform 34 (API 34)
  - ✅ Android SDK Build-Tools
  - ✅ Android SDK Command-line Tools

#### 3️⃣ تهيئة Flutter
```bash
flutter doctor --android-licenses  # اقبل جميع التراخيص
flutter doctor -v                  # تحقق من الإعداد
```

#### 4️⃣ بناء APK
```bash
cd /path/to/Qeyafa/mobile-app

# بناء نسخة تجريبية (Debug)
flutter build apk --debug

# أو بناء نسخة محسّنة (Release)
flutter build apk --release

# APK سيكون في:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## 🌐 **الطريقة 3: Codemagic (CI/CD سحابي)**

### الخطوات:
1. اذهب إلى: https://codemagic.io
2. سجّل دخول بحساب GitHub
3. اربط مستودع `Qeyafa`
4. اختر `mobile-app` كمشروع Flutter
5. اضغط "Start your first build"
6. حمّل APK بعد البناء

### المميزات:
- ✅ مجاني لـ 500 دقيقة شهرياً
- ✅ واجهة سهلة
- ✅ دعم iOS أيضاً

---

## 📦 **الطريقة 4: Appetize.io (تجربة مباشرة بدون تحميل)**

لتجربة التطبيق **في المتصفح** دون تثبيت:

1. اذهب إلى: https://appetize.io
2. ارفع APK (بعد بنائه)
3. شغّل التطبيق في محاكي أندرويد افتراضي

---

## 🚀 **طريقة سريعة: استخدام Google IDX**

### بديل لـ Codespaces مع دعم Android:

1. اذهب إلى: https://idx.google.com
2. افتح مشروع Flutter جديد
3. استنسخ الكود:
   ```bash
   git clone https://github.com/OsmanMohamad249/Qeyafa.git
   cd Qeyafa/mobile-app
   ```
4. ابنِ APK:
   ```bash
   flutter build apk --release
   ```

---

## 🔧 **حل مشاكل شائعة**

### مشكلة: "Android SDK not found"
```bash
flutter config --android-sdk /path/to/Android/sdk
```

### مشكلة: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### مشكلة: "Model file not found"
- تأكد من وجود `assets/models/pose_landmarker_heavy.task`
- حجمه ~90 MB

### مشكلة: "Unsigned APK"
- Debug APK: لا يحتاج توقيع
- Release APK: انظر [Signing Guide](https://docs.flutter.dev/deployment/android#signing-the-app)

---

## 📊 **مقارنة الطرق**

| الطريقة | السهولة | الوقت | التكلفة | يتطلب تثبيت |
|---------|---------|-------|---------|-------------|
| GitHub Actions | ⭐⭐⭐⭐⭐ | 5-10 دقائق | مجاني | لا |
| محلي | ⭐⭐⭐ | 30-60 دقيقة (أول مرة) | مجاني | نعم |
| Codemagic | ⭐⭐⭐⭐ | 5-10 دقائق | مجاني | لا |
| Google IDX | ⭐⭐⭐⭐ | 10-15 دقيقة | مجاني | لا |

---

## 🎁 **الطريقة الموصى بها**

### للتجربة السريعة:
👉 **استخدم GitHub Actions** (الملف موجود بالفعل في `.github/workflows/build-android-apk.yml`)

### للتطوير المستمر:
👉 **ثبّت البيئة محلياً** على جهازك

---

## 📝 **ملاحظات مهمة**

1. **APK Debug vs Release:**
   - Debug: حجم أكبر (~100 MB)، مع أدوات التطوير
   - Release: محسّن (~50 MB)، للمستخدمين النهائيين

2. **الصلاحيات المطلوبة:**
   - الكاميرا (للقياس)
   - التخزين (لحفظ الصور)

3. **الأجهزة المدعومة:**
   - Android 7.0 (API 24) أو أحدث
   - معالج ARM64 أو ARMv7 أو x86_64

4. **النموذج الثقيل:**
   - حجم APK سيكون كبير (~90 MB إضافية)
   - بسبب `pose_landmarker_heavy.task`

---

## 🆘 **الدعم**

إذا واجهت مشاكل:
1. تحقق من `flutter doctor -v`
2. راجع سجلات GitHub Actions
3. افتح Issue في المستودع

---

**تم إنشاؤه:** 22 نوفمبر 2025  
**الإصدار:** 1.0.0
