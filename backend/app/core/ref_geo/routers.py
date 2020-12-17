from typing import Any, List
from fastapi import Depends, HTTPException

from fastapi import APIRouter
from .actions import bib_areas_types
from .schemas import BibAreasTypes
from starlette.status import HTTP_201_CREATED, HTTP_404_NOT_FOUND
from sqlalchemy.orm import Session

from app.core.db import get_db

router = APIRouter()


@router.get(
    "/bibareastypes",
    response_model=List[BibAreasTypes],
    tags=["ref_geo"],
)
def list_bibareastypes(
    db: Session = Depends(get_db), skip: int = 0, limit: int = 100
) -> Any:
    bibareastypes = bib_areas_types.get_all(db=db, skip=skip, limit=limit)
    return bibareastypes


@router.get(
    "/bibareastypes/{id_type}",
    response_model=BibAreasTypes,
    responses={HTTP_404_NOT_FOUND: {"model": BibAreasTypes}},
    tags=["ref_geo"],
)
def get_bibareastypes(*, db: Session = Depends(get_db), id: int) -> Any:
    bibareastypes = bib_areas_types.get(db=db, id_type=id_type)
    if not bibareastypes:
        raise HTTPException(status_code=HTTP_404_NOT_FOUND, detail="Post not found")
    return bibareastypes
