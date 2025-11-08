"""
User endpoints.
"""

from fastapi import APIRouter, Depends

from core.deps import get_current_user
from models.user import User
from schemas.user import UserResponse

router = APIRouter()


@router.get("/me", response_model=UserResponse)
def get_current_user_info(current_user: User = Depends(get_current_user)):
    """
    Get current user information.
    """
    return current_user
