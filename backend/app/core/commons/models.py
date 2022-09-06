from sqlalchemy import Boolean, Column, Date, DateTime, Integer, String, Text
from sqlalchemy.dialects.postgresql import ARRAY

from app.utils.db import Base


class DataForAtlas(Base):
    __tablename__ = "mv_data_for_atlas"
    __table_args__ = {
        "schema": "atlas",
    }
    id_data = Column(Integer, primary_key=True)
    id_form = Column(Integer)
    id_area = Column(Integer, nullable=False)
    cd_nom = Column(Integer, nullable=False)
    date_min = Column(Date, nullable=False)
    date_min = Column(Date, nullable=False)
    new_data_all_period = Column(Boolean)
    old_data_all_period = Column(Boolean)
    new_data_wintering = Column(Boolean)
    old_data_wintering = Column(Boolean)
    new_data_all_period = Column(Boolean)
    old_data_breeding = Column(Boolean)
    new_data_breeding = Column(Boolean)
    new_data_breeding = Column(Boolean)
    bird_breed_code = Column(Integer)


class FormsForAtlas(Base):
    __tablename__ = "mv_forms_for_atlas"
    __table_args__ = {
        "schema": "atlas",
    }
    id_form_universal = Column(String, primary_key=True, nullable=False)
    id_form_local = Column(Integer, nullable=False)
    id_area = Column(Integer)
    site = Column(String)
    timestamp_start = Column(DateTime, nullable=False)
    timestamp_stop = Column(DateTime, nullable=False)
    timelength_secs = Column(Integer)
    is_wintering = Column(Boolean)
    is_breeding = Column(Boolean)
    is_epoc = Column(Boolean)
    full_form = Column(Boolean)
    geom = Column(Boolean)
    comment = Column(Text)
    protocol = Column(String)


class AreaKnowledgeTaxaList(Base):
    __tablename__ = "mv_area_knowledge_list_taxa"
    __table_args__ = {"schema": "atlas"}
    id_area = Column(Integer, primary_key=True)
    cd_nom = Column(Integer, primary_key=True)
    sci_name = Column(String)
    common_name_fr = Column(String)
    common_name_en = Column(String)
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
    phenology = Column(ARRAY(item_type=Integer))
