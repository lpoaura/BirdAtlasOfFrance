import logging
from typing import List, Optional

from geoalchemy2 import functions

# from sqlalchemy_utils.functions import json_sql
from sqlalchemy import and_, func
from sqlalchemy.orm import Query, Session

from app.core.actions.crud import BaseReadOnlyActions

from ..prospecting.models import AreaKnowledgeLevel
from ..ref_geo.actions import bib_areas_types
from ..ref_geo.models import BibAreasTypes, LAreas
from .models import GeneralStats

logger = logging.getLogger(__name__)


class GeneralStatsActions(BaseReadOnlyActions[GeneralStats]):
    """Post actions with basic CRUD operations"""

    def query(self, db: Session) -> Query:

        q = db.query(
            func.json_build_object(
                "all_period",
                GeneralStats.count_taxa_all_period,
                "breeding",
                GeneralStats.count_taxa_breeding,
                "wintering",
                GeneralStats.count_taxa_wintering,
            ).label("count_taxa"),
            func.json_build_object(
                "other_period",
                func.coalesce(GeneralStats.prospecting_hours_other_period, 0),
                "breeding",
                func.coalesce(GeneralStats.prospecting_hours_breeding, 0),
                "wintering",
                func.coalesce(GeneralStats.prospecting_hours_wintering, 0),
            ).label("prospecting_hours"),
        )
        return q.first()


class KnowledgeLevelGeneralStatsActions(BaseReadOnlyActions[AreaKnowledgeLevel]):
    """[summary]

    Args:
        BaseReadOnlyActions ([type]): [description]
    """

    def query(self, db: Session, territory_id: int = None, period: str = "allperiod") -> Query:
        """[summary]

        Args:
            db (Session): [description]

        Returns:
            Query: [description]
        """
        percent_knowledge_fields = {
            "allperiod": AreaKnowledgeLevel.allperiod_percent_knowledge,
            "wintering": AreaKnowledgeLevel.wintering_percent_knowledge,
            "breeding": AreaKnowledgeLevel.breeding_percent_knowledge,
        }
        q = (
            db.query(
                func.avg(percent_knowledge_fields[period]).label("average"),
                func.count(AreaKnowledgeLevel.id_area)
                .filter(
                    and_(
                        percent_knowledge_fields[period] >= 0,
                        percent_knowledge_fields[period] < 0.25,
                    )
                )
                .label("from0to25"),
                func.count(AreaKnowledgeLevel.id_area)
                .filter(
                    and_(
                        percent_knowledge_fields[period] >= 0.25,
                        percent_knowledge_fields[period] < 0.5,
                    )
                )
                .label("from25to50"),
                func.count(AreaKnowledgeLevel.id_area)
                .filter(
                    and_(
                        percent_knowledge_fields[period] >= 0.5,
                        percent_knowledge_fields[period] < 0.75,
                    )
                )
                .label("from50to75"),
                func.count(AreaKnowledgeLevel.id_area)
                .filter(
                    and_(
                        percent_knowledge_fields[period] >= 0.75,
                        percent_knowledge_fields[period] < 1,
                    )
                )
                .label("from75to100"),
                func.count(AreaKnowledgeLevel.id_area)
                .filter(percent_knowledge_fields[period] >= 1)
                .label("over100"),
            )
            # .filter(LAreas.id_type == territory_type)
        )
        q = (
            q.filter(LAreas.id_area == territory_id)
            .filter(LAreas.geom.intersects(AreaKnowledgeLevel.geom))
            .group_by(LAreas.id_area)
            if territory_id
            else q
        )
        logger.debug(q)
        return q.first()


general_stats = GeneralStatsActions(GeneralStats)
knowledge_level_general_stats = KnowledgeLevelGeneralStatsActions(
    KnowledgeLevelGeneralStatsActions
)
