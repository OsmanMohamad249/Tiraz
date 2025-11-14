import io
import os
import json
import tempfile
import pytest
from fastapi.testclient import TestClient


def test_measurements_smoke_flow(client: TestClient):
    """End-to-end smoke test for measurements flow:
    - Register a user
    - Login
    - Create a manual measurement
    - Upload a single image
    - List measurements and verify the created record exists
    """

    # 1) Register a fresh user (API allows public registration)
    email = f"smoke_test_{int(os.times().system)}@example.com"
    password = "smokePass123"
    reg_payload = {
        "email": email,
        "password": password,
        "first_name": "Smoke",
        "last_name": "Tester",
    }
    # Include X-Forwarded-For to avoid testclient having no client IP (rate limiter safe-path)
    base_headers = {"X-Forwarded-For": "127.0.0.1"}
    r = client.post("/api/v1/auth/register", json=reg_payload, headers=base_headers)
    assert r.status_code in (201, 400)

    # 2) Login to obtain bearer token
    login = client.post(
        "/api/v1/login/access-token",
        data={"username": email, "password": password},
        headers=base_headers,
    )
    assert login.status_code == 200
    token = login.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 3) Create manual measurement
    create_payload = {
        "measurements": {"chest": 92.0, "waist": 78.0, "hip": 96.0},
        "image_paths": {"image": "uploads/manual.jpg"},
        "confidence_score": 0.0,
    }
    rc = client.post("/api/v1/measurements", json=create_payload, headers={**headers, **base_headers})
    assert rc.status_code == 201
    created = rc.json()
    assert "id" in created

    # 4) Upload a single image (use a small temp file)
    tmp = tempfile.NamedTemporaryFile(delete=False)
    try:
        tmp.write(b"smoke-test-image-content")
        tmp.flush()
        with open(tmp.name, "rb") as fh:
            files = {"file": ("smoke.jpg", fh, "image/jpeg")}
            ru = client.post("/api/v1/measurements/upload-image", headers={**headers, **base_headers}, files=files)
        assert ru.status_code == 200
        up = ru.json()
        assert "image_paths" in up
    finally:
        try:
            os.unlink(tmp.name)
        except Exception:
            pass

    # 5) List measurements and ensure our created ID is present
    rl = client.get("/api/v1/measurements", headers={**headers, **base_headers})
    assert rl.status_code == 200
    data = rl.json()
    ids = [m.get("id") for m in data]
    assert created["id"] in ids
