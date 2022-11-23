#!/usr/bin/python
"""Search sqlalchemy models module"""

import logging
from xmlrpc.client import Boolean

from sqlalchemy import Boolean, Column, Date, ForeignKey, Integer, String
from sqlalchemy.dialects.postgresql import INT4RANGE, JSON

from app.core.ref_geo.models import LAreas
from app.utils.db import Base

logger = logging.getLogger(__name__)


class MvTerritoryAltitudeRanges(Base):
    __tablename__ = "mv_territory_altitude_ranges"
    __table_args__ = {"schema": "atlas"}
    id = Column(Integer, primary_key=True)
    id_area = Column(Integer)
    range = Column(INT4RANGE)


class MvAltitudeDistribution(Base):
    __tablename__ = "mv_alti_distribution"
    __table_args__ = {"schema": "atlas"}
    id = Column(Integer, primary_key=True)
    id_area = Column(Integer)
    cd_nom = Column(Integer)
    range = Column(INT4RANGE)
    count_all_period = Column(Integer)
    count_breeding = Column(Integer)
    count_wintering = Column(Integer)


class MvAltitudeTerritory(Base):
    __tablename__ = "mv_alti_territory"
    __table_args__ = {"schema": "atlas"}
    id = Column(Integer, primary_key=True)
    id_area = Column(Integer)
    percentage = Column(Integer)
    range = Column(INT4RANGE)


class MvTaxaGlobalPhenology(Base):
    __tablename__ = "mv_taxa_global_phenology"
    __table_args__ = {"schema": "atlas"}
    id = Column(Integer, primary_key=True)
    id_area = Column(Integer)
    cd_nom = Column(Integer)
    period = Column(String)
    decade = Column(Integer)
    count_data = Column(Integer)
    count_list = Column(Integer)


class THistoricAtlasesInfo(Base):
    __tablename__ = "t_historic_atlases_info"
    __table_args__ = {"schema": "atlas"}
    id = Column(Integer, primary_key=True)
    id_territory = Column(ForeignKey(LAreas.id_area), nullable=True)
    atlas_period = Column(String)
    date_start = Column(Date)
    date_end = Column(Date)
    season_period = Column(String)
    description = Column(String)
    is_active = Column(Boolean)


class THistoricAtlasesData(Base):
    __tablename__ = "t_historic_atlases_data"
    __table_args__ = {"schema": "atlas"}
    id = Column(Integer, primary_key=True)
    id_historic_atlas_info = Column(ForeignKey(THistoricAtlasesInfo.id), nullable=False)
    id_area = Column(ForeignKey(LAreas.id_area), nullable=False)
    cd_nom = Column(Integer)
    status = Column(String)
