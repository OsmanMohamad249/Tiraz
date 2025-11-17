"""Merge multiple heads

Revision ID: 20251117_merge_heads
Revises: 20251115_merge_575410277ca3_and_20251115_add_templates_and_assets, 20251116_templates_assets
Create Date: 2025-11-17 00:00:00.000000

This is a merge migration to unify the two heads created by parallel development.
"""
from alembic import op


# revision identifiers, used by Alembic.
revision = "20251117_merge_heads"
down_revision = (
    "20251115_merge_575410277ca3_and_20251115_add_templates_and_assets",
    "20251116_templates_assets"
)
branch_labels = None
depends_on = None


def upgrade() -> None:
    """Merge migration: no schema changes required.
    
    This migration intentionally does not alter the database schema.
    It only records a merge of two revision heads so that `alembic`
    considers the migration graph linear for `upgrade head`.
    """
    pass


def downgrade() -> None:
    """Downgrade from a merge is non-trivial and not implemented.
    
    If you need to revert this merge, handle the branches manually.
    """
    pass
