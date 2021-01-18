#!/usr/bin/python
"""Search pydantic schemas module"""

import logging
from typing import List

from pydantic import BaseModel

logger = logging.getLogger(__name__)


# Shared properties
class MvSearchBaseSchema(BaseModel):
    code: str
    name: str
    html_repr: str


class MvSearchAreasSchema(MvSearchBaseSchema):
    id: int
    type_name: str
    type_code: str
    bounds: List[List]

    class Config:
        orm_mode = True


class MvSearchTaxaSchema(MvSearchBaseSchema):
    class Config:
        orm_mode = True
