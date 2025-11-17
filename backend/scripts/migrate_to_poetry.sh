#!/bin/bash
#
# Migrate from requirements.txt to Poetry
# This script helps transition the project to use Poetry for dependency management
#

set -euo pipefail

cd "$(dirname "$0")/.."

echo "🔍 Checking if Poetry is installed..."
if ! command -v poetry &> /dev/null; then
    echo "❌ Poetry is not installed!"
    echo ""
    echo "To install Poetry, run:"
    echo "  curl -sSL https://install.python-poetry.org | python3 -"
    echo ""
    echo "Then add Poetry to PATH:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    exit 1
fi

echo "✅ Poetry is installed: $(poetry --version)"
echo ""

echo "📋 Current pyproject.toml status:"
if [ -f "pyproject.toml" ]; then
    echo "✅ pyproject.toml exists"
else
    echo "❌ pyproject.toml not found!"
    exit 1
fi

echo ""
echo "🔧 Installing dependencies with Poetry..."
poetry install

echo ""
echo "🔒 Generating poetry.lock..."
poetry lock

echo ""
echo "✅ Poetry migration complete!"
echo ""
echo "Next steps:"
echo "1. Test that everything works:"
echo "   poetry run pytest"
echo "   poetry run python -m alembic upgrade head"
echo ""
echo "2. Update your development workflow:"
echo "   - Use 'poetry add <package>' instead of 'pip install <package>'"
echo "   - Use 'poetry run <command>' to run commands in the Poetry environment"
echo "   - Use 'poetry shell' to activate the virtual environment"
echo ""
echo "3. Update CI/CD:"
echo "   - Replace 'pip install -r requirements.txt' with 'poetry install'"
echo ""
echo "4. (Optional) Remove requirements.txt after confirming everything works:"
echo "   git rm backend/requirements.txt"
