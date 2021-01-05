from geoalchemy2 import Geometry
from sqlalchemy import Column, Float, Integer, String
from sqlalchemy.dialects.postgresql import JSONB

from app.utils.db import Base


class AreaKnowledgeLevel(Base):
    __tablename__ = "mv_area_knowledge_level"
    __table_args__ = {"schema": "atlas"}
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
