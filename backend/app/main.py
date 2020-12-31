from typing import Any, List
import uvicorn
from .utils import log

from fastapi.logger import logger
from fastapi import Depends, FastAPI, HTTPException
from fastapi.responses import RedirectResponse
from pydantic import UUID4
from sqlalchemy.orm import Session
from starlette.status import HTTP_201_CREATED, HTTP_404_NOT_FOUND

from app.core.db import SessionLocal, engine

from app.core.ref_geo.routers import router as ref_geo_router

app = FastAPI(title='BirdAtlasOfFrance API')
logger = log.setup_logger_from_settings()


@app.get("/")
async def root():
    logger.debug("Hello!")
    # return {"message": "Welcome to Atlas bird of France API"}
    return RedirectResponse('/docs')

@app.get("/pong")
async def pong():
    logger.error("Error log")
    logger.warning("Warning log")
    logger.info("Info log")
    logger.debug("Debug log")
    return {"ping": "pong"}

app.include_router(ref_geo_router)


def main():
    try:
        logger.info("starting ODF app")
        uvicorn.run("app.main:app", host="0.0.0.0", log_level="debug", port=8888, reload=True, workers=2)
    except Exception as e:
        logger.critical(f"Can't start app")
        raise e


if __name__ == "__main__":
    main()
