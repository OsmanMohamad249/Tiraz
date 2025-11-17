#!/bin/bash
#
# Setup pre-commit hooks
# This script installs and configures pre-commit hooks for the project
#

set -euo pipefail

cd "$(dirname "$0")/.."

echo "🔍 Checking if pre-commit is installed..."
if ! command -v pre-commit &> /dev/null; then
    echo "⚙️ Installing pre-commit..."
    pip3 install pre-commit
else
    echo "✅ pre-commit is already installed: $(pre-commit --version)"
fi

echo ""
echo "📋 Installing pre-commit hooks..."
pre-commit install

echo ""
echo "🧪 Running pre-commit on all files (this may take a while)..."
pre-commit run --all-files || {
    echo ""
    echo "⚠️ Some hooks failed on the first run."
    echo "This is normal - the hooks may have auto-fixed some issues."
    echo "Review the changes and commit them if they look good."
    echo ""
    echo "To run pre-commit again:"
    echo "  pre-commit run --all-files"
}

echo ""
echo "✅ Pre-commit hooks setup complete!"
echo ""
echo "Usage:"
echo "  - Hooks will run automatically on 'git commit'"
echo "  - To run manually: pre-commit run --all-files"
echo "  - To skip hooks: git commit --no-verify"
echo "  - To update hooks: pre-commit autoupdate"
echo ""
echo "Configured hooks:"
echo "  ✓ Black (Python code formatting)"
echo "  ✓ isort (Python import sorting)"
echo "  ✓ Flake8 (Python linting)"
echo "  ✓ General file checks (trailing whitespace, YAML, JSON, etc.)"
echo "  ✓ Migration chain integrity check"
echo "  ✓ Python dependencies check"
echo "  ✓ Flutter analyze"
