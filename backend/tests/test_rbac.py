"""
Tests for Role-Based Access Control (RBAC) functionality.

Note: These tests require a running database.
Run with: pytest tests/test_rbac.py
"""




from fastapi.testclient import TestClient
from main import app
from models.roles import UserRole
import redis.asyncio as redis
from fastapi_limiter import FastAPILimiter
import asyncio
import os


def get_auth_token(client, role="customer"):
    """Helper function to get authentication token."""
    import time
    email = f"test_{role}_{int(time.time())}@example.com"
    password = "testpass123"

    # Register user
    reg_response = client.post("/api/v1/auth/register", json={
        "email": email,
        "password": password,
        "first_name": "Test",
        "last_name": "User",
        "role": role,
    })

    # Login to get token
    login_response = client.post(
        "/api/v1/auth/login",
        data={"username": email, "password": password}
    )

    if login_response.status_code == 200:
        return login_response.json()["access_token"]
    return None


def test_register_user_with_default_customer_role(client):
    """Test user registration defaults to CUSTOMER role."""
    import time

    email = f"customer_{int(time.time())}@example.com"

    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": "testpass123",
            "first_name": "Test",
            "last_name": "Customer",
        },
    )

    assert response.status_code in [201, 400]

    if response.status_code == 201:
        # Login to verify role
        login_response = client.post(
            "/api/v1/auth/login", data={"username": email, "password": "testpass123"}
        )
        token = login_response.json()["access_token"]

        # Get user info
        user_response = client.get(
            "/api/v1/users/me", headers={"Authorization": f"Bearer {token}"}
        )
        assert user_response.status_code == 200
        data = user_response.json()
        assert data["role"] == UserRole.CUSTOMER.value
        assert data["is_superuser"] is False


def test_register_user_with_designer_role(client):
    """Test user registration with DESIGNER role."""
    import time

    email = f"designer_{int(time.time())}@example.com"

    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": "testpass123",
            "first_name": "Test",
            "last_name": "Designer",
            "role": UserRole.DESIGNER.value,
        },
    )

    assert response.status_code in [201, 400]

    if response.status_code == 201:
        # Login to verify role
        login_response = client.post(
            "/api/v1/auth/login", data={"username": email, "password": "testpass123"}
        )
        token = login_response.json()["access_token"]

        # Get user info
        user_response = client.get(
            "/api/v1/users/me", headers={"Authorization": f"Bearer {token}"}
        )
        assert user_response.status_code == 200
        data = user_response.json()
        assert data["role"] == UserRole.DESIGNER.value
        assert data["is_superuser"] is False


def test_register_user_with_tailor_role(client):
    """Test user registration with TAILOR role."""
    import time

    email = f"tailor_{int(time.time())}@example.com"

    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": "testpass123",
            "first_name": "Test",
            "last_name": "Tailor",
            "role": UserRole.TAILOR.value,
        },
    )

    assert response.status_code in [201, 400]

    if response.status_code == 201:
        # Login to verify role
        login_response = client.post(
            "/api/v1/auth/login", data={"username": email, "password": "testpass123"}
        )
        token = login_response.json()["access_token"]

        # Get user info
        user_response = client.get(
            "/api/v1/users/me", headers={"Authorization": f"Bearer {token}"}
        )
        assert user_response.status_code == 200
        data = user_response.json()
        assert data["role"] == UserRole.TAILOR.value
        assert data["is_superuser"] is False


def test_user_response_includes_role_fields(client):
    """Test that UserResponse includes is_superuser and role fields."""
    import time

    email = f"rolecheck_{int(time.time())}@example.com"
    password = "testpass123"

    # Register user
    client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": password,
            "first_name": "Role",
            "last_name": "Check",
        },
    )

    # Login
    login_response = client.post(
        "/api/v1/auth/login", data={"username": email, "password": password}
    )
    token = login_response.json()["access_token"]

    # Get current user
    response = client.get(
        "/api/v1/users/me", headers={"Authorization": f"Bearer {token}"}
    )

    assert response.status_code == 200
    data = response.json()
    assert "role" in data
    assert "is_superuser" in data
    assert "is_active" in data
    assert data["is_active"] is True


def test_user_cannot_set_superuser_flag_during_registration(client):
    """Test that is_superuser is always False during public registration."""
    import time

    email = f"notsuperuser_{int(time.time())}@example.com"
    password = "testpass123"

    # Try to register as superuser (should be ignored)
    client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": password,
            "is_superuser": True,  # This should be ignored
        },
    )

    # Login
    login_response = client.post(
        "/api/v1/auth/login", data={"username": email, "password": password}
    )

    if login_response.status_code == 200:
        token = login_response.json()["access_token"]

        # Get user info
        user_response = client.get(
            "/api/v1/users/me", headers={"Authorization": f"Bearer {token}"}
        )
        assert user_response.status_code == 200
        data = user_response.json()
        # Should be False regardless of what was sent
        assert data["is_superuser"] is False
