#!/usr/bin/python
"""Search sqlalchemy models module"""

import logging

from sqlalchemy import Column, Integer, String
from sqlalchemy.dialects.postgresql import JSON

from app.utils.db import Base

logger = logging.getLogger(__name__)


class MvSearchAreas(Base):
    __tablename__ = "mv_search_areas"
    __table_args__ = {"schema": "atlas"}
    id = Column(Integer, primary_key=True)
    type_name = Column(String)
    type_code = Column(String)
    search_string = Column(String)
    code = Column(String)
    name = Column(String)
    html_repr = Column(String)
    bounds = Column(JSON)


class MvSearchTaxa(Base):
    __tablename__ = "mv_search_taxa"
    __table_args__ = {"schema": "atlas"}
    code = Column(Integer, primary_key=True)
    search_string = Column(String)
    common_name_fr = Column(String)
    common_name_en = Column(String)
    sci_name = Column(String)
    name = Column(String)
    html_repr = Column(String)
