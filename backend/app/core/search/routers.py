#!/usr/bin/python
"""Search routers module"""

import logging
from typing import Any, List, Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.utils.db import get_db

from .actions import mv_search_areas, mv_search_taxa
from .schemas import MvSearchAreasSchema, MvSearchTaxaSchema

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get(
    "/search/areas",
    response_model=List[MvSearchAreasSchema],
    tags=["core"],
    summary="Area search API by type code",
    description="""# Area search by type code

Search area by type code using area name and code
    """,
)
def search_areas(
    db: Session = Depends(get_db),
    limit: int = 10,
    search: Optional[str] = None,
    type_code: Optional[str] = None,
) -> Any:
    q = mv_search_areas.get_search_list(db=db, limit=limit, search=search, type_code=type_code)
    return q


@router.get(
    "/search/taxa",
    response_model=List[MvSearchTaxaSchema],
    tags=["core"],
    summary="Taxa search API",
    description="""# Taxa search

Search taxa by scientific name, common name or official cd_ref
""",
)
def search_taxa(
    db: Session = Depends(get_db),
    limit: int = 10,
    search: Optional[str] = None,
    cd_nom: Optional[int] = None,
) -> Any:
    q = mv_search_taxa.get_search_list(db=db, limit=limit, search=search, cd_nom=cd_nom)
    return q
