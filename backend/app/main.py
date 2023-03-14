#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Backend entry point"""
import random
import string
import time
import hashlib

import uvicorn
from typing import Optional
from enum import Enum
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import RedirectResponse, StreamingResponse

from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend
from fastapi_cache.decorator import cache

from redis import asyncio as aioredis

from app import __version__
from app.core.general.routers import router as main_router
from app.core.prospecting.routers import router as prospecting_router
from app.core.ref_geo.routers import router as ref_geo_router
from app.core.search.routers import router as search_router
from app.core.taxa.routers import router as taxa_router
from app.utils import log
from app.utils.config import settings
from app.utils.db import database

tags_metadata = [
    {
        "name": "core",
        "description": "Core APIs, globally used in app",
    },
    {
        "name": "main",
        "description": "Main APIs, used in home page",
    },
    {
        "name": "prospecting",
        "description": "APIs dedicated to atlas prospecting modules",
    },
    {
        "name": "ref_geo",
        "description": "APIs dedicated to GeoNature ref_geo module",
    },
    {
        "name": "taxa",
        "description": "APIs dedicated to atlas taxa data",
    },
]


app = FastAPI(
    title=settings.APP_NAME,
    description=f"{settings.APP_NAME} API Backend",
    openapi_tags=tags_metadata,
    docs_url="/api/v1/docs",
    redoc_url=None,
)


app.add_middleware(GZipMiddleware, minimum_size=1000)

if settings.SENTRY_DSN:
    try:
        import sentry_sdk
        from sentry_sdk.integrations.asgi import SentryAsgiMiddleware

        sentry_sdk.init(
            dsn=settings.SENTRY_DSN,
            traces_sample_rate=settings.SENTRY_TRACES_SAMPLE_RATE,
        )
        app.add_middleware(SentryAsgiMiddleware)
    except Exception:  # pylint: disable=W0718
        # pass silently if the Sentry integration failed
        pass


logger = log.setup_logger_from_settings()

origins = [
    #  Localhost  URLs
    "http://localhost",
    "http://127.0.0.1",
    # API Urls
    "http://localhost:8888",
    "http://127.0.0.1:8888",
    # Dev Frontend URL
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    # VSCode live server default URL
    "http://127.0.0.1:5500",
]

origins.append(settings.APP_URL)

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def api_key_builder(
    func,
    namespace: Optional[str] = "",
    request: Optional[Request] = None,
    response: Optional[Response] = None,
    args: Optional[tuple] = None,
    kwargs: Optional[dict] = None,
):
    """
    Handle Enum and Session params properly.
    """
    prefix = f"{FastAPICache.get_prefix()}:{namespace}:"

    # Remove session and convert Enum parameters to strings
    arguments = {}
    for key, value in kwargs.items():
        if key != "db":
            arguments[key] = value.value if isinstance(value, Enum) else value

    cache_key = (
        prefix
        + hashlib.md5(f"{func.__module__}:{func.__name__}:{args}:{arguments}".encode()).hexdigest()
    )

    return cache_key


@app.on_event("startup")
async def startup():
    """Database connect at startup"""
    await database.connect()
    redis = aioredis.from_url(
        f"redis://{settings.CACHE_REDIS_HOST}:{settings.CACHE_REDIS_PORT}",
        encoding="utf8",
        decode_responses=True,
    )
    FastAPICache.init(
        RedisBackend(redis),
        prefix="fastapi-cache",
        key_builder=api_key_builder,
        expire=settings.CACHE_DURATION,
    )


@app.on_event("shutdown")
async def shutdown():
    """Database disconnect at shutdown"""
    await database.disconnect()


@app.middleware("http")
async def log_requests(request: Request, call_next) -> StreamingResponse:
    """Log API time performances"""
    idem = "".join(random.choices(string.ascii_uppercase + string.digits, k=6))
    logger.debug(f"rid={idem} start request path={request.url.path}")
    start_time = time.time()

    response = await call_next(request)

    process_time = (time.time() - start_time) * 1000
    formatted_process_time = "{0:.2f}".format(process_time)
    logger.debug(
        f"rid={idem} completed_in={formatted_process_time}ms status_code={response.status_code}"
    )
    logger.debug(f"RESPONSE {response}")
    return response


@app.get("/", tags=["core"])
async def root() -> RedirectResponse:
    """Root API redirect to docs"""
    return RedirectResponse("/api/v1/docs")


if settings.SENTRY_DSN:

    @app.get("/sentry")
    async def sentry() -> dict:
        """Test sentry integration"""
        logger.debug(f"SENTRY_DSN: {settings.SENTRY_DSN}")
        return {"sentry": "ok"}


if settings.LOG_LEVEL == "debug":

    @app.get("/api/v1/ping", tags=["core"])
    @cache()
    async def pong() -> dict:
        """Debug ping pong log test"""
        print("CACHE")
        logger.error("Error log")
        logger.warning("Warning log")
        logger.info("Info log")
        logger.debug("Debug log")
        return {"ping": "pong"}


app.include_router(ref_geo_router, prefix=settings.API_PREFIX)
app.include_router(main_router, prefix=settings.API_PREFIX)
app.include_router(search_router, prefix=settings.API_PREFIX)
app.include_router(prospecting_router, prefix=settings.API_PREFIX)
logger.debug(f"{settings.API_PREFIX}/taxa")
logger.debug(settings.API_PREFIX)
app.include_router(taxa_router, prefix=f"{settings.API_PREFIX}/taxa")


def main():
    """App startup"""
    try:
        logger.info(f"starting app: {app.title} {__version__}")
        uvicorn.run(
            "app.main:app",
            host="0.0.0.0",
            log_level="debug",
            port=8888,
            reload=True,
            workers=2,
        )
    except Exception as error:  # pylint: disable=W0718
        logger.critical("Can't start app")
        raise error


if __name__ == "__main__":
    main()
