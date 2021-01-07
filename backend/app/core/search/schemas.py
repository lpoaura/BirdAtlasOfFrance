#!/usr/bin/python
"""Search pydantic schemas module"""

import logging
from typing import List, Optional

from pydantic import BaseModel

logger = logging.getLogger(__name__)


# Shared properties
class MvAutocompleteSearchSchema(BaseModel):
    type_name: str
    code: str
    name: str
    html_repr: str

    class Config:
        orm_mode = True
