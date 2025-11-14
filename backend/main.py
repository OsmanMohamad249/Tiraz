from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
from fastapi_limiter import FastAPILimiter
import redis.asyncio as redis

from core.config import settings
from api.v1.api import api_router


from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    redis_url = settings.REDIS_URL or "redis://localhost:6379/0"
    try:
        redis_client = redis.from_url(redis_url, encoding="utf8", decode_responses=True)
        await FastAPILimiter.init(redis_client)
        print("✅ Redis rate limiting enabled.")
    except Exception as e:
        print(f"⚠️ Redis not available, rate limiting disabled. Reason: {e}")
    yield

app = FastAPI(title="Qeyafa Backend (FastAPI)", lifespan=lifespan)

# Configure CORS with settings from environment
# Support for GitHub Codespaces with regex patterns
cors_origins = settings.CORS_ORIGINS.copy()

# Add GitHub Codespaces pattern support
# Pattern: https://*.app.github.dev
cors_origins_regex = None
if any("github.dev" in origin for origin in cors_origins):
    # If any GitHub Codespaces URL is configured, allow all Codespaces URLs
    cors_origins_regex = r"https://.*\.app\.github\.dev"

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_origin_regex=cors_origins_regex,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Rate limiting setup (Redis)
import asyncio


# Include API routers
app.include_router(api_router, prefix=settings.API_V1_PREFIX)


@app.get("/health", tags=["health"])
async def health():
    return {"status": "ok", "service": "qeyafa-backend"}
