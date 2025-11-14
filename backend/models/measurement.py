"""
Measurement model.
"""

import uuid

from sqlalchemy import Column, DateTime, Float, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func

from core.database import Base


class Measurement(Base):
    """Measurement model for storing AI-processed body measurements."""

    __tablename__ = "measurements"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    measurements = Column(JSONB, nullable=False)
    image_paths = Column(JSONB, nullable=False)
    processed_at = Column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    confidence_score = Column(Float, nullable=False)

    def __repr__(self):
        return f"<Measurement(id={self.id}, user_id={self.user_id})>"
