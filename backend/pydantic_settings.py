"""Compatibility shim for projects importing `pydantic_settings`.

This provides a minimal `BaseSettings` by re-exporting pydantic's BaseSettings
so the code can import `from pydantic_settings import BaseSettings` without
installing the external `pydantic-settings` package. This is intentionally
minimal and only required for env-based configuration used in this project.
"""

from pydantic import BaseSettings as _BaseSettings


class BaseSettings(_BaseSettings):
    """Thin shim around pydantic.BaseSettings to satisfy imports.

    The real `pydantic-settings` package provides additional helpers; this
    project uses only the BaseSettings behaviour for env parsing, so this
    shim is sufficient.
    """

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True
        extra = "ignore"
