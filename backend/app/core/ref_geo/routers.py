import logging
from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException
from geoalchemy2 import functions as geofunctions
from geojson_pydantic.features import FeatureCollection
from sqlalchemy.orm import Session
from starlette.status import HTTP_201_CREATED, HTTP_404_NOT_FOUND

from app.core.db import get_db

from .actions import bib_areas_types, l_areas
from .models import BibAreasTypes, LAreas
from .schemas import BibAreasTypes, LAreasGeoJson, LAreasGeoJsonList

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get(
    "/bibareastypes",
    response_model=List[BibAreasTypes],
    tags=["ref_geo"],
)
def list_bibareastypes(db: Session = Depends(get_db), skip: int = 0, limit: int = 100) -> Any:
    bibareastypes = bib_areas_types.get_all(db=db, skip=skip, limit=limit)
    return bibareastypes


@router.get(
    "/bibareastypes/{id_type}",
    response_model=BibAreasTypes,
    responses={HTTP_404_NOT_FOUND: {"model": BibAreasTypes}},
    tags=["ref_geo"],
)
def get_bibareastypes(*, db: Session = Depends(get_db), id_type: int) -> Any:
    bibareastypes = bib_areas_types.get(db=db, id_type=id_type)
    if not bibareastypes:
        raise HTTPException(status_code=HTTP_404_NOT_FOUND, detail="Post not found")
    return bibareastypes


@router.get(
    "/lareas",
    response_model=LAreasGeoJsonList,
    tags=["ref_geo"],
)
def list_lareas(db: Session = Depends(get_db)) -> Any:
    # lareas = l_areas.get_all(db=db, skip=skip, limit=limit)
    lareas = db.query(
        LAreas.area_code, LAreas.area_name, geofunctions.ST_AsGeoJSON(LAreas.geom)
    ).all()
    gdata = LAreasGeoJsonList.features = lareas
    return gdata


@router.get(
    "/lareas/{id_area}",
    response_model=LAreasGeoJson,
    responses={HTTP_404_NOT_FOUND: {"model": LAreasGeoJson}},
    tags=["ref_geo"],
)
def get_lareas(*, db: Session = Depends(get_db), id_area: int) -> Any:
    lareas = l_areas.get(db=db, id_area=id_area)
    if not lareas:
        raise HTTPException(status_code=HTTP_404_NOT_FOUND, detail="Get not found")
    return lareas
