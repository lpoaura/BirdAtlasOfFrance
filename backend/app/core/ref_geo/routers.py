import json
import logging
from typing import Any, List, Optional

from fastapi import APIRouter, Depends, HTTPException
from geojson_pydantic.features import FeatureCollection
from sqlalchemy.orm import Session
from starlette.status import HTTP_404_NOT_FOUND

from app.utils.db import get_db

from .actions import bib_areas_types, l_areas
from .schemas import BibAreasTypesSchema, LAreasFeatureProperties

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get(
    "/bibareastypes",
    response_model=List[BibAreasTypesSchema],
    tags=["ref_geo"],
)
def list_bibareastypes(db: Session = Depends(get_db), skip: int = 0, limit: int = 100) -> Any:
    bibareastypes = bib_areas_types.get_all(db=db, skip=skip, limit=limit)
    return bibareastypes


@router.get(
    "/bibareastypes/{id_type}",
    response_model=BibAreasTypesSchema,
    responses={HTTP_404_NOT_FOUND: {"model": BibAreasTypesSchema}},
    tags=["ref_geo"],
)
def get_bibareastypes(*, db: Session = Depends(get_db), id_type: int) -> Any:
    bibareastypes = bib_areas_types.get(db=db, id_type=id_type)
    if not bibareastypes:
        raise HTTPException(status_code=HTTP_404_NOT_FOUND, detail="Post not found")
    return bibareastypes


@router.get(
    "/lareas/{type_code}",
    response_model=FeatureCollection,
    tags=["ref_geo"],
)
def list_lareas(
    db: Session = Depends(get_db),
    type_code: str = "COM",
    limit: Optional[int] = None,
    envelope: Optional[str] = None,
) -> Any:
    if envelope:
        logger.debug(f"envelop qs: {envelope}")
        envelope = [float(c) for c in envelope.split(",")]
    logger.debug(f"envelop {envelope} {type(envelope)}")
    lareas = l_areas.get_feature_list(db=db, type_code=type_code, limit=limit, envelope=envelope)
    features = []
    for a in lareas:
        f = LAreasFeatureProperties(
            properties=a.properties,
            geometry=json.loads(a.geometry),
            id=a.id,
        )
        features.append(f)
    collection = FeatureCollection(features=features)
    return collection


@router.get(
    "/lareas/{id_area}",
    response_model=FeatureCollection,
    responses={HTTP_404_NOT_FOUND: {"model": LAreasFeatureProperties}},
    tags=["ref_geo"],
)
def get_lareas(*, db: Session = Depends(get_db), id_area: int) -> Any:
    lareas = l_areas.get(db=db, id_area=id_area)
    if not lareas:
        raise HTTPException(status_code=HTTP_404_NOT_FOUND, detail="Get not found")
    return lareas
