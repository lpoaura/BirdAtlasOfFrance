#!/usr/bin/python
"""Search routers module"""

import logging
from typing import Any, List, Optional

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.utils.db import get_db

from .actions import mv_autocomplete_search
from .schemas import MvAutocompleteSearchSchema

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/search", response_model=List[MvAutocompleteSearchSchema], tags=["core"])
def search(
    db: Session = Depends(get_db),
    limit: int = 10,
    search: Optional[str] = None,
    type_code: Optional[str] = None,
) -> Any:
    rsearch = mv_autocomplete_search.get_search_list(
        db=db, limit=limit, search=search, type_code=type_code
    )
    return rsearch
