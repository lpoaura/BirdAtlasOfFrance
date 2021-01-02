from geoalchemy2 import Geometry
from sqlalchemy import BigInteger, Column, DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.core.db import Base


class BibAreasTypes(Base):
    __tablename__ = "bib_areas_types"
    __table_args__ = {"schema": "ref_geo"}
    id_type = Column(Integer, primary_key=True)
    type_name = Column(String)
    type_code = Column(String)
    type_desc = Column(String)
    ref_name = Column(String)
    ref_version = Column(String)
    num_version = Column(String)


class LAreas(Base):
    __tablename__ = "l_areas"
    __table_args__ = {"schema": "ref_geo"}
    id_area = Column(Integer, primary_key=True)
    id_type = Column(Integer, ForeignKey("ref_geo.bib_areas_types.id_type"))
    area_name = Column(String)
    area_code = Column(String)
    geom = Column(Geometry("GEOMETRY", 2154))
    source = Column(String)
    area_type = relationship("BibAreasTypes", lazy="select")


class LiMunicipalities(Base):
    __tablename__ = "li_municipalities"
    __table_args__ = {"schema": "ref_geo"}
    id_municipality = Column(Integer, primary_key=True)
    id_area = Column(Integer)
    status = Column(String)
    insee_com = Column(String)
    nom_com = Column(String)
    insee_arr = Column(String)
    nom_dep = Column(String)
    insee_dep = Column(String)
    nom_reg = Column(String)
    insee_reg = Column(String)
    code_epci = Column(String)
    plani_precision = Column(Float)
    siren_code = Column(String)
    canton = Column(String)
    population = Column(Integer)
    multican = Column(String)
    cc_nom = Column(String)
    cc_siren = Column(BigInteger)
    cc_nature = Column(String)
    cc_date_creation = Column(String)
    cc_date_effet = Column(String)
    insee_commune_nouvelle = Column(String)
    meta_create_date = Column(DateTime)
    meta_update_date = Column(DateTime)
