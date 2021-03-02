from geoalchemy2 import Geometry
from sqlalchemy import Column, Float, Integer, String, Table
from sqlalchemy.dialects.postgresql import JSONB

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


class AreaKnowledgeTaxaList(Base):
    __tablename__ = "mv_area_knowledge_list_taxa"
    __table_args__ = {
        "schema": "atlas",
    }
    id_area = Column(Integer, primary_key=True)
    cd_nom = Column(Integer, primary_key=True)
    sci_name = Column(String)
    common_name = Column(String)
    all_period_count_data_old = Column(Integer)
    all_period_count_data_new = Column(Integer)
    all_period_last_obs = Column(Integer)
    breeding_count_data_new = Column(Integer)
    breeding_status_new = Column(String)
    breeding_count_data_old = Column(Integer)
    breeding_status_old = Column(String)
    breeding_last_obs = Column(Integer)
    wintering_count_data_old = Column(Integer)
    wintering_count_data_new = Column(Integer)
    wintering_last_obs = Column(Integer)
