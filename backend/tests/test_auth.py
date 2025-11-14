"""
Tests for authentication endpoints.

Note: These tests require a running database.
Run with: pytest tests/test_auth.py
"""






import pytest
from fastapi.testclient import TestClient
import os
from main import app
from models.roles import UserRole


@pytest.fixture(scope="function", autouse=True)
def disable_rate_limiter(monkeypatch):
    """
    Disable FastAPILimiter for all tests to avoid event loop and 429 errors.
    """
    try:
        import fastapi_limiter.depends
        async def no_op_call(self, request, response):
            return None
        monkeypatch.setattr(fastapi_limiter.depends.RateLimiter, "__call__", no_op_call)
    except ImportError:
        pass


def test_health_endpoint(client):
    """Test health endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_register_user(client):
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


def test_register_duplicate_email(client):
    """Test registering with duplicate email."""
    email = "duplicate@example.com"
    user_data = {
        "email": email,
        "password": "testpass123",
        "first_name": "Test",
        "last_name": "User",
        "role": "customer",
    }

    # First registration
    response1 = client.post("/api/v1/auth/register", json=user_data)
    print("First registration response:", response1.json())

    # Second registration with same email
    response2 = client.post("/api/v1/auth/register", json=user_data)
    print("Second registration response:", response2.json())

    # Second one should fail
    assert response2.status_code == 400
    assert "already registered" in response2.json()["detail"].lower()


def test_login_success(client):
    """Test successful login."""
    # First register a user
    import time

    email = f"login_test_{int(time.time())}@example.com"
    password = "testpass123"

    reg_response = client.post("/api/v1/auth/register", json={
        "email": email,
        "password": password,
        "first_name": "Test",
        "last_name": "User",
        "role": "customer",
    })
    print("Registration response:", reg_response.json())

    # Now try to login
    response = client.post(
        "/api/v1/auth/login",
        data={"username": email, "password": password},  # OAuth2 uses 'username' field
    )

    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


def test_login_wrong_password(client):
    """Test login with wrong password."""
    response = client.post(
        "/api/v1/auth/login",
        data={"username": "test@example.com", "password": "wrongpassword"},
    )

    assert response.status_code == 401


def test_get_current_user_authenticated(client):
    """Test getting current user info with valid token."""
    # Register and login
    import time

    email = f"current_user_{int(time.time())}@example.com"
    password = "testpass123"

    reg_response = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": password,
            "first_name": "Current",
            "last_name": "User",
            "role": "customer",
        },
    )
    print("Registration response:", reg_response.json())
    

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


def test_get_current_user_unauthenticated(client):
    """Test getting current user without token."""
    response = client.get("/api/v1/users/me")

    assert response.status_code == 401


def test_get_current_user_invalid_token(client):
    """Test getting current user with invalid token."""
    response = client.get(
        "/api/v1/users/me", headers={"Authorization": "Bearer invalid_token"}
    )

    assert response.status_code == 401


def test_register_password_too_short(client):
    """Test registration with password shorter than 8 characters."""
    import time

    email = f"short_pwd_{int(time.time())}@example.com"

    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": "short",  # Only 5 characters
            "first_name": "Test",
            "last_name": "User",
        },
    )

    assert response.status_code == 422
    error_detail = response.json()["detail"]
    assert any("password" in str(error).lower() for error in error_detail)


def test_register_password_too_long(client):
    """Test registration with password longer than 72 characters."""
    import time

    email = f"long_pwd_{int(time.time())}@example.com"
    # Create a password longer than 72 characters
    long_password = "a" * 73

    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": long_password,
            "first_name": "Test",
            "last_name": "User",
            "role": UserRole.CUSTOMER,
        },
    )

    assert response.status_code == 422
    error_detail = response.json()["detail"]
    assert any("password" in str(error).lower() for error in error_detail)


def test_register_password_valid_lengths(client):
    """Test registration with valid password lengths (8 and 72 characters)."""
    import time

    # Test minimum length (8 characters)
    email_min = f"pwd_min_{int(time.time())}@example.com"
    response_min = client.post(
        "/api/v1/auth/register",
        json={
            "email": email_min,
            "password": "12345678",  # Exactly 8 characters
            "first_name": "Test",
            "last_name": "User",
            "role": UserRole.CUSTOMER,
        },
    )

    assert response_min.status_code in [201, 400]  # 201 success, 400 duplicate email

    # Test maximum length (72 characters)
    email_max = f"pwd_max_{int(time.time())}@example.com"
    response_max = client.post(
        "/api/v1/auth/register",
        json={
            "email": email_max,
            "password": "a" * 72,  # Exactly 72 characters
            "first_name": "Test",
            "last_name": "User",
            "role": UserRole.CUSTOMER,
        },
    )

    assert response_max.status_code in [201, 400]  # 201 success, 400 duplicate email
