"""
Measurements endpoints for photo upload and processing.
"""

import os
import uuid
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session
import aiofiles

from core.database import get_db
from core.deps import get_current_user
from models.user import User
from models.measurement import Measurement
from schemas.measurement import (
    MeasurementProcessResponse,
    MeasurementUploadResponse,
    MeasurementCreate,
    MeasurementUpdate,
    MeasurementResponse,
)
from crud import measurement as measurement_crud
from services.ai_client import ai_client, AIServiceError

router = APIRouter()

# Configuration
# Use workspace-local uploads directory by default so tests can write files.
UPLOAD_DIR = os.getenv("UPLOAD_DIR", "/workspaces/Qeyafa/backend/uploads")
ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png"}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB


def allowed_file(filename: str) -> bool:
    """Check if file extension is allowed."""
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


def validate_file(file: UploadFile) -> None:
    """Validate uploaded file."""
    if not file.filename:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No filename provided",
        )

    if not allowed_file(file.filename):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File type not allowed. Allowed types: {', '.join(ALLOWED_EXTENSIONS)}",
        )


async def save_upload_file(file: UploadFile, user_id: uuid.UUID) -> str:
    """
    Save uploaded file to disk.

    Args:
        file: The uploaded file
        user_id: ID of the user uploading the file

    Returns:
        Relative path to the saved file
    """
    # Create user-specific directory
    user_dir = os.path.join(UPLOAD_DIR, str(user_id))
    os.makedirs(user_dir, exist_ok=True)

    # Generate unique filename
    file_ext = file.filename.rsplit(".", 1)[1].lower()
    unique_filename = f"{uuid.uuid4()}.{file_ext}"
    file_path = os.path.join(user_dir, unique_filename)

    # Save file using aiofiles to prevent blocking
    contents = await file.read()
    async with aiofiles.open(file_path, "wb") as f:
        await f.write(contents)

    # Reset file pointer for potential reuse
    await file.seek(0)

    return f"{user_id}/{unique_filename}"


# CRUD endpoints for manual measurements


@router.post("/", response_model=MeasurementResponse, status_code=status.HTTP_201_CREATED)
def create_measurement_endpoint(
    payload: MeasurementCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create a manual measurement record for the authenticated user."""
    db_measurement = measurement_crud.create_measurement(db, current_user.id, payload)
    return db_measurement


@router.get("/", response_model=list[MeasurementResponse])
def list_measurements_for_user(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """List measurements belonging to the authenticated user."""
    measurements = measurement_crud.get_measurements_for_user(db, current_user.id, skip, limit)
    return measurements


@router.get("/{measurement_id}", response_model=MeasurementResponse)
def get_measurement_endpoint(
    measurement_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get a specific measurement; ensure ownership."""
    measurement = measurement_crud.get_measurement(db, measurement_id)
    if measurement is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Measurement not found")
    if measurement.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to access this measurement")
    return measurement


@router.put("/{measurement_id}", response_model=MeasurementResponse)
def update_measurement_endpoint(
    measurement_id: uuid.UUID,
    payload: MeasurementUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update a measurement (only owner)."""
    measurement = measurement_crud.get_measurement(db, measurement_id)
    if measurement is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Measurement not found")
    if measurement.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to update this measurement")

    updated = measurement_crud.update_measurement(db, measurement_id, payload)
    return updated


@router.delete("/{measurement_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_measurement_endpoint(
    measurement_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Delete a measurement (only owner)."""
    measurement = measurement_crud.get_measurement(db, measurement_id)
    if measurement is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Measurement not found")
    if measurement.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to delete this measurement")

    success = measurement_crud.delete_measurement(db, measurement_id)
    if not success:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to delete measurement")


@router.post("/upload-image", response_model=MeasurementUploadResponse)
async def upload_single_image(
    file: UploadFile = File(...), current_user: User = Depends(get_current_user)
):
    """Upload a single image for later association with a measurement."""
    validate_file(file)
    try:
        path = await save_upload_file(file, current_user.id)
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Failed to save file: {str(e)}")

    return MeasurementUploadResponse(message="Image uploaded successfully", image_paths={"image": path})


@router.post("/upload", response_model=MeasurementUploadResponse)
async def upload_photos(
    photo_front: UploadFile = File(...),
    photo_back: UploadFile = File(...),
    photo_left: UploadFile = File(...),
    photo_right: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
):
    """
    Upload 4 photos for measurement processing.

    Args:
        photo_front: Front view photo
        photo_back: Back view photo
        photo_left: Left side photo
        photo_right: Right side photo
        current_user: Authenticated user

    Returns:
        Confirmation with saved file paths
    """
    photos = {
        "front": photo_front,
        "back": photo_back,
        "left": photo_left,
        "right": photo_right,
    }

    # Validate all files
    for name, photo in photos.items():
        validate_file(photo)

    # Save all files
    saved_paths = {}
    try:
        for name, photo in photos.items():
            path = await save_upload_file(photo, current_user.id)
            saved_paths[name] = path
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save files: {str(e)}",
        )

    return MeasurementUploadResponse(
        message="Photos uploaded successfully",
        image_paths=saved_paths,
    )


@router.post("/process", response_model=MeasurementProcessResponse)
async def process_measurements(
    photo_front: UploadFile = File(...),
    photo_back: UploadFile = File(...),
    photo_left: UploadFile = File(...),
    photo_right: UploadFile = File(...),
    height: float = Form(..., gt=0),
    weight: float = Form(..., gt=0),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Process measurements from uploaded photos.

    Args:
        photo_front: Front view photo
        photo_back: Back view photo
        photo_left: Left side photo
        photo_right: Right side photo
        height: User height in cm
        weight: User weight in kg
        current_user: Authenticated user
        db: Database session

    Returns:
        Processed measurement results
    """
    photos = {
        "front": photo_front,
        "back": photo_back,
        "left": photo_left,
        "right": photo_right,
    }

    # Validate all files
    for name, photo in photos.items():
        validate_file(photo)

    try:
        # Save photos
        saved_paths = {}
        for name, photo in photos.items():
            path = await save_upload_file(photo, current_user.id)
            saved_paths[name] = path

        # Call AI service
        try:
            ai_result = await ai_client.process_measurements(
                photo_front=photo_front,
                photo_back=photo_back,
                photo_left=photo_left,
                photo_right=photo_right,
                height=height,
                weight=weight,
            )
        except AIServiceError as e:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail=f"AI service error: {str(e)}",
            )

        # Extract results from AI service response
        if ai_result.get("status") != "success":
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="AI service returned unsuccessful status",
            )

        ai_data = ai_result.get("data", {})
        measurements_dict = ai_data.get("measurements", {})
        confidence = ai_data.get("confidence", 0.0)

        # Create measurement record
        measurement = Measurement(
            user_id=current_user.id,
            measurements=measurements_dict,
            image_paths=saved_paths,
            confidence_score=confidence,
        )

        db.add(measurement)
        db.commit()
        db.refresh(measurement)

        return MeasurementProcessResponse(
            id=measurement.id,
            user_id=measurement.user_id,
            measurements=measurements_dict,
            confidence_score=measurement.confidence_score,
            processed_at=measurement.processed_at,
        )

    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process measurements: {str(e)}",
        )
