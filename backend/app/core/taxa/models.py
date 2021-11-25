#!/usr/bin/python
"""Search sqlalchemy models module"""

import logging

from sqlalchemy import Column, Integer, String
from sqlalchemy.dialects.postgresql import INT4RANGE, JSON

from app.utils.db import Base

logger = logging.getLogger(__name__)


class MvTaxaAltitudeDistribution(Base):
    __tablename__ = "mv_taxa_alti_distribution"
    __table_args__ = {"schema": "atlas"}
    id = Column(Integer, primary_key=True)
    id_area = Column(Integer)
    cd_nom = Column(Integer)
    range = Column(INT4RANGE)
    count = Column(String)
