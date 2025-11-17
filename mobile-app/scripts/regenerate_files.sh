#!/bin/bash
#
# Regenerate Flutter generated files
# This script rebuilds all generated files (*.g.dart, *.freezed.dart, etc.)
#

set -euo pipefail

cd "$(dirname "$0")/.."

echo "🧹 Cleaning old generated files..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Deleting old generated files..."
find lib -name "*.g.dart" -delete
find lib -name "*.freezed.dart" -delete
find lib -name "*.gr.dart" -delete
find lib -name "*.config.dart" -delete

echo "⚙️ Running build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "✅ All generated files have been regenerated!"
echo ""
echo "Next steps:"
echo "1. Review the changes with: git diff"
echo "2. If everything looks good, commit: git add . && git commit -m 'chore: regenerate Flutter files'"
echo "3. Push to remote: git push"
