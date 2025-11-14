"""Configuration settings for the application.

This module uses pydantic v1 `BaseSettings` for environment parsing to match
the project's pinned requirements. The implementation uses v1-style
validators and `Config` class for env-file support.
"""

import os
from typing import List, Optional
from pydantic import BaseSettings, Field, validator


class Settings(BaseSettings):
    """Application settings with environment variable validation"""
    REDIS_URL: Optional[str] = Field(default=None, description="Redis connection URL")

    # Environment Configuration
    ENVIRONMENT: str = Field(
        default="development",
        description="Application environment (development, staging, production)",
    )

    # Database - REQUIRED, no default for security
    DATABASE_URL: str = Field(..., description="Database connection URL (e.g., postgresql://user:pass@host:port/db)")
    POSTGRES_USER: Optional[str] = Field(default=None, description="Postgres username")
    POSTGRES_PASSWORD: Optional[str] = Field(default=None, description="Postgres password")
    POSTGRES_DB: Optional[str] = Field(default=None, description="Postgres database name")

    # Security - REQUIRED, no default for security
    SECRET_KEY: str = Field(..., description="Secret key for JWT token signing (must be kept secret)", min_length=32)
    ALGORITHM: str = Field(default="HS256", description="Algorithm for JWT token encoding")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=30, description="Access token expiration time in minutes", ge=1)

    # API
    API_V1_PREFIX: str = Field(default="/api/v1", description="API v1 prefix path")

    # CORS Settings - More restrictive by default
    CORS_ORIGINS_STR: str = Field(default="http://localhost:3000,http://localhost:8080", description="Allowed CORS origins (comma-separated in env)")

    # AI Service - Optional with sensible default
    AI_SERVICE_URL: str = Field(default="http://ai-models:8000", description="AI service URL for model inference")

    # Debug mode - automatically set based on environment
    DEBUG: bool = Field(default=True, description="Debug mode (automatically False in production)")

    @validator("ENVIRONMENT", pre=True)
    def validate_environment(cls, v):
        if v is None:
            return v
        allowed = ["development", "staging", "production"]
        if v.lower() not in allowed:
            raise ValueError(f"ENVIRONMENT must be one of {allowed}, got: {v}")
        return v.lower()

    @validator("SECRET_KEY", pre=True)
    def validate_secret_key(cls, v):
        if v is None:
            return v
        weak_keys = [
            "your-secret-key",
            "your-secret-key-change-this-in-production",
            "change-this",
            "secret",
            "password",
        ]
        if any(weak in v.lower() for weak in weak_keys):
            raise ValueError(
                "SECRET_KEY appears to be a weak/default value. Please set a strong secret key in your environment variables."
            )
        return v

    @validator("DEBUG", pre=True)
    def set_debug_mode(cls, v):
        env = os.getenv("ENVIRONMENT")
        if env == "production":
            return False
        return v

    @property
    def CORS_ORIGINS(self) -> List[str]:
        """Parse and return CORS origins as a list"""
        return [origin.strip() for origin in self.CORS_ORIGINS_STR.split(",")]

    @property
    def is_development(self) -> bool:
        return self.ENVIRONMENT == "development"

    @property
    def is_staging(self) -> bool:
        return self.ENVIRONMENT == "staging"

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT == "production"

    class Config:
        env_file = [".env", ".env.test"] if os.getenv("TESTING") else ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True
        extra = "ignore"


settings = Settings()
