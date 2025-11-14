"""
Tests for admin endpoints.

Note: These tests require a running database.
Run with: pytest tests/test_admin_endpoints.py
"""

import pytest
from fastapi.testclient import TestClient
from main import app
import time


def get_admin_token(client):
    """Helper function to get admin authentication token."""
    email = "admin@example.com"
    password = "password123"

    # Login to get token
    login_response = client.post(
        "/api/v1/auth/login",
        data={"username": email, "password": password}
    )
    print(f"Login response: {login_response.status_code} - {login_response.text}")

    if login_response.status_code == 200:
        return login_response.json()["access_token"]
    return None


def test_create_designer(client):
    """Test creating a designer user as admin."""
    token = get_admin_token(client)
    assert token is not None

    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    data = {
        "email": f"designer_{int(time.time())}@example.com",
        "password": "designerpass",
        "first_name": "Designer",
        "last_name": "User",
        "role": "designer"
    }
    response = client.post("/api/v1/admin/admin-create-user", json=data, headers=headers)
    print("Create designer:", response.status_code, response.json())
    assert response.status_code in [201, 400]  # 201 success, 400 duplicate


def test_list_users(client):
    """Test listing users as admin."""
    token = get_admin_token(client)
    assert token is not None

    headers = {"Authorization": f"Bearer {token}"}
    response = client.get("/api/v1/admin/users", headers=headers)
    print("List users:", response.status_code, response.json())
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)


def test_update_user(client):
    """Test updating a user as admin."""
    token = get_admin_token(client)
    assert token is not None

    # Create a test user first
    user_email = f"update_test_{int(time.time())}@example.com"
    reg_response = client.post("/api/v1/admin/admin-create-user", json={
        "email": user_email,
        "password": "testpass123",
        "first_name": "Test",
        "last_name": "User",
        "role": "designer",
    }, headers={"Authorization": f"Bearer {token}"})
    assert reg_response.status_code == 201
    user_data = reg_response.json()
    user_email = user_data["email"]

    # Get user ID from list_users endpoint
    list_response = client.get("/api/v1/admin/users", headers={"Authorization": f"Bearer {token}"})
    assert list_response.status_code == 200
    users = list_response.json()
    user = next((u for u in users if u["email"] == user_email), None)
    assert user is not None
    user_id = user["id"]

    # Update the user
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    data = {"first_name": "UpdatedUser"}
    response = client.put(f"/api/v1/admin/users/{user_id}", json=data, headers=headers)
    assert response.status_code == 200


def test_delete_user(client):
    """Test deleting a user as admin."""
    token = get_admin_token(client)
    assert token is not None

    # Create a test user first
    user_email = f"delete_test_{int(time.time())}@example.com"
    reg_response = client.post("/api/v1/admin/admin-create-user", json={
        "email": user_email,
        "password": "testpass123",
        "first_name": "Test",
        "last_name": "User",
        "role": "designer",
    }, headers={"Authorization": f"Bearer {token}"})
    assert reg_response.status_code == 201
    user_data = reg_response.json()
    user_email = user_data["email"]

    # Get user ID from list_users endpoint
    list_response = client.get("/api/v1/admin/users", headers={"Authorization": f"Bearer {token}"})
    assert list_response.status_code == 200
    users = list_response.json()
    user = next((u for u in users if u["email"] == user_email), None)
    assert user is not None
    user_id = user["id"]

    # Delete the user
    headers = {"Authorization": f"Bearer {token}"}
    response = client.delete(f"/api/v1/admin/users/{user_id}", headers=headers)
    assert response.status_code == 200


def test_delete_user(client):
    """Test deleting a user as admin."""
    token = get_admin_token(client)
    assert token is not None

    headers = {"Authorization": f"Bearer {token}"}
    response = client.delete("/api/v1/admin/users/12345678-1234-5678-9012-123456789012", headers=headers)  # Non-existent user
    assert response.status_code in [400, 404, 403]
