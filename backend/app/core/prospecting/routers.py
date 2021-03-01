import json
import logging
from typing import Any, List, Optional

from fastapi import APIRouter, Depends, HTTPException
from geojson_pydantic.features import FeatureCollection
from sqlalchemy.orm import Session

from app.utils.db import get_db, settings

from .actions import area_knowledge_level, area_knowledge_taxa_list
from .schemas import (
    AreaKnowledgeLevelFeatureSchema,
    AreaKnowledgeLevelGeoJson,
    AreaKnowledgeLevelPropertiesSchema,
    AreaKnowledgeTaxaListSchema,
)

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get(
    "/area_knowledge_level/{type_code}",
    response_model=AreaKnowledgeLevelGeoJson,
    tags=["prospecting"],
    summary="Areas list with general statistics per zone within a bounding box",
    description="""# Area list

This return a list of areas filtered by type (`type_code`) 
and within a geographic bounding box (`envelope`) with general stats:
* All period:
  * Count taxa in previous atlas as `old_count` ;
  * Count taxa in this atlas as `new_count` ;
  * Percent knowlegde calculated by Count taa in previous `(count_new/count_old)`.
* wintering, same as all period ;
* Breeding, same as all period.

    """,
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


@router.get(
    "/area/list_taxa/{id_area}",
    response_model=List[AreaKnowledgeTaxaListSchema],
    tags=["prospecting"],
    summary="List of species by area with qualitative data",
)
def area_list_taxa(
    id_area: int, db: Session = Depends(get_db), limit: Optional[int] = None
) -> Any:
    taxa_list = area_knowledge_taxa_list.get_area_taxa_list(db=db, id_area=id_area)
    return taxa_list
