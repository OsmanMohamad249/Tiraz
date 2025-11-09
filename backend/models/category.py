"""
Category model.
"""

import uuid

from sqlalchemy import Column, String
from sqlalchemy.dialects.postgresql import UUID

from core.database import Base


class Category(Base):
    """Category model for garment types."""

    __tablename__ = "categories"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, unique=True, nullable=False, index=True)
    description = Column(String, nullable=True)

    def __repr__(self):
        return f"<Category(id={self.id}, name={self.name})>"
