import logging
from typing import Any

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.utils.db import get_db

from .actions import general_stats
from .schemas import GeneralStatsSchema

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get(
    "/general_stats",
    response_model=GeneralStatsSchema,
    tags=["main"],
    summary="Areas list with general statistics per zone within a bounding box",
    description="""# General stats

Platform general stats for home page:
* Taxa count (atlas date range) for each kind of period.
* Prospecting cumulated time (in hours) for each kind of period.

Periods are:
* all period (all along the year)
* wintering (only wintering observations)
* breeding (only breeding observations)
    """,
)
def general_stats_data(db: Session = Depends(get_db)) -> Any:
    q = general_stats.query(db=db)
    logger.debug(q)
    return q
