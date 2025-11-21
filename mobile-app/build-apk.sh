#!/bin/bash

# Qeyafa APK Build Script
# بناء تطبيق Qeyafa APK

set -e

echo "🚀 بدء بناء Qeyafa APK..."
echo "================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter غير مثبت!${NC}"
    echo "قم بتثبيت Flutter من: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${GREEN}✅ Flutter متوفر${NC}"

# Check Android SDK
if ! flutter doctor | grep -q "Android toolchain.*✓"; then
    echo -e "${YELLOW}⚠️ Android SDK غير متوفر بالكامل${NC}"
    echo "قم بتثبيت Android Studio وإعداد SDK"
    flutter doctor
    exit 1
fi

echo -e "${GREEN}✅ Android SDK متوفر${NC}"

# Clean previous build
echo ""
echo "🧹 تنظيف البناء السابق..."
flutter clean

# Get dependencies
echo ""
echo "📦 تحميل dependencies..."
flutter pub get

# Check model file
MODEL_FILE="assets/models/pose_landmarker_heavy.task"
if [ ! -f "$MODEL_FILE" ]; then
    echo -e "${RED}❌ ملف النموذج غير موجود!${NC}"
    echo "تحميل ملف النموذج..."
    mkdir -p assets/models
    wget -O "$MODEL_FILE" \
        "https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_heavy/float16/1/pose_landmarker_heavy.task"
fi

MODEL_SIZE=$(du -h "$MODEL_FILE" | cut -f1)
echo -e "${GREEN}✅ ملف النموذج موجود (${MODEL_SIZE})${NC}"

# Build type selection
echo ""
echo "اختر نوع البناء:"
echo "1) Debug APK (سريع، للتجربة)"
echo "2) Release APK (محسّن، للتوزيع)"
echo "3) Release APK Split (محسّن، حجم أصغر)"
echo "4) App Bundle (للنشر على Google Play)"
read -p "اختيارك [1-4]: " choice

case $choice in
    1)
        echo ""
        echo "🔨 بناء Debug APK..."
        flutter build apk --debug
        OUTPUT="build/app/outputs/flutter-apk/app-debug.apk"
        ;;
    2)
        echo ""
        echo "🔨 بناء Release APK..."
        flutter build apk --release
        OUTPUT="build/app/outputs/flutter-apk/app-release.apk"
        ;;
    3)
        echo ""
        echo "🔨 بناء Release APK (Split per ABI)..."
        flutter build apk --release --split-per-abi
        OUTPUT="build/app/outputs/flutter-apk/"
        ;;
    4)
        echo ""
        echo "🔨 بناء App Bundle..."
        flutter build appbundle --release
        OUTPUT="build/app/outputs/bundle/release/app-release.aab"
        ;;
    *)
        echo -e "${RED}❌ اختيار غير صحيح!${NC}"
        exit 1
        ;;
esac

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}✅ تم البناء بنجاح!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    
    if [ -d "$OUTPUT" ]; then
        echo "📦 ملفات APK:"
        ls -lh "$OUTPUT"*.apk 2>/dev/null || ls -lh "$OUTPUT"*.aab 2>/dev/null
    else
        echo "📦 الملف: $OUTPUT"
        ls -lh "$OUTPUT"
    fi
    
    echo ""
    echo "📱 لتثبيت على الجهاز:"
    echo "   adb install $OUTPUT"
    echo ""
    echo "أو"
    echo "   flutter install"
    
else
    echo -e "${RED}❌ فشل البناء!${NC}"
    exit 1
fi
