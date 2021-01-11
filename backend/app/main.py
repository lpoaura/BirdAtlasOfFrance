#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Backend entry point"""

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import RedirectResponse

from app import __version__
from app.core.prospecting.routers import router as prospecting_router
from app.core.ref_geo.routers import router as ref_geo_router
from app.core.search.routers import router as search_router
from app.utils import log
from app.utils.config import settings
from app.utils.db import database

tags_metadata = [
    {
        "name": "core",
        "description": "Core APIs, globally used in app",
    },
    {
        "name": "prospecting",
        "description": "APIs dedicated to atlas prospecting modules",
    },
    {
        "name": "ref_geo",
        "description": "APIs dedicated to GeoNature ref_geo module",
    },
]


app = FastAPI(title=settings.APP_NAME, openapi_tags=tags_metadata)
app.add_middleware(GZipMiddleware, minimum_size=1000)
logger = log.setup_logger_from_settings()

origins = [
    "http://localhost",
    "http://localhost:8888",
    "http://127.0.0.1",
    "http://127.0.0.1:8888",
    "http://127.0.0.1:5500",
    "http://127.0.0.1:*",
    "http://127.0.0.1:3000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def startup():
    await database.connect()


@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()


@app.get("/", tags=["core"])
async def root():
    logger.debug("Hello!")
    # return {"message": "Welcome to Atlas bird of France API"}
    return RedirectResponse("/docs")


if settings.LOG_LEVEL == "DEBUG":

    @app.get("/pong", tags=["core"])
    async def pong():
        logger.error("Error log")
        logger.warning("Warning log")
        logger.info("Info log")
        logger.debug("Debug log")
        return {"ping": "pong"}


app.include_router(ref_geo_router, prefix=settings.API_PREFIX)
app.include_router(prospecting_router, prefix=settings.API_PREFIX)
app.include_router(search_router, prefix=settings.API_PREFIX)


def main():
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
    except Exception as e:
        logger.critical("Can't start app")
        raise e


if __name__ == "__main__":
    main()
