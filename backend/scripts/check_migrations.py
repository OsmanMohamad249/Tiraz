#!/usr/bin/env python3
"""
Script to check Alembic migration chain integrity.
Ensures there are no multiple heads or broken migration chains.
"""

import sys
import os
from pathlib import Path
from typing import List, Dict, Set, Tuple

# Add backend to path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

from alembic.config import Config
from alembic.script import ScriptDirectory


def get_migration_heads(script_dir: ScriptDirectory) -> List[str]:
    """Get all current heads in the migration chain."""
    return list(script_dir.get_heads())


def check_multiple_heads(script_dir: ScriptDirectory) -> Tuple[bool, List[str]]:
    """Check if there are multiple heads in the migration chain."""
    heads = get_migration_heads(script_dir)
    if len(heads) > 1:
        return False, heads
    return True, heads


def check_migration_chain(script_dir: ScriptDirectory) -> Tuple[bool, List[str]]:
    """Check for broken migration chains."""
    errors = []
    
    # Get all revisions
    revisions = {}
    for revision in script_dir.walk_revisions():
        revisions[revision.revision] = revision
    
    # Check each revision
    for rev_id, revision in revisions.items():
        # Check down_revision exists
        if revision.down_revision:
            if isinstance(revision.down_revision, tuple):
                # Multiple down revisions (merge)
                for down_rev in revision.down_revision:
                    if down_rev and down_rev not in revisions:
                        errors.append(
                            f"❌ Revision {rev_id} references non-existent "
                            f"down_revision: {down_rev}"
                        )
            else:
                # Single down revision
                if revision.down_revision not in revisions:
                    errors.append(
                        f"❌ Revision {rev_id} references non-existent "
                        f"down_revision: {revision.down_revision}"
                    )
    
    return len(errors) == 0, errors


def check_duplicate_revisions(script_dir: ScriptDirectory) -> Tuple[bool, List[str]]:
    """Check for duplicate revision IDs."""
    seen_revisions = set()
    duplicates = []
    
    for revision in script_dir.walk_revisions():
        if revision.revision in seen_revisions:
            duplicates.append(f"❌ Duplicate revision ID: {revision.revision}")
        seen_revisions.add(revision.revision)
    
    return len(duplicates) == 0, duplicates


def main():
    """Main function to run all migration checks."""
    print("🔍 Checking Alembic migration chain integrity...\n")
    
    # Get Alembic config
    alembic_ini = backend_dir / "alembic.ini"
    if not alembic_ini.exists():
        print(f"❌ Error: alembic.ini not found at {alembic_ini}")
        sys.exit(1)
    
    config = Config(str(alembic_ini))
    script_dir = ScriptDirectory.from_config(config)
    
    all_passed = True
    
    # Check 1: Multiple heads
    print("📋 Check 1: Multiple heads")
    passed, heads = check_multiple_heads(script_dir)
    if passed:
        print(f"✅ PASSED: Single head found: {heads[0]}")
    else:
        print(f"❌ FAILED: Multiple heads found: {', '.join(heads)}")
        print("   This usually happens when multiple migrations have the same down_revision.")
        print("   You need to create a merge migration or fix the down_revision values.")
        all_passed = False
    print()
    
    # Check 2: Migration chain integrity
    print("📋 Check 2: Migration chain integrity")
    passed, errors = check_migration_chain(script_dir)
    if passed:
        print("✅ PASSED: All migrations reference valid down_revisions")
    else:
        print("❌ FAILED: Broken migration chain detected:")
        for error in errors:
            print(f"   {error}")
        all_passed = False
    print()
    
    # Check 3: Duplicate revisions
    print("📋 Check 3: Duplicate revision IDs")
    passed, duplicates = check_duplicate_revisions(script_dir)
    if passed:
        print("✅ PASSED: No duplicate revision IDs found")
    else:
        print("❌ FAILED: Duplicate revision IDs detected:")
        for duplicate in duplicates:
            print(f"   {duplicate}")
        all_passed = False
    print()
    
    # Summary
    print("=" * 60)
    if all_passed:
        print("✅ All migration checks passed!")
        sys.exit(0)
    else:
        print("❌ Some migration checks failed. Please fix the issues above.")
        sys.exit(1)


if __name__ == "__main__":
    main()
