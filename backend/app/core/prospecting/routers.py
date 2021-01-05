import json
import logging
from typing import Any, List, Optional

from fastapi import APIRouter, Depends, HTTPException
from geojson_pydantic.features import FeatureCollection
from sqlalchemy.orm import Session

from app.utils.db import get_db, settings

from .actions import area_knowledge_level
from .schemas import (
    AreaKnowledgeLevelFeatureSchema,
    AreaKnowledgeLevelGeoJson,
    AreaKnowledgeLevelPropertiesSchema,
)

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get(
    "/area_knowledge_level/{type_code}",
    response_model=AreaKnowledgeLevelGeoJson,
    tags=["prospecting"],
)
def list_area_knowledge_level(
    db: Session = Depends(get_db),
    type_code: str = "M10",
    limit: Optional[int] = None,
    envelope: Optional[str] = None,
) -> Any:
    logger.debug(settings.SQLALCHEMY_DATABASE_URI)
    if envelope:
        logger.debug(f"envelop qs: {envelope}")
        envelope = [float(c) for c in envelope.split(",")]
    logger.debug(f"envelop {envelope} {type(envelope)}")
    areas = area_knowledge_level.get_feature_list(
        db=db, type_code=type_code, limit=limit, envelope=envelope
    )
    features = []
    for a in areas:
        f = AreaKnowledgeLevelFeatureSchema(
            properties=(AreaKnowledgeLevelPropertiesSchema(**a.properties)),
            geometry=json.loads(a.geometry),
            id=a.id,
        )
        features.append(f)
    return AreaKnowledgeLevelGeoJson(features=features)
