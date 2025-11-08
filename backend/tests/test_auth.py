"""
Tests for authentication endpoints.

Note: These tests require a running database.
Run with: pytest tests/test_auth.py
"""

import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_health_endpoint():
    """Test health endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_register_user():
    """Test user registration."""
    # Use a unique email for each test run
    import time

    email = f"test_{int(time.time())}@example.com"

    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": "testpass123",
            "first_name": "Test",
            "last_name": "User",
        },
    )

    # Should succeed or fail with email already registered
    assert response.status_code in [201, 400]

    if response.status_code == 201:
        data = response.json()
        assert "message" in data
        assert data["email"] == email


def test_register_duplicate_email():
    """Test registering with duplicate email."""
    email = "duplicate@example.com"
    user_data = {
        "email": email,
        "password": "testpass123",
    }

    # First registration
    response1 = client.post("/api/v1/auth/register", json=user_data)

    # Second registration with same email
    response2 = client.post("/api/v1/auth/register", json=user_data)

    # Second one should fail
    assert response2.status_code == 400
    assert "already registered" in response2.json()["detail"].lower()


def test_login_success():
    """Test successful login."""
    # First register a user
    import time

    email = f"login_test_{int(time.time())}@example.com"
    password = "testpass123"

    client.post("/api/v1/auth/register", json={"email": email, "password": password})

    # Now try to login
    response = client.post(
        "/api/v1/auth/login",
        data={"username": email, "password": password},  # OAuth2 uses 'username' field
    )

    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


def test_login_wrong_password():
    """Test login with wrong password."""
    response = client.post(
        "/api/v1/auth/login",
        data={"username": "test@example.com", "password": "wrongpassword"},
    )

    assert response.status_code == 401


def test_get_current_user_authenticated():
    """Test getting current user info with valid token."""
    # Register and login
    import time

    email = f"current_user_{int(time.time())}@example.com"
    password = "testpass123"

    client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": password,
            "first_name": "Current",
            "last_name": "User",
        },
    )

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
    assert data["email"] == email
    assert data["first_name"] == "Current"
    assert data["last_name"] == "User"


def test_get_current_user_unauthenticated():
    """Test getting current user without token."""
    response = client.get("/api/v1/users/me")

    assert response.status_code == 401


def test_get_current_user_invalid_token():
    """Test getting current user with invalid token."""
    response = client.get(
        "/api/v1/users/me", headers={"Authorization": "Bearer invalid_token"}
    )

    assert response.status_code == 401
