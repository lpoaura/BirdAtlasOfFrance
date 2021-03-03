import logging
from typing import List, Optional

from geoalchemy2 import functions

# from sqlalchemy_utils.functions import json_sql
from sqlalchemy import func
from sqlalchemy.orm import Query, Session

from app.core.actions.crud import BaseReadOnlyActions

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


general_stats = GeneralStatsActions(GeneralStats)
