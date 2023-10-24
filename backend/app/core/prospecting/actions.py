import logging
import time
from typing import List, Optional

from geoalchemy2 import functions

# from sqlalchemy_utils.functions import json_sql
from sqlalchemy import func
from sqlalchemy.orm import Query, Session, aliased

from app.core.actions.crud import BaseReadOnlyActions
from app.core.commons.models import AreaKnowledgeTaxaList, DataForAtlas
from app.core.ref_geo.actions import bib_areas_types
from app.core.ref_geo.models import BibAreasTypes, LAreas

from .models import (
    AreaDashboard,
    AreaKnowledgeLevel,
    Epoc,
    RealizedEpoc,
    TaxonCountClassesByTerritory,
)

logger = logging.getLogger(__name__)


class AreaKnowledgeLevelActions(BaseReadOnlyActions[AreaKnowledgeLevel]):
    """Post actions with basic CRUD operations"""

    def query_data4features(self, db: Session) -> Query:
        q = db.query(
            AreaKnowledgeLevel.id_area.label("id"),
            func.json_build_object(
                "area_code",
                AreaKnowledgeLevel.area_code,
                "area_name",
                AreaKnowledgeLevel.area_name,
                "all_period",
                func.json_build_object(
                    "old_count",
                    AreaKnowledgeLevel.allperiod_count_taxa_old,
                    "new_count",
                    AreaKnowledgeLevel.allperiod_count_taxa_new,
                    "percent_knowledge",
                    AreaKnowledgeLevel.allperiod_percent_knowledge,
                ),
                "breeding",
                func.json_build_object(
                    "old_count",
                    AreaKnowledgeLevel.breeding_count_taxa_old,
                    "new_count",
                    AreaKnowledgeLevel.breeding_count_taxa_new,
                    "percent_knowledge",
                    AreaKnowledgeLevel.breeding_percent_knowledge,
                ),
                "wintering",
                func.json_build_object(
                    "old_count",
                    AreaKnowledgeLevel.wintering_count_taxa_old,
                    "new_count",
                    AreaKnowledgeLevel.wintering_count_taxa_new,
                    "percent_knowledge",
                    AreaKnowledgeLevel.wintering_percent_knowledge,
                ),
            ).label("properties"),
            AreaKnowledgeLevel.geojson_geom.label("geometry"),
        )
        return q

    def get_feature_list(
        self,
        db: Session,
        type_code: str = "COM",
        limit: Optional[int] = None,
        envelope: Optional[List] = None,
    ) -> List:
        """[summary]

        Args:
            db (Session): [description]
            type_code (str, optional): [description]. Defaults to "COM".
            limit (Optional[int], optional): [description]. Defaults to None.

        Returns:
            List: [description]
        """
        id_type = bib_areas_types.get_id_from_code(db=db, code=type_code)
        query = self.query_data4features(db=db)
        query = query.filter(AreaKnowledgeLevel.id_type == id_type)
        if envelope:
            query = query.filter(
                functions.ST_Intersects(
                    AreaKnowledgeLevel.geom,
                    functions.ST_MakeEnvelope(
                        envelope[0], envelope[1], envelope[2], envelope[3], 4326
                    ),
                ),
            )
        if limit:
            query = query.limit(limit)
        return query.all()


class AreaKnowledgeTaxaListActions(BaseReadOnlyActions[AreaKnowledgeLevel]):
    """Post actions with basic CRUD operations"""

    def get_area_taxa_list(self, db: Session, id_area: int, limit: Optional[int] = None) -> List:
        query = db.query(
            AreaKnowledgeTaxaList.id_area,
            AreaKnowledgeTaxaList.cd_nom,
            AreaKnowledgeTaxaList.sci_name,
            AreaKnowledgeTaxaList.common_name_fr,
            AreaKnowledgeTaxaList.common_name_en,
            func.json_build_object(
                "last_obs",
                AreaKnowledgeTaxaList.all_period_last_obs,
                "new_count",
                AreaKnowledgeTaxaList.all_period_count_data_new,
                "old_count",
                AreaKnowledgeTaxaList.all_period_count_data_old,
            ).label("all_period"),
            func.json_build_object(
                "last_obs",
                AreaKnowledgeTaxaList.wintering_last_obs,
                "new_count",
                AreaKnowledgeTaxaList.wintering_count_data_new,
                "old_count",
                AreaKnowledgeTaxaList.wintering_count_data_old,
            ).label("wintering"),
            func.json_build_object(
                "last_obs",
                AreaKnowledgeTaxaList.breeding_last_obs,
                "new_count",
                AreaKnowledgeTaxaList.breeding_count_data_new,
                "new_status",
                AreaKnowledgeTaxaList.breeding_status_new,
                "old_count",
                AreaKnowledgeTaxaList.breeding_count_data_old,
                "old_status",
                AreaKnowledgeTaxaList.breeding_status_old,
            ).label("breeding"),
            AreaKnowledgeTaxaList.phenology,
        ).filter(AreaKnowledgeTaxaList.id_area == id_area)

        if limit:
            query = query.limit(limit)
        print(query)
        return query.order_by(AreaKnowledgeTaxaList.common_name_fr).all()


class AreaDashboardActions(BaseReadOnlyActions[AreaDashboard]):
    """Post actions with basic CRUD operations"""

    def get_area_stats(self, db: Session, id_area: int) -> Query:
        """querying general area stats

        Args:
            db (Session): Database session
            id_area (int): Area unique id

        Returns:
            Query: Area general stats
        """
        q = db.query(
            AreaDashboard.last_date,
            AreaDashboard.data_count,
            AreaDashboard.taxa_count_all_period,
            AreaDashboard.taxa_count_wintering,
            AreaDashboard.taxa_count_breeding,
            func.coalesce(AreaDashboard.prospecting_hours_other_period, 0).label(
                "prospecting_hours_other_period"
            ),
            func.coalesce(AreaDashboard.prospecting_hours_wintering, 0).label(
                "prospecting_hours_wintering"
            ),
            func.coalesce(AreaDashboard.prospecting_hours_breeding, 0).label(
                "prospecting_hours_breeding"
            ),
        ).filter(AreaDashboard.id_area == id_area)
        return q.first()

    def get_time_distribution(self, db: Session, id_area: int, time_unit: str = "month") -> Query:
        """get data distribution in time

        Args:
            db (Session): Database session
            id_area (int): Area unique id
            time_unit (str, optional): Time unit identifier. Defaults to "month".

        Returns:
            Query: data distribution in time
        """
        q = (
            db.query(
                func.extract(time_unit, DataForAtlas.date_min).label("label"),
                # func.extract("year", DataForAtlas.date_min).label("year"),
                func.count(DataForAtlas.id_data).label("count_data"),
            )
            .filter(DataForAtlas.id_area == id_area)
            .filter(DataForAtlas.new_data_all_period)
            .group_by(func.extract(time_unit, DataForAtlas.date_min))
            # .group_by(func.extract("year", DataForAtlas.date_min))
            .order_by(func.extract(time_unit, DataForAtlas.date_min))
            # .order_by(func.extract("year", DataForAtlas.date_min))
        )

        return q.all()

    def get_intersected_areas(self, db: Session, id_area: int, type_code: str) -> List:
        """[summary]

        Args:
            db (Session): [description]
            id_area (int): [description]

        Returns:
            Query: [description]
        """
        area = aliased(LAreas)
        q = (
            db.query(LAreas.id_area, LAreas.area_code, LAreas.area_name)
            .join(BibAreasTypes, BibAreasTypes.id_type == LAreas.id_type)
            .filter(functions.ST_Intersects(LAreas.geom, area.geom))
            .filter(area.id_area == id_area)
            .filter(BibAreasTypes.type_code == type_code)
            .order_by(LAreas.area_name)
        )
        return q.all()

    def get_area_epocs(self, db: Session, id_area: int) -> Query:
        q = (
            db.query(Epoc.id_epoc, Epoc.id_ff, Epoc.status, Epoc.rang_rsv)
            .join(LAreas, LAreas.id_area == Epoc.id_area)
            .filter(LAreas.id_area == id_area)
            .order_by(Epoc.status)
            .order_by(Epoc.rang_rsv)
        )
        logger.debug(q)
        return q.all()


class EpocActions(BaseReadOnlyActions[Epoc]):
    def get_epocs(
        self,
        db: Session,
        id_area: Optional[int] = None,
        status: Optional[str] = None,
        envelope: Optional[List] = None,
    ) -> List:
        """[summary]

        Args:
            db (Session): DB Session
            envelope (Optional[List], optional): Filtering by bounding box. Defaults to None.
            id_area (Optional[int], optional): Filtering by area. Defaults to None.
            status (Optional[str], optional): Filtering by status. Defaults to None

        Returns:
            Query: Return
        """
        query = db.query(
            Epoc.id_epoc,
            Epoc.id_ff,
            Epoc.status,
            Epoc.rang_rsv,
            Epoc.geojson.label("geometry"),
        )
        query = query.filter(Epoc.status == status) if status else query
        query = query.filter(Epoc.id_area == id_area) if id_area else query
        query = (
            query.filter(
                functions.ST_Intersects(
                    Epoc.geom,
                    functions.ST_MakeEnvelope(
                        envelope[0], envelope[1], envelope[2], envelope[3], 4326
                    ),
                ),
            )
            if envelope
            else query
        )
        return query.all()


class RealizedEpocActions(BaseReadOnlyActions[RealizedEpoc]):
    def get_realized_epocs(
        self,
        db: Session,
        id_area: Optional[int] = None,
        project_code: Optional[str] = None,
        envelope: Optional[List] = None,
    ) -> List:
        """[summary]

        Args:
            db (Session): DB Session
            envelope (Optional[List], optional): Filtering by bounding box. Defaults to None.
            id_area (Optional[int], optional): Filtering by area. Defaults to None.
            status (Optional[str], optional): Filtering by status. Defaults to None

        Returns:
            Query: Return
        """
        q = db.query(
            RealizedEpoc.id,
            RealizedEpoc.project_code,
            RealizedEpoc.timelength_secs,
            RealizedEpoc.date,
            RealizedEpoc.time,
            functions.ST_AsGeoJSON(RealizedEpoc.geom).label("geometry"),
        )
        q = q.filter(RealizedEpoc.project_code == project_code) if project_code else q
        q = q.filter(RealizedEpoc.id_area == id_area) if id_area else q
        q = (
            q.filter(
                functions.ST_Intersects(
                    RealizedEpoc.geom,
                    functions.ST_MakeEnvelope(
                        envelope[0], envelope[1], envelope[2], envelope[3], 4326
                    ),
                ),
            )
            if envelope
            else q
        )
        return q.all()


class TaxonCountClassesByTerritoryActions(BaseReadOnlyActions[TaxonCountClassesByTerritory]):
    def get_classes(self, db: Session, id_area: int, period: str = "all_period") -> List:
        """[summary]

        Args:
            db (Session): DB Session
            envelope (Optional[List], optional): Filtering by bounding box. Defaults to None.
            id_area (Optional[int], optional): Filtering by area. Defaults to None.
            status (Optional[str], optional): Filtering by status. Defaults to None

        Returns:
            Query: Return
        """
        q = db.query(
            TaxonCountClassesByTerritory.ntile,
            TaxonCountClassesByTerritory.min,
            TaxonCountClassesByTerritory.max,
        ).order_by(TaxonCountClassesByTerritory.ntile)
        q = q.filter(
            TaxonCountClassesByTerritory.id_area == id_area,
            TaxonCountClassesByTerritory.period == period,
        )
        return q.all()


area_knowledge_level = AreaKnowledgeLevelActions(AreaKnowledgeLevel)
area_knowledge_taxa_list = AreaKnowledgeTaxaListActions(AreaKnowledgeTaxaList)
area_dashboard = AreaDashboardActions(AreaDashboard)
epoc = EpocActions(Epoc)
realized_epoc = RealizedEpocActions(RealizedEpoc)
taxon_count_classes_by_territory = TaxonCountClassesByTerritoryActions(
    TaxonCountClassesByTerritory
)
