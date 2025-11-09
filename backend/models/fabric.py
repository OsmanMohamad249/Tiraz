"""
Fabric model.
"""

import uuid

from sqlalchemy import Column, String, Float, ForeignKey
from sqlalchemy.dialects.postgresql import UUID

from core.database import Base


class Fabric(Base):
    """Fabric model for fabric options."""

    __tablename__ = "fabrics"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False, index=True)
    description = Column(String, nullable=True)
    image_url = Column(String, nullable=True)
    price_per_meter = Column(Float, nullable=True)
    category_id = Column(UUID(as_uuid=True), ForeignKey("categories.id"), nullable=False)

    def __repr__(self):
        return f"<Fabric(id={self.id}, name={self.name})>"
