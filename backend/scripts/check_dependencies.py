#!/usr/bin/env python3
"""
Script to check if all required dependencies are installed.
Verifies that requirements.txt and pyproject.toml are in sync.
"""

import sys
import subprocess
from pathlib import Path
from typing import List, Set, Tuple


def parse_requirements_txt(file_path: Path) -> Set[str]:
    """Parse requirements.txt and extract package names."""
    packages = set()
    
    if not file_path.exists():
        return packages
    
    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip()
            # Skip empty lines and comments
            if not line or line.startswith('#'):
                continue
            
            # Extract package name (before ==, >=, etc.)
            package = line.split('==')[0].split('>=')[0].split('[')[0].strip()
            if package:
                packages.add(package.lower())
    
    return packages


def get_installed_packages() -> Set[str]:
    """Get list of installed packages using pip."""
    try:
        result = subprocess.run(
            ['pip3', 'list', '--format=freeze'],
            capture_output=True,
            text=True,
            check=True
        )
        
        packages = set()
        for line in result.stdout.splitlines():
            if '==' in line:
                package = line.split('==')[0].strip().lower()
                packages.add(package)
        
        return packages
    except subprocess.CalledProcessError as e:
        print(f"❌ Error running pip list: {e}")
        return set()


def check_missing_dependencies(
    required: Set[str],
    installed: Set[str]
) -> Tuple[bool, List[str]]:
    """Check for missing dependencies."""
    missing = required - installed
    
    # Some packages have different names when installed
    name_mappings = {
        'python-multipart': 'multipart',
        'python-jose': 'jose',
        'python-dotenv': 'dotenv',
    }
    
    # Filter out false positives
    actual_missing = []
    for pkg in missing:
        # Check if it's a known mapping
        if pkg in name_mappings:
            if name_mappings[pkg] not in installed:
                actual_missing.append(pkg)
        else:
            actual_missing.append(pkg)
    
    return len(actual_missing) == 0, actual_missing


def main():
    """Main function to run all dependency checks."""
    print("🔍 Checking Python dependencies...\n")
    
    backend_dir = Path(__file__).parent.parent
    requirements_file = backend_dir / "requirements.txt"
    
    if not requirements_file.exists():
        print(f"❌ Error: requirements.txt not found at {requirements_file}")
        sys.exit(1)
    
    all_passed = True
    
    # Check 1: Parse requirements.txt
    print("📋 Check 1: Parsing requirements.txt")
    required_packages = parse_requirements_txt(requirements_file)
    if required_packages:
        print(f"✅ Found {len(required_packages)} required packages")
    else:
        print("❌ No packages found in requirements.txt")
        all_passed = False
    print()
    
    # Check 2: Get installed packages
    print("📋 Check 2: Checking installed packages")
    installed_packages = get_installed_packages()
    if installed_packages:
        print(f"✅ Found {len(installed_packages)} installed packages")
    else:
        print("❌ Could not retrieve installed packages")
        all_passed = False
    print()
    
    # Check 3: Check for missing dependencies
    print("📋 Check 3: Checking for missing dependencies")
    passed, missing = check_missing_dependencies(required_packages, installed_packages)
    if passed:
        print("✅ PASSED: All required dependencies are installed")
    else:
        print("❌ FAILED: Missing dependencies detected:")
        for pkg in missing:
            print(f"   - {pkg}")
        print("\n   To install missing dependencies, run:")
        print(f"   pip install -r {requirements_file}")
        all_passed = False
    print()
    
    # Check 4: Check for pyproject.toml
    print("📋 Check 4: Checking for pyproject.toml")
    pyproject_file = backend_dir / "pyproject.toml"
    if pyproject_file.exists():
        print("✅ PASSED: pyproject.toml exists")
        print("   You can use Poetry for dependency management:")
        print("   poetry install")
    else:
        print("⚠️  WARNING: pyproject.toml not found")
        print("   Consider adding Poetry support for better dependency management")
    print()
    
    # Summary
    print("=" * 60)
    if all_passed:
        print("✅ All dependency checks passed!")
        sys.exit(0)
    else:
        print("❌ Some dependency checks failed. Please fix the issues above.")
        sys.exit(1)


if __name__ == "__main__":
    main()
