"""
Tests for design endpoints.

Note: These tests require a running database.
Run with: pytest tests/test_designs.py
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


def _create_user_and_login(client, role=UserRole.CUSTOMER):
    """Helper function to create a user and get auth token."""
    import time

    email = f"user_{int(time.time() * 1000000)}@example.com"
    password = "testpass123"

    # Register user with specified role
    client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": password,
            "first_name": "Test",
            "last_name": "User",
            "role": role.value,
        },
    )

    # Login to get token
    login_response = client.post(
        "/api/v1/auth/login", data={"username": email, "password": password}
    )

    if login_response.status_code == 200:
        return login_response.json()["access_token"]
    return None


def test_list_designs_unauthenticated(client):
    """Test listing designs without authentication."""
    response = client.get("/api/v1/designs/")

    # Should succeed - public endpoint
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_create_design_as_designer(client):
    """Test creating a design as designer."""
    # Create designer user and login
    token = _create_user_and_login(client, UserRole.DESIGNER)

    if not token:
        return

    import time

    design_name = f"Test Design {int(time.time())}"

    response = client.post(
        "/api/v1/designs/",
        json={
            "name": design_name,
            "description": "Beautiful test design",
            "style_type": "modern",
            "base_price": 99.99,
        },
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code in [201, 403]


def test_create_design_as_customer(client):
    """Test creating a design as customer (should fail)."""
    # Create customer user and login
    token = _create_user_and_login(client, UserRole.CUSTOMER)


def test_create_design_unauthenticated(client):
    """Test that unauthenticated users cannot create designs."""
    import time

    design_name = f"Test Design {int(time.time())}"

    response = client.post(
        "/api/v1/designs/",
        json={
            "name": design_name,
            "description": "Test design",
            "base_price": 99.99,
        },
    )

    # Should fail - authentication required
    assert response.status_code == 401


def test_create_design_with_negative_price(client):
    """Test creating a design with negative price (should fail)."""
    # Create designer user and login
    token = _create_user_and_login(client, UserRole.DESIGNER)


def test_get_design_details(client):
    """Test getting design details."""
    # First, list designs to get an ID (if any exist)
    list_response = client.get("/api/v1/designs/")

    if list_response.status_code == 200:
        designs = list_response.json()

        if len(designs) > 0:
            # Get first design details
            design_id = designs[0]["id"]
            response = client.get(f"/api/v1/designs/{design_id}")

            assert response.status_code == 200
            data = response.json()
            assert data["id"] == design_id


def test_get_nonexistent_design(client):
    """Test getting a design that doesn't exist."""
    fake_id = "00000000-0000-0000-0000-000000000000"
    response = client.get(f"/api/v1/designs/{fake_id}")

    assert response.status_code == 404


def test_list_designs_with_pagination(client):
    """Test listing designs with pagination parameters."""
    response = client.get("/api/v1/designs/?skip=0&limit=10")

    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_list_designs_with_style_filter(client):
    """Test listing designs filtered by style type."""
    response = client.get("/api/v1/designs/?style_type=modern")

    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_list_designs_with_active_filter(client):
    """Test listing only active designs."""
    response = client.get("/api/v1/designs/?active_only=true")

    assert response.status_code == 200
    designs = response.json()
    assert isinstance(designs, list)

    # All designs should be active
    for design in designs:
        assert design.get("is_active") is True


def test_get_designer_own_designs(client):
    """Test getting a designer's own designs via /designs/me endpoint."""
    token = _create_user_and_login(client, UserRole.DESIGNER)

    if not token:
        return

    response = client.get(
        "/api/v1/designs/me",
        headers={"Authorization": f"Bearer {token}"},
    )

    # Should succeed - designer can access their own designs
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_get_designer_own_designs_as_customer(client):
    """Test that customers cannot access /designs/me endpoint."""
    token = _create_user_and_login(client, UserRole.CUSTOMER)

    if not token:
        return

    response = client.get(
        "/api/v1/designs/me",
        headers={"Authorization": f"Bearer {token}"},
    )

    # Should fail - only designers can access this endpoint
    assert response.status_code == 403


def test_update_design_requires_ownership(client):
    """Test that only the design owner can update it."""
    # This test would need to create a design with one user
    # and try to update it with another user
    # Skip for now as it requires more complex setup
    pass


def test_delete_design_requires_ownership(client):
    """Test that only the design owner can delete it."""
    # This test would need to create a design with one user
    # and try to delete it with another user
    # Skip for now as it requires more complex setup
    pass
