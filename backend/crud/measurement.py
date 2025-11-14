"""
CRUD operations for Measurement model.
"""

from typing import List, Optional
from uuid import UUID
from sqlalchemy.orm import Session

from models.measurement import Measurement
from schemas.measurement import MeasurementCreate, MeasurementUpdate


def get_measurement(db: Session, measurement_id: UUID) -> Optional[Measurement]:
    """Get a single measurement by ID."""
    return db.query(Measurement).filter(Measurement.id == measurement_id).first()


def get_measurements_for_user(
    db: Session, user_id: UUID, skip: int = 0, limit: int = 100
) -> List[Measurement]:
    """Get measurements for a specific user."""
    return (
        db.query(Measurement)
        .filter(Measurement.user_id == user_id)
        .order_by(Measurement.processed_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )


def create_measurement(
    db: Session,
    user_id: UUID,
    measurement_in: MeasurementCreate,
) -> Measurement:
    """Create a new measurement record."""
    data = measurement_in.dict(exclude_unset=True)
    db_measurement = Measurement(
        user_id=user_id,
        measurements=data.get("measurements", {}),
        image_paths=data.get("image_paths", {}),
        confidence_score=data.get("confidence_score", 0.0),
    )
    db.add(db_measurement)
    db.commit()
    db.refresh(db_measurement)
    return db_measurement


def update_measurement(
    db: Session, measurement_id: UUID, measurement_in: MeasurementUpdate
) -> Optional[Measurement]:
    """Update an existing measurement record."""
    db_measurement = get_measurement(db, measurement_id)
    if db_measurement is None:
        return None

    update_data = measurement_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_measurement, field, value)

    db.commit()
    db.refresh(db_measurement)
    return db_measurement


def delete_measurement(db: Session, measurement_id: UUID) -> bool:
    """Delete a measurement record."""
    db_measurement = get_measurement(db, measurement_id)
    if db_measurement is None:
        return False
    db.delete(db_measurement)
    db.commit()
    return True
