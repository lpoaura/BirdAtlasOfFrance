from geoalchemy2 import Geometry
from sqlalchemy import (DECIMAL, Column, Float, ForeignKey, Integer, String,
                        Table)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship

from app.utils.db import Base, metadata


class AreaKnowledgeLevel(Base):
    __tablename__ = "mv_area_knowledge_level"
    __table_args__ = {
        "schema": "atlas",
    }
    id_area = Column(Integer, primary_key=True)
    id_type = Column(Integer)
    area_name = Column(String)
    area_code = Column(String)
    allperiod_count_taxa_old = Column(Integer)
    allperiod_count_taxa_new = Column(Integer)
    allperiod_percent_knowledge = Column(Float)
    breeding_count_taxa_old = Column(Integer)
    breeding_count_taxa_new = Column(Integer)
    breeding_percent_knowledge = Column(Float)
    wintering_count_taxa_old = Column(Integer)
    wintering_count_taxa_new = Column(Integer)
    wintering_percent_knowledge = Column(Float)
    geom = Column(Geometry(geometry_type="MULTIPOLYGON", srid=4326))
    geojson_geom = Column(JSONB)


MvAreaKnowledgeLevel = Table(
    "mv_area_knowledge_level",
    metadata,
    Column("id_area", Integer, primary_key=True),
    Column("id_type", Integer),
    Column("area_name", String),
    Column("area_code", String),
    Column("allperiod_count_taxa_old", Integer),
    Column("allperiod_count_taxa_new", Integer),
    Column("allperiod_percent_knowledge", Float),
    Column("breeding_count_taxa_old", Integer),
    Column("breeding_count_taxa_new", Integer),
    Column("breeding_percent_knowledge", Float),
    Column("wintering_count_taxa_old", Integer),
    Column("wintering_count_taxa_new", Integer),
    Column("wintering_percent_knowledge", Float),
    Column("geom", Geometry(geometry_type="MULTIPOLYGON", srid=4326)),
    Column("geojson_geom", JSONB),
    schema="atlas",
)


class AreaDashboard(Base):
    __tablename__ = "mv_area_dashboard"
    __table_args__ = {
        "schema": "atlas",
    }
    id_area = Column(Integer, primary_key=True)
    last_date = Column(Integer)
    data_count = Column(Integer)
    taxa_count_all_period = Column(Integer)
    taxa_count_wintering = Column(Integer)
    taxa_count_breeding = Column(Integer)
    prospecting_hours_other_period = Column(DECIMAL)
    prospecting_hours_wintering = Column(DECIMAL)
    prospecting_hours_breeding = Column(DECIMAL)


class Epoc(Base):
    __tablename__ = "t_epoc"
    __table_args__ = {
        "schema": "atlas",
    }
    id_epoc = Column(Integer, primary_key=True)
    id_ff = Column(String)
    status = Column(String)
    rang_rsv = Column(Integer)
    id_area = Column(Integer, ForeignKey("ref_geo.l_areas.id_area"))
    area = relationship("LAreas", lazy="select")
    area_code = Column(String)
    geom = Column(Geometry(geometry_type="POINT", srid=4326))
    geojson = Column(JSONB)


class TaxonCountClassesByTerritory(Base):
    __tablename__ = "mv_taxon_count_classes_by_territory"
    __table_args__ = {
        "schema": "atlas",
    }
    id = Column(Integer, primary_key=True)
    period = Column(String)
    id_area = Column(Integer)
    ntile = Column(Integer)
    min = Column(Integer)
    max = Column(Integer)
