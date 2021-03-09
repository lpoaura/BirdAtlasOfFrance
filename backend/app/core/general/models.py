from sqlalchemy import Column, Integer, Table

from app.utils.db import Base, metadata


class GeneralStats(Base):
    __tablename__ = "mv_general_stats"
    __table_args__ = {
        "schema": "atlas",
    }
    id = Column(Integer, primary_key=True)
    count_taxa_all_period = Column(Integer)
    count_taxa_breeding = Column(Integer)
    count_taxa_wintering = Column(Integer)
    prospecting_hours_all_period = Column(Integer)
    prospecting_hours_breeding = Column(Integer)
    prospecting_hours_wintering = Column(Integer)


mv_general_stats = Table(
    "mv_general_stats",
    metadata,
    Column("count_taxa_all_period", Integer),
    Column("count_taxa_breeding", Integer),
    Column("count_taxa_wintering", Integer),
    Column("prospecting_hours_all_period", Integer),
    Column("prospecting_hours_breeding", Integer),
    Column("prospecting_hours_wintering", Integer),
)
