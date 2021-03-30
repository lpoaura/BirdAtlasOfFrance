import logging
from typing import List, Optional

from geoalchemy2 import functions as geofunc
# from sqlalchemy_utils.geofunc import json_sql
from sqlalchemy import func
from sqlalchemy.orm import Query, Session

from app.core.actions.crud import BaseReadOnlyActions
from app.utils.db import database

from .models import BibAreasTypes, LAreas

logger = logging.getLogger(__name__)


class BibAreasTypesActions(BaseReadOnlyActions[BibAreasTypes]):
    """Post actions with basic CRUD operations"""

    def get_id_from_code(self, db: Session, code: str) -> Optional[int]:
        q = db.query(self.model.id_type).filter(self.model.type_code == code)
        return q.first().id_type


bib_areas_types = BibAreasTypesActions(BibAreasTypes)


class LAreasActions(BaseReadOnlyActions[LAreas]):
    """Post actions with basic CRUD operations"""

    def query_data4features(self, db: Session) -> Query:
        q = db.query(
            LAreas.id_area.label("id"),
            func.json_build_object(
                "area_code",
                LAreas.area_code,
                "area_name",
                LAreas.area_name,
            ).label("properties"),
            geofunc.ST_AsGeoJSON(geofunc.ST_Transform(LAreas.geom, 4326)).label("geometry"),
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
        # logger.debug(f"Q {q}\n{type(q.)}\n{dir(q)}")
        q = q.filter(LAreas.id_type == id_type)
        if envelope:
            q = q.filter(
                geofunc.ST_Intersects(
                    LAreas.geom,
                    geofunc.ST_Transform(
                        geofunc.ST_MakeEnvelope(
                            envelope[0], envelope[1], envelope[2], envelope[3], 4326
                        ),
                        2154,
                    ),
                )
            )
        logger.debug("\n".join([f"{o}: {dir(o)}\t{type(o)}" for o in dir(q)]))
        if limit:
            q = q.limit(limit)

        return q.all()


bib_areas_types = BibAreasTypesActions(BibAreasTypes)
l_areas = LAreasActions(LAreas)
