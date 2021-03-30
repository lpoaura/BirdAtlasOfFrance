from sqlalchemy import Boolean, Column, Date, DateTime, Integer, String, Text

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
