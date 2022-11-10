import json
import logging
from typing import Any, List, Optional, Union

from fastapi import APIRouter, Depends, Response
from geojson_pydantic.features import FeatureCollection
from sqlalchemy.orm import Session
from starlette.status import HTTP_204_NO_CONTENT

from app.utils.db import get_db

from .actions import bib_areas_types, l_areas
from .schemas import BibAreasTypesSchema, LAreasFeatureProperties, LAreasIdArea

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
    "/bibareastypes/id/{id_type}",
    response_model=BibAreasTypesSchema,
    tags=["ref_geo"],
)
def get_bibareastypes(*, db: Session = Depends(get_db), id_type: int) -> Any:
    q = bib_areas_types.get(db=db, id_type=id_type)
    if not q:
        return Response(status_code=HTTP_204_NO_CONTENT)
    return q


@router.get(
    "/lareas/type/{type_code}",
    response_model=FeatureCollection,
    tags=["ref_geo"],
    summary="List areas from specific area type by type code",
    description="""# List areas from specific area type by type code

Return main areas infos as geojson:
* name
* code
* geometry (return only bounding box geometry if bbox is `True`)

Filter only enable areas if enable is True.

Filter from bbox giving envelop coordinates in envelop querystring 
(ex: `...?envelope=2.4,48.7,2.6,48.8`)
    """,
)
def list_lareas(
    db: Session = Depends(get_db),
    type_code: str = "COM",
    bbox: bool = None,
    only_enable: bool = None,
    limit: Optional[int] = None,
    envelope: Optional[str] = None,
) -> Any:
    if envelope:
        logger.debug(f"envelop qs: {envelope}")
        envelope = [float(c) for c in envelope.split(",")]
    logger.debug(f"envelop {envelope} {type(envelope)}")
    lareas = l_areas.get_feature_list(
        db=db,
        type_code=type_code,
        limit=limit,
        envelope=envelope,
        bbox=bbox,
        only_enable=only_enable,
    ).all()
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
    "/lareas/id/{id_area}",
    response_model=LAreasFeatureProperties,
    # responses={HTTP_204_NO_CONTENT: {"model": Feature}},
    tags=["ref_geo"],
)
def get_area_geom_by_id_area(
    id_area: int,
    bbox: bool = None,
    db: Session = Depends(get_db),
) -> Any:
    q = l_areas.get_feature_list(db=db, id_area=id_area, bbox=bbox).first()
    if not q:
        return Response(status_code=HTTP_204_NO_CONTENT)
    feature = LAreasFeatureProperties(
        id=q.id, properties=q.properties, geometry=json.loads(q.geometry)
    )
    return feature


@router.get(
    "/lareas/position",
    response_model=LAreasFeatureProperties,
    tags=["ref_geo"],
)
def get_area_by_coordinates(
    coordinates: str,
    type_code: str,
    bbox: bool = None,
    only_enable: bool = None,
    db: Session = Depends(get_db),
) -> Any:
    coords = [float(c) for c in coordinates.split(",")]
    q = l_areas.get_feature_list(
        db=db, type_code=type_code, bbox=bbox, coordinates=coords, only_enable=only_enable
    ).first()
    if not q:
        return Response(status_code=HTTP_204_NO_CONTENT)
    feature = LAreasFeatureProperties(
        id=q.id, properties=q.properties, geometry=json.loads(q.geometry)
    )
    return feature


@router.get(
    "/lareas/{type_code}/{area_code}",
    response_model=Union[LAreasFeatureProperties,LAreasIdArea],
    tags=["ref_geo"],
)
def get_area_geom_by_type_and_code(
    *,
    db: Session = Depends(get_db),
    area_code: str,
    type_code: str,
    geom: Optional[bool] = True,
    bbox: Optional[bool] = False
) -> Any:
    if isinstance(bbox, str):
        bbox: bool = True
    q = l_areas.get_by_area_type_and_code(
        db=db, area_code=area_code, type_code=type_code, geom=geom, bbox=bbox
    )
    if not q:
        return Response(status_code=HTTP_204_NO_CONTENT)
    if geom:
        feature = LAreasFeatureProperties(
            id=q.id, properties=q.properties, geometry=json.loads(q.geometry)
        )
        return feature
    else:
        return q
