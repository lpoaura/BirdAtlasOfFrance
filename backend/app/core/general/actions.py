import logging
from typing import List, Optional

from geoalchemy2 import functions

# from sqlalchemy_utils.functions import json_sql
from sqlalchemy import and_, func
from sqlalchemy.orm import Query, Session

from app.core.actions.crud import BaseReadOnlyActions

from ..prospecting.models import AreaKnowledgeLevel
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
                "all_period",
                GeneralStats.prospecting_hours_all_period,
                "breeding",
                GeneralStats.prospecting_hours_breeding,
                "wintering",
                GeneralStats.prospecting_hours_wintering,
            ).label("prospecting_hours"),
        )
        return q.first()


class KnowledgeLevelGeneralStatsActions(BaseReadOnlyActions[AreaKnowledgeLevel]):
    """[summary]

    Args:
        BaseReadOnlyActions ([type]): [description]
    """

    def query(self, db: Session) -> Query:
        """[summary]

        Args:
            db (Session): [description]

        Returns:
            Query: [description]
        """
        q = db.query(
            func.count(AreaKnowledgeLevel.id_area)
            .filter(
                and_(
                    AreaKnowledgeLevel.allperiod_percent_knowledge >= 0,
                    AreaKnowledgeLevel.allperiod_percent_knowledge < 0.25,
                )
            )
            .label("from0to25"),
            func.count(AreaKnowledgeLevel.id_area)
            .filter(
                and_(
                    AreaKnowledgeLevel.allperiod_percent_knowledge >= 0.25,
                    AreaKnowledgeLevel.allperiod_percent_knowledge < 0.5,
                )
            )
            .label("from25to50"),
            func.count(AreaKnowledgeLevel.id_area)
            .filter(
                and_(
                    AreaKnowledgeLevel.allperiod_percent_knowledge >= 0.5,
                    AreaKnowledgeLevel.allperiod_percent_knowledge < 0.75,
                )
            )
            .label("from50to75"),
            func.count(AreaKnowledgeLevel.id_area)
            .filter(
                and_(
                    AreaKnowledgeLevel.allperiod_percent_knowledge >= 0.75,
                    AreaKnowledgeLevel.allperiod_percent_knowledge < 1,
                )
            )
            .label("from75to100"),
            func.count(AreaKnowledgeLevel.id_area)
            .filter(AreaKnowledgeLevel.allperiod_percent_knowledge >= 1)
            .label("over100"),
        )
        logger.debug(q)
        return q.first()


general_stats = GeneralStatsActions(GeneralStats)
knowledge_level_general_stats = KnowledgeLevelGeneralStatsActions(
    KnowledgeLevelGeneralStatsActions
)
