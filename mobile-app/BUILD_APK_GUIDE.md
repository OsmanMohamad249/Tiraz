# دليل بناء APK - تطبيق Qeyafa

## 📱 بناء APK للتجربة

### المتطلبات:
- ✅ Android Studio مثبت
- ✅ Android SDK (API 24+)
- ✅ Flutter SDK (3.38.3+)
- ✅ Java JDK 17

---

## 🚀 خطوات البناء

### 1️⃣ تحضير البيئة

```bash
# تأكد من تثبيت Flutter
flutter doctor -v

# يجب أن ترى:
# ✓ Flutter
# ✓ Android toolchain
# ✓ Android Studio
```

### 2️⃣ استنساخ المشروع

```bash
git clone https://github.com/OsmanMohamad249/Qeyafa.git
cd Qeyafa/mobile-app
```

### 3️⃣ تثبيت Dependencies

```bash
flutter clean
flutter pub get
```

### 4️⃣ بناء APK للتجربة (Debug)

```bash
# بناء APK تجريبي (أسرع، حجم أكبر)
flutter build apk --debug

# الملف سيكون في:
# build/app/outputs/flutter-apk/app-debug.apk
```

**أو** للإصدار المحسّن (Release):

```bash
# بناء APK محسّن (أبطأ، حجم أصغر، أداء أفضل)
flutter build apk --release

# الملف سيكون في:
# build/app/outputs/flutter-apk/app-release.apk
```

### 5️⃣ بناء APK حسب المعمارية (أصغر حجماً)

```bash
# بناء APK لكل معمارية على حدة
flutter build apk --split-per-abi

# ستحصل على 3 ملفات:
# - app-armeabi-v7a-release.apk  (للأجهزة القديمة 32-bit)
# - app-arm64-v8a-release.apk    (للأجهزة الحديثة 64-bit) ← الأكثر شيوعاً
# - app-x86_64-release.apk       (للمحاكيات x86)
```

---

## 📦 الأحجام المتوقعة

| النوع | الحجم التقريبي | الاستخدام |
|------|----------------|-----------|
| Debug APK | ~100-150 MB | التطوير والاختبار |
| Release APK (Universal) | ~80-120 MB | التوزيع العام |
| Release APK (arm64-v8a) | ~40-60 MB | معظم الهواتف الحديثة |

**ملاحظة:** الحجم كبير نسبياً بسبب:
- MediaPipe Heavy Model (~90 MB)
- Flutter Engine
- مكتبات معالجة الصور

---

## 🧪 تثبيت APK على الجهاز

### عبر USB (ADB):

```bash
# تأكد من تفعيل USB Debugging على الهاتف
flutter install

# أو يدوياً:
adb install build/app/outputs/flutter-apk/app-release.apk
```

### عبر الملف مباشرة:

1. انسخ ملف APK إلى الهاتف
2. افتح الملف من مدير الملفات
3. اسمح بالتثبيت من مصادر غير معروفة (إذا طُلب ذلك)
4. اضغط "تثبيت"

---

## 🔍 التحقق من النموذج

تأكد من وجود ملف النموذج:

```bash
ls -lh mobile-app/assets/models/pose_landmarker_heavy.task

# يجب أن يكون الحجم ~90 MB
```

إذا لم يكن موجوداً، حمّله:

```bash
cd mobile-app/assets/models
wget https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_heavy/float16/1/pose_landmarker_heavy.task
```

---

## ⚙️ إعدادات البناء (اختياري)

### تقليل حجم APK:

في `android/app/build.gradle`:

```gradle
android {
    buildTypes {
        release {
            // تفعيل الضغط
            shrinkResources true
            minifyEnabled true
            
            // ProGuard rules
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### تخصيص اسم التطبيق:

في `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="Qeyafa"  ← غيّر هنا
    ...
```

---

## 🐛 حل المشاكل الشائعة

### مشكلة: "Execution failed for task ':app:mergeReleaseResources'"

**الحل:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### مشكلة: "Android license status unknown"

**الحل:**
```bash
flutter doctor --android-licenses
# اقبل جميع التراخيص
```

### مشكلة: "Minimum supported Gradle version is X.X"

**الحل:** حدّث `android/gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip
```

### مشكلة: APK كبير جداً

**الحل:**
```bash
# استخدم split-per-abi
flutter build apk --split-per-abi --release

# أو استخدم App Bundle (للنشر على Play Store)
flutter build appbundle --release
```

---

## 📊 اختبار APK قبل التوزيع

### 1. اختبار الأداء:

```bash
# قياس FPS
adb shell dumpsys gfxinfo com.qeyafa.mobile

# مراقبة الذاكرة
adb shell dumpsys meminfo com.qeyafa.mobile
```

### 2. اختبار الصلاحيات:

- ✅ إذن الكاميرا
- ✅ إذن التخزين (إذا كان مطلوباً)

### 3. اختبار الوظائف:

- ✅ تهيئة MediaPipe
- ✅ كشف الوضعية (33 نقطة)
- ✅ العد التنازلي (3, 2, 1)
- ✅ الالتقاط التلقائي
- ✅ حفظ الصورة

---

## 🌐 بناء App Bundle (للنشر)

```bash
# بناء Android App Bundle (للنشر على Google Play)
flutter build appbundle --release

# الملف سيكون في:
# build/app/outputs/bundle/release/app-release.aab
```

**مميزات App Bundle:**
- ✅ حجم تحميل أصغر (Google Play يختار المعمارية المناسبة)
- ✅ تحديثات تلقائية
- ✅ دعم Dynamic Delivery

---

## 📝 قائمة المراجعة النهائية

قبل توزيع APK، تأكد من:

- [ ] ✅ تم اختبار التطبيق على جهاز فعلي
- [ ] ✅ جميع الصلاحيات تعمل
- [ ] ✅ MediaPipe يكتشف الوضعية بنجاح
- [ ] ✅ الالتقاط التلقائي يعمل
- [ ] ✅ لا توجد أخطاء في Logcat
- [ ] ✅ الأداء جيد (>15 FPS)
- [ ] ✅ استهلاك البطارية معقول
- [ ] ✅ التطبيق يعمل على أجهزة مختلفة

---

## 🎯 الأوامر السريعة

```bash
# بناء سريع للتجربة
flutter build apk --debug

# بناء محسّن للتوزيع
flutter build apk --release --split-per-abi

# تثبيت مباشر على الجهاز
flutter install

# مشاهدة السجلات
flutter logs

# فحص شامل
flutter doctor -v
```

---

## 📱 الأجهزة المدعومة

- ✅ **Android 7.0** (API 24) فأحدث
- ✅ **معمارية:** ARM64, ARMv7, x86_64
- ✅ **الذاكرة:** 2 GB RAM على الأقل (موصى به 4 GB)
- ✅ **الكاميرا:** كاميرا خلفية مطلوبة
- ✅ **المعالج:** يفضل معالج مع GPU للأداء الأفضل

---

## 🔗 روابط مفيدة

- [Flutter Build APK](https://docs.flutter.dev/deployment/android#build-an-apk)
- [Android App Bundle](https://developer.android.com/guide/app-bundle)
- [MediaPipe Pose](https://developers.google.com/mediapipe/solutions/vision/pose_landmarker)
- [Qeyafa Repository](https://github.com/OsmanMohamad249/Qeyafa)

---

**آخر تحديث:** نوفمبر 21, 2025  
**الإصدار:** 1.0.0-beta  
**الحالة:** ✅ جاهز للبناء والاختبار
