import json
import logging
import time
from typing import Any, List, Optional

from fastapi import APIRouter, Depends, HTTPException
from fastapi_cache.decorator import cache
from sqlalchemy.orm import Session
from starlette.status import HTTP_204_NO_CONTENT

from app.utils.db import get_db

from .actions import (
    area_dashboard,
    area_knowledge_level,
    area_knowledge_taxa_list,
    epoc,
    realized_epoc,
    taxon_count_classes_by_territory,
)
from .schemas import (
    AreaDashboardIntersectAreas,
    AreaDashboardSchema,
    AreaDashboardTimeDistribSchema,
    AreaKnowledgeLevelFeatureSchema,
    AreaKnowledgeLevelGeoJson,
    AreaKnowledgeLevelPropertiesSchema,
    AreaKnowledgeTaxaListSchema,
    EpocFeaturePropertiesSchema,
    EpocFeatureSchema,
    EpocSchema,
    RealizedEpocFeaturePropertiesSchema,
    RealizedEpocFeatureSchema,
    RealizedEpocSchema,
    TaxonCountClassesByTerritorySchema,
)


logger = logging.getLogger(__name__)

router = APIRouter()


@router.get(
    "/area/knowledge_level/{type_code}",
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
@cache()
def area_list_knowledge_level(
    db: Session = Depends(get_db),
    type_code: str = "M10",
    limit: Optional[int] = None,
    envelope: Optional[str] = None,
) -> Any:
    if envelope:
        envelope = [float(c) for c in envelope.split(",")]
    q = area_knowledge_level.get_feature_list(
        db=db, type_code=type_code, limit=limit, envelope=envelope
    )
    features = []
    if q:
        for a in q:
            f = AreaKnowledgeLevelFeatureSchema(
                properties=(AreaKnowledgeLevelPropertiesSchema(**a.properties)),
                geometry=json.loads(a.geometry),
                id=a.id,
            )
            features.append(f)
    return AreaKnowledgeLevelGeoJson(features=features)


@router.get(
    "/area/taxa_list/{id_area}",
    response_model=List[AreaKnowledgeTaxaListSchema],
    tags=["prospecting"],
    summary="List of species by area with qualitative data",
)
@cache()
def area_taxa_list(
    id_area: int, db: Session = Depends(get_db), limit: Optional[int] = None
) -> Any:
    query = area_knowledge_taxa_list.get_area_taxa_list(db=db, id_area=id_area)
    logger.debug(query)
    if query:
        return query
    return []


@router.get(
    "/area/general_stats/{id_area}",
    response_model=AreaDashboardSchema,
    tags=["prospecting"],
    summary="General stats by area",
)
@cache()
def area_general_stats(id_area: int, db: Session = Depends(get_db)) -> Any:
    query = area_dashboard.get_area_stats(db=db, id_area=id_area)
    if not query:
        raise HTTPException(status_code=404, detail="No data")
    return query


@router.get(
    "/area/time_distrib/{id_area}/{time_unit}",
    response_model=List[AreaDashboardTimeDistribSchema],
    tags=["prospecting"],
    summary="General stats by area",
    description="""# Data distribution in time

Count data by time unit during atlas period

**Time unit** must be a [PostgreSQL date field identifier]. *e.g.* :
  * `month`
  * `year`
  * `week`
  * `quarter`
  * *etc*.
""",
)
@cache()
def area_contrib_time_distrib(
    id_area: int,
    db: Session = Depends(get_db),
    time_unit: str = "month",
) -> Any:
    q = area_dashboard.get_time_distribution(db=db, id_area=id_area, time_unit=time_unit)
    logger.debug(f"<area_contrib_time_distrib> query {q}")
    if not q:
        raise HTTPException(status_code=404, detail="No data")
    return q


@router.get(
    "/area/list_areas",
    response_model=List[AreaDashboardIntersectAreas],
    tags=["prospecting"],
    summary="...",
    description="""cqfd""",
)
@cache()
def area_list_intersected_areas(
    id_area: int,
    db: Session = Depends(get_db),
    area_type: str = "COM",
) -> Any:
    query = area_dashboard.get_intersected_areas(db=db, id_area=id_area, type_code=area_type)
    if query:
        return query
    return []


@router.get(
    "/epoc",
    response_model=EpocSchema,
    tags=["prospecting"],
    summary="EPOC protocol geolocation",
    description="""# EPOC protocol geolocation

Official EPOC points, with status ("**Officiel**" vs "**Réserve**")

Status can be optionaly optionally using the query string `status=...`.
status filter must be one of the following:
* `Officiel`
* `Reserve`
    """,
)
# @cache()
def epoc_list(
    db: Session = Depends(get_db),
    status: Optional[str] = None,
    id_area: Optional[int] = None,
    envelope: Optional[str] = None,
) -> Any:
    envelope = [float(c) for c in envelope.split(",")] if envelope else None
    query = epoc.get_epocs(db=db, envelope=envelope, status=status, id_area=id_area)
    features = []
    if query:
        logger.debug(f"step3: {(time.time() - start_time) * 1000}")
        for item in query:
            ditem = item._asdict()
            geojson = ditem.pop("geometry", None)
            f = EpocFeatureSchema(
                properties=(EpocFeaturePropertiesSchema(**ditem)),
                geometry=geojson,
                id=item.id_epoc,
            )
            features.append(f)
    return EpocSchema(features=features)


@router.get(
    "/epoc/realized",
    response_model=RealizedEpocSchema,
    tags=["prospecting"],
    summary="Realized EPOC geolocation",
    description="""# Realized EPOC protocol geolocation

Realized EPOC points, from "EPOC..." project codes ("**EPOC**" vs "**EPOC-ODF**")

Project code can be optionaly optionally using the query string `project_code=...` .
Project code filter must be one of the following:
* `EPOC`
* `EPOC-ODF`
    """,
)
@cache()
def realized_epoc_list(
    db: Session = Depends(get_db),
    project_code: Optional[str] = None,
    id_area: Optional[int] = None,
    envelope: Optional[str] = None,
) -> Any:
    envelope = [float(c) for c in envelope.split(",")] if envelope else None
    query = realized_epoc.get_realized_epocs(
        db=db, envelope=envelope, project_code=project_code, id_area=id_area
    )
    features = []
    if query:
        for item in query:
            ditem = item._asdict()
            geojson = ditem.pop("geometry", None)
            f = RealizedEpocFeatureSchema(
                properties=(RealizedEpocFeaturePropertiesSchema(**ditem)),
                geometry=json.loads(geojson),
                id=item.id,
            )
            features.append(f)
        logger.debug(f"step4: {(time.time() - start_time) * 1000}")
    return RealizedEpocSchema(features=features)


@router.get(
    "/map/count_taxon_classes",
    response_model=Optional[List[TaxonCountClassesByTerritorySchema]],
    tags=["prospecting"],
    summary="Count taxon map classes",
    description="""# Count taxon map classes

Map representation classes to illustration taxon count by grid, using ntile method with 5 classes.
    """,
)
@cache()
def count_taxon_classes(
    id_area: int, db: Session = Depends(get_db), period: Optional[str] = "all_period"
) -> Any:
    q = taxon_count_classes_by_territory.get_classes(db=db, id_area=id_area, period=period)
    if q:
        return q
    return []
