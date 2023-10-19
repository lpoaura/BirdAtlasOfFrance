import logging
from typing import Any

from fastapi import APIRouter, Depends, HTTPException
from fastapi_cache.decorator import cache
from sqlalchemy.orm import Session
from starlette.status import HTTP_204_NO_CONTENT

from app.utils.db import get_db

from .actions import general_stats, knowledge_level_general_stats
from .schemas import GeneralStatsSchema, KnowledgeLevelGeneralStatsSchema

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get(
    "/period_stats",
    response_model=GeneralStatsSchema,
    tags=["main"],
    summary="General stats",
    description="""# General stats

Platform general stats for home page:
* Taxa count (atlas date range) for each kind of period:
  * all period (all along the year)
  * wintering (only wintering observations)
  * breeding (only breeding observations)
* Prospecting cumulated time (in hours) for each kind of period:
  * all but breeding/wintering
  * wintering (only wintering observations)
  * breeding (only breeding observations)
""",
)
@cache()
def period_stats(db: Session = Depends(get_db)) -> Any:
    q = general_stats.query(db=db)
    logger.debug(q)
    return q


@router.get(
    "/knowledge_level",
    response_model=KnowledgeLevelGeneralStatsSchema,
    tags=["main"],
    summary="Global knowledge level",
    description="""# Global knowledge level

Global knowledge level for atlas, from area counts categorized by knowledge level:
* average
* from 0 to 25%
* from 25 to 50%
* from 50 to 75%
* from 75 to 100%
* over 100%

Period options are:
* `allperiod`
* `wintering`
* `breeding`
    """,
)
@cache()
def knowledge_level(
    id_area: int = None, period: str = "allperiod", db: Session = Depends(get_db)
) -> Any:
    q = knowledge_level_general_stats.query(db=db, id_area=id_area, period=period)
    if not q:
        raise HTTPException(status_code=404, detail="No data")
    return q
