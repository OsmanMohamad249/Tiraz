"""
Design model.
"""

import uuid

from sqlalchemy import Column, String, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB

from core.database import Base


class Design(Base):
    """Design model for storing customized garment designs."""

    __tablename__ = "designs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    category_id = Column(UUID(as_uuid=True), ForeignKey("categories.id"), nullable=False)
    fabric_id = Column(UUID(as_uuid=True), ForeignKey("fabrics.id"), nullable=False)
    customization = Column(JSONB, nullable=False)

    def __repr__(self):
        return f"<Design(id={self.id}, name={self.name}, user_id={self.user_id})>"
