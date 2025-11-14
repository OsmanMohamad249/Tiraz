"""
Dependencies for authentication.
"""

from typing import List, Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from core.database import get_db
from core.security import verify_access_token
from models.user import User
from models.roles import UserRole

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def get_current_user(
    token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)
) -> User:
    """
    Get the current authenticated user from the token.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    payload = verify_access_token(token)
    if payload is None:
        raise credentials_exception

    email: Optional[str] = payload.get("sub")
    if email is None:
        raise credentials_exception

    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="User is not active"
        )

    return user


class RoleChecker:
    """
    Reusable role-based access control checker.

    This class provides a flexible way to check if a user has one of the allowed roles.
    Superusers are automatically granted access regardless of their role.

    Example usage:
        is_admin = RoleChecker([UserRole.ADMIN])
        is_designer_or_admin = RoleChecker([UserRole.DESIGNER, UserRole.ADMIN])
    """

    def __init__(self, allowed_roles: List[UserRole]):
        """
        Initialize the role checker with allowed roles.

        Args:
            allowed_roles: List of UserRole enums that are allowed access
        """
        self.allowed_roles = allowed_roles

    def __call__(self, current_user: User = Depends(get_current_user)) -> User:
        """
        Check if the current user has one of the allowed roles.

        Args:
            current_user: The authenticated user

        Returns:
            The user if they have an allowed role

        Raises:
            HTTPException: 403 if user doesn't have required role
        """
        # Superusers have access to everything
        if current_user.is_superuser:
            return current_user

        if current_user.role not in self.allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="Operation not permitted"
            )
        return current_user


# Role guard instances for common use cases
is_admin = RoleChecker([UserRole.ADMIN])
is_designer = RoleChecker([UserRole.DESIGNER])
is_tailor = RoleChecker([UserRole.TAILOR])
is_customer = RoleChecker([UserRole.CUSTOMER])
is_designer_or_admin = RoleChecker([UserRole.DESIGNER, UserRole.ADMIN])
is_tailor_or_admin = RoleChecker([UserRole.TAILOR, UserRole.ADMIN])


# Legacy compatibility functions - kept for backward compatibility
def get_current_admin_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """
    Dependency to check if the current user is a superuser (admin).

    Note: This is kept for backward compatibility. Consider using is_admin instead.
    """
    if not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="The user does not have administrative privileges",
        )
    return current_user


def get_current_designer_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """
    Dependency to check if the current user is a designer.

    Note: This is kept for backward compatibility. Consider using is_designer instead.
    """
    if current_user.role != UserRole.DESIGNER and not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="The user is not a designer",
        )
    return current_user


def get_current_tailor_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """
    Dependency to check if the current user is a tailor.

    Note: This is kept for backward compatibility. Consider using is_tailor instead.
    """
    if current_user.role != UserRole.TAILOR and not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="The user is not a tailor",
        )
    return current_user
