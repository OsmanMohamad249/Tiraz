"""
Tests for measurements endpoints.

Note: These tests require a running database and AI service.
Run with: pytest tests/test_measurements.py
"""

import io



from fastapi.testclient import TestClient
from main import app
import redis.asyncio as redis
from fastapi_limiter import FastAPILimiter
import asyncio
import os


def get_auth_token(client):
    """Helper function to get authentication token."""
    import time
    email = f"test_user_{int(time.time())}@example.com"
    password = "testpass123"

    # Register user
    reg_response = client.post("/api/v1/auth/register", json={
        "email": email,
        "password": password,
        "first_name": "Test",
        "last_name": "User",
        "role": "customer",
    })

    # Login to get token
    login_response = client.post(
        "/api/v1/auth/login",
        data={"username": email, "password": password}
    )

    if login_response.status_code == 200:
        return login_response.json()["access_token"]
    return None


def test_upload_photos_unauthenticated(client):
    """Test uploading photos without authentication."""
    # Create dummy image files
    files = {
        "photo_front": ("front.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_back": ("back.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_left": ("left.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_right": ("right.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
    }

    response = client.post("/api/v1/measurements/upload", files=files)

    # Should require authentication
    assert response.status_code == 401


def test_process_measurements_unauthenticated(client):
    """Test processing measurements without authentication."""
    # Create dummy image files
    files = {
        "photo_front": ("front.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_back": ("back.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_left": ("left.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_right": ("right.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
    }

    data = {"height": 175.0, "weight": 70.0}

    response = client.post("/api/v1/measurements/process", files=files, data=data)

    # Should require authentication
    assert response.status_code == 401


def get_auth_token(client):
    """Helper function to get authentication token."""
    import time

    email = f"test_measurements_{int(time.time())}@example.com"
    password = "testpass123"

    # Register user
    client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": password,
            "first_name": "Test",
            "last_name": "User",
        },
    )

    # Login
    response = client.post(
        "/api/v1/auth/login", data={"username": email, "password": password}
    )

    return response.json()["access_token"]


def test_upload_photos_authenticated(client):
    """Test uploading photos with authentication."""
    token = get_auth_token(client)

    # Create dummy image files
    files = {
        "photo_front": ("front.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_back": ("back.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_left": ("left.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_right": ("right.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
    }

    response = client.post(
        "/api/v1/measurements/upload",
        files=files,
        headers={"Authorization": f"Bearer {token}"},
    )

    # Should succeed
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "image_paths" in data
    assert len(data["image_paths"]) == 4


def test_upload_photos_missing_file(client):
    """Test uploading photos with missing file."""
    token = get_auth_token(client)

    # Create incomplete set of files
    files = {
        "photo_front": ("front.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_back": ("back.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_left": ("left.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        # Missing photo_right
    }

    response = client.post(
        "/api/v1/measurements/upload",
        files=files,
        headers={"Authorization": f"Bearer {token}"},
    )

    # Should fail with 422 (validation error)
    assert response.status_code == 422


def test_upload_photos_invalid_file_type(client):
    """Test uploading photos with invalid file type."""
    token = get_auth_token(client)

    # Create files with invalid type
    files = {
        "photo_front": ("front.txt", io.BytesIO(b"fake image content"), "text/plain"),
        "photo_back": ("back.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_left": ("left.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_right": ("right.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
    }

    response = client.post(
        "/api/v1/measurements/upload",
        files=files,
        headers={"Authorization": f"Bearer {token}"},
    )

    # Should fail with 400 (bad request)
    assert response.status_code == 400
    assert "not allowed" in response.json()["detail"].lower()


# Note: Full integration test for process_measurements would require the AI service to be running
# For now, we just test authentication and validation
def test_process_measurements_missing_data(client):
    """Test processing measurements with missing data."""
    token = get_auth_token(client)

    # Create files but no height/weight
    files = {
        "photo_front": ("front.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_back": ("back.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_left": ("left.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
        "photo_right": ("right.jpg", io.BytesIO(b"fake image content"), "image/jpeg"),
    }

    # Missing height and weight in data
    response = client.post(
        "/api/v1/measurements/process",
        files=files,
        headers={"Authorization": f"Bearer {token}"},
    )

    # Should fail with 422 (validation error)
    assert response.status_code == 422
