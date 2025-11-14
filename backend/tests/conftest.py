"""
Pytest configuration for backend tests.
"""
import pytest
from fastapi.testclient import TestClient
from main import app as main_app
import os
from dotenv import load_dotenv

# Load test environment variables
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '.env.test'))


# Mock RateLimiter for tests
import fastapi_limiter
from fastapi_limiter.depends import RateLimiter

class MockRedis:
    async def script_load(self, script):
        return "mock_sha"

    async def evalsha(self, sha, keys, *args):
        return 0

class MockRateLimiter:
    def __init__(self, times=None, seconds=None):
        pass

    async def __call__(self, request, response):
        return None

# Initialize FastAPILimiter with mock redis before anything else
import asyncio
mock_redis = MockRedis()
asyncio.run(fastapi_limiter.FastAPILimiter.init(mock_redis))

# Monkey patch RateLimiter
fastapi_limiter.depends.RateLimiter = MockRateLimiter


@pytest.fixture(scope="session")
def app():
    """
    Create a test app without FastAPILimiter to avoid event loop issues.
    """
    # Set test environment
    os.environ["TESTING"] = "true"

    # Create a new FastAPI app for testing without rate limiting
    from fastapi import FastAPI
    from fastapi.middleware.cors import CORSMiddleware
    from core.config import settings
    from api.v1.api import api_router

    test_app = FastAPI(title="Qeyafa Backend (Test)")

    # Configure CORS
    cors_origins = settings.CORS_ORIGINS  # This is a property that parses CORS_ORIGINS_STR
    cors_origins_regex = None
    if any("github.dev" in origin for origin in cors_origins):
        cors_origins_regex = r"https://.*\.app\.github\.dev"

    test_app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_origin_regex=cors_origins_regex,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Include API router WITHOUT rate limiting
    test_app.include_router(api_router, prefix=settings.API_V1_PREFIX)

    # Add health endpoint
    @test_app.get("/health", tags=["health"])
    async def health():
        return {"status": "ok"}

    # Add lifespan event to initialize FastAPILimiter (even though it's mocked)
    @test_app.on_event("startup")
    async def startup_event():
        from fastapi_limiter import FastAPILimiter
        # Mock Redis client for testing
        class MockRedis:
            pass
        await FastAPILimiter.init(MockRedis())

    return test_app


@pytest.fixture(scope="function")
def client(app):
    """
    Create a test client for the app.
    """
    return TestClient(app)


@pytest.fixture(scope="function", autouse=True)
def setup_database():
    """
    Setup database for tests.
    """
    from core.database import Base, engine
    from core.config import settings

    # Create all tables
    Base.metadata.create_all(bind=engine)

    # Create test admin user
    from core.security import hash_password
    from models.user import User
    from models.roles import UserRole
    from sqlalchemy.orm import Session

    db = Session(engine)
    try:
        # Check if admin user exists
        admin_user = db.query(User).filter(User.email == "admin@example.com").first()
        if not admin_user:
            admin_user = User(
                email="admin@example.com",
                hashed_password=hash_password("password123"),
                first_name="Admin",
                last_name="User",
                role=UserRole.ADMIN,
                is_active=True,
                is_superuser=True,
            )
            db.add(admin_user)
            db.commit()
    finally:
        db.close()

    yield

    # Drop all tables after test
    Base.metadata.drop_all(bind=engine)