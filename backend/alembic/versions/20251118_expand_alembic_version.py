"""expand alembic_version.version_num to 168 characters

Revision ID: 20251118_expand_alembic_version
Revises: 20251117_merge_heads
Create Date: 2025-11-18 00:00:00.000000
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '20251118_expand_alembic_version'
down_revision = '20251117_merge_heads'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.alter_column(
        'alembic_version', 'version_num', existing_type=sa.String(length=32), type_=sa.String(length=168), existing_nullable=False,
    )


def downgrade() -> None:
    op.alter_column(
        'alembic_version', 'version_num', existing_type=sa.String(length=168), type_=sa.String(length=32), existing_nullable=False,
    )
