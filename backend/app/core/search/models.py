#!/usr/bin/python
"""Search sqlalchemy models module"""

import logging

from sqlalchemy import Column, Integer, String

from app.utils.db import Base

logger = logging.getLogger(__name__)


class MvAutocompleteSearch(Base):
    __tablename__ = "mv_autocomplete_search"
    __table_args__ = {"schema": "atlas"}
    id = Column(Integer, primary_key=True)
    type_name = Column(String)
    type_code = Column(String)
    search_string = Column(String)
    code = Column(String)
    name = Column(String)
    html_repr = Column(String)
