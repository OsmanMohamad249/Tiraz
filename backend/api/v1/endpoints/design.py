"""
Design endpoints for browsing categories, fabrics, and saving designs.
"""

import uuid
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from core.database import get_db
from core.deps import get_current_user
from models.user import User
from models.category import Category
from models.fabric import Fabric
from models.design import Design
import schemas

router = APIRouter()


@router.get("/categories", response_model=List[schemas.Category])
async def get_categories(db: Session = Depends(get_db)):
    """
    Get all garment categories.

    Returns:
        List of all categories
    """
    categories = db.query(Category).all()
    return categories


@router.get("/fabrics/{category_id}", response_model=List[schemas.Fabric])
async def get_fabrics_by_category(
    category_id: uuid.UUID, db: Session = Depends(get_db)
):
    """
    Get all fabrics for a specific category.

    Args:
        category_id: UUID of the category

    Returns:
        List of fabrics matching the category
    """
    fabrics = db.query(Fabric).filter(Fabric.category_id == category_id).all()
    return fabrics


@router.post("/save", response_model=schemas.Design, status_code=status.HTTP_201_CREATED)
async def save_design(
    design_in: schemas.DesignCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Save a customized design (Protected - requires authentication).

    Args:
        design_in: Design data to save
        db: Database session
        current_user: Authenticated user

    Returns:
        The created design
    """
    # Create new design
    new_design = Design(
        name=design_in.name,
        user_id=current_user.id,
        category_id=design_in.category_id,
        fabric_id=design_in.fabric_id,
        customization=design_in.customization,
    )

    db.add(new_design)
    db.commit()
    db.refresh(new_design)

    return new_design
