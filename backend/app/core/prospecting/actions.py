import logging
from typing import List, Optional

from geoalchemy2 import functions

# from sqlalchemy_utils.functions import json_sql
from sqlalchemy import func
from sqlalchemy.orm import Query, Session

from app.core.actions.crud import BaseReadOnlyActions
from app.core.ref_geo.actions import bib_areas_types

from .models import AreaKnowledgeLevel

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
        q = self.query_data4features(db=db)
        q = q.filter(AreaKnowledgeLevel.id_type == id_type)
        if envelope:
            q = q.filter(
                functions.ST_Intersects(
                    AreaKnowledgeLevel.geom,
                    functions.ST_MakeEnvelope(
                        envelope[0], envelope[1], envelope[2], envelope[3], 4326
                    ),
                ),
            )
        if limit:
            q = q.limit(limit)
        return q.all()


area_knowledge_level = AreaKnowledgeLevelActions(AreaKnowledgeLevel)
