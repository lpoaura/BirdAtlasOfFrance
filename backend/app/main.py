from typing import Any, List
import uvicorn
import coloredlogs, logging

from fastapi import Depends, FastAPI, HTTPException
from pydantic import UUID4
from sqlalchemy.orm import Session
from starlette.status import HTTP_201_CREATED, HTTP_404_NOT_FOUND

from .core.db import SessionLocal, engine

from .core.ref_geo.routers import router as ref_geo_router

# Create all tables in the database.
# Comment this out if you using migrations.
# models.Base.metadata.create_all(bind=engine)

logger = logging.getLogger(__name__)
coloredlogs.install(level='DEBUG', logger=logger)
logger.debug("this is a debugging message")
logger.info("this is an informational message")
logger.warning("this is a warning message")
logger.error("this is an error message")
logger.critical("this is a critical message")

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Atlas bird of France root API"}

app.include_router(ref_geo_router)




def main():
    logger.info("starting ODF app")
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True, workers=2)

if __name__ == "__main__":
    main()
