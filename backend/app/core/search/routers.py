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


@router.get("/search_areas", response_model=List[MvSearchAreasSchema], tags=["core"])
def search_areas(
    db: Session = Depends(get_db),
    limit: int = 10,
    search: Optional[str] = None,
    type_code: Optional[str] = None,
) -> Any:
    rsearch = mv_search_areas.get_search_list(
        db=db, limit=limit, search=search, type_code=type_code
    )
    return rsearch


@router.get("/search_taxa", response_model=List[MvSearchTaxaSchema], tags=["core"])
def search_taxa(
    db: Session = Depends(get_db), limit: int = 10, search: Optional[str] = None
) -> Any:
    rsearch = mv_search_taxa.get_search_list(db=db, limit=limit, search=search)
    return rsearch
