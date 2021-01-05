from geoalchemy2 import Geometry, Multi
from sqlalchemy import BigInteger, Column, DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship

from app.utils.db import Base


class AreaKnowledgeLevel(Base):
    __tablename__ = "mv_area_knowledge_level"
    __table_args__ = {"schema": "atlas"}
    id_area = Column(Integer, primary_key=True)
    id_type = Column(Integer)
    area_name = Column(String)
    area_code = Column(String)
    count_taxa_old = Column(Integer)
    count_taxa_new = Column(Integer)
    percent_knowledge = Column(Float)
    geom = Column(Geometry(geometry_type="MULTIPOLYGON", srid=4326))
    geojson_geom = Column(JSONB)
