#!/usr/bin/python
"""Search pydantic schemas module"""

import logging
from typing import List, Optional, Union

from pydantic import BaseModel

logger = logging.getLogger(__name__)


# Shared properties
class MvSearchBaseSchema(BaseModel):
    code: Union[str, int]
    name: str
    html_repr: str


class MvSearchAreasSchema(MvSearchBaseSchema):
    id: int
    type_name: str
    type_code: str
    bounds: List[List]

    class Config:
        from_attributes = True


class MvSearchTaxaSchema(MvSearchBaseSchema):
    common_name_fr: Optional[str]
    common_name_en: Optional[str]
    sci_name: Optional[str]

    class Config:
        from_attributes = True
