#!/bin/bash
# Script to automatically fix Dart code issues using dart fix

set -e

echo "🔧 Running Dart Fix..."
echo ""

# Navigate to mobile-app directory
cd "$(dirname "$0")/.."

# Run dart fix with dry-run first to see what will be changed
echo "📋 Step 1: Checking what can be fixed (dry-run)..."
flutter pub get
dart fix --dry-run

echo ""
echo "📝 Step 2: Applying automatic fixes..."
dart fix --apply

echo ""
echo "✅ Dart fix completed!"
echo ""
echo "Next steps:"
echo "1. Review the changes made by dart fix"
echo "2. Run 'flutter analyze' to check for remaining issues"
echo "3. Run 'flutter test' to ensure tests still pass"
