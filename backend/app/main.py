from typing import Any, List

from fastapi import Depends, FastAPI, HTTPException
from pydantic import UUID4
from sqlalchemy.orm import Session
from starlette.status import HTTP_201_CREATED, HTTP_404_NOT_FOUND

from app.core.db import SessionLocal, engine

from .core.ref_geo.routers import router as ref_geo_router

# Create all tables in the database.
# Comment this out if you using migrations.
# models.Base.metadata.create_all(bind=engine)

app = FastAPI()


@app.get("/")
def index():
    return {"message": "Hello world!"}


app.include_router(ref_geo_router)


@app.get("/")
async def root():
    return {"message": "Hello Bigger Applications!"}
