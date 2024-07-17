import logging
from typing import Any, Dict, Optional

from pydantic import PostgresDsn, validator
from pydantic_settings import BaseSettings, SettingsConfigDict

logger = logging.getLogger(__name__)


class Settings(BaseSettings):
    """App settings from env.

    Args:
        POSTGRES_HOST (Optional, str): DB Host. Default to "localhost".
        POSTGRES_PORT (Optional, int): DB Port. Default to 5432.
        POSTGRES_USER (str): DB username.
        POSTGRES_PASSWORD (str): DB password.
        POSTGRES_DB (str): DB name.
        LOG_LEVEL (Optional, str) : Log level. Default to "INFO"

    Returns:
        [type]: [description]
    """

    POSTGRES_USER: str
    POSTGRES_PASSWORD: str
    POSTGRES_DB: str
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: int = 5432
    LOG_LEVEL: str = "INFO"
    APP_NAME: str = "Bird atlas of France"
    APP_SYSNAME: str = "odf_api"
    API_PREFIX: str = "/api/v1"
    APP_URL: str
    SENTRY_DSN: Optional[str] = None
    SENTRY_TRACES_SAMPLE_RATE: float = 0.2
    SQLALCHEMY_DATABASE_URI: Optional[PostgresDsn] = None
    SQLALCHEMY_POOL_SIZE: int = 5
    SQLALCHEMY_MAX_OVERFLOW: int = 10
    CACHE_REDIS_HOST: str = "localhost"
    CACHE_REDIS_PORT: str = "6379"
    CACHE_DURATION: int = 1440
    model_config = SettingsConfigDict(case_sensitive=True, extra="ignore", env_file="../.env")

    @validator("SQLALCHEMY_DATABASE_URI", pre=True)
    def assemble_db_connection(cls, v: Optional[str], values: Dict[str, Any]) -> Any:
        """Generate db connection string"""
        if isinstance(v, str):
            return v
        pg_uri = PostgresDsn.build(
            scheme="postgresql",
            username=values.get("POSTGRES_USER"),
            password=values.get("POSTGRES_PASSWORD"),
            host=values.get("POSTGRES_HOST"),
            port=values.get("POSTGRES_PORT"),
            # path=f"/{values.get('POSTGRES_DB') or  ''}?application_name=odf_api",
            path=f"{values.get('POSTGRES_DB') or  ''}",
        )
        logger.debug(f"PG_URI {type(pg_uri)}")
        return pg_uri


settings = Settings()

logger.debug
