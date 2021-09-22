import logging
import time
from typing import List, Optional

from geoalchemy2 import functions as geofunc
from sqlalchemy import and_, func
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


class LAreasActions(BaseReadOnlyActions[LAreas]):
    """Post actions with basic CRUD operations"""

    def query_data4features(self, db: Session, bbox: bool = False) -> Query:
        geom = (
            geofunc.ST_AsGeoJSON(geofunc.ST_Envelope(geofunc.ST_Transform(LAreas.geom, 4326)))
            if bbox
            else LAreas.geojson_4326
        )

        q = db.query(
            LAreas.id_area.label("id"),
            func.json_build_object(
                "area_code",
                LAreas.area_code,
                "area_name",
                LAreas.area_name,
            ).label("properties"),
            geom.label("geometry"),
        )
        return q

    def get_by_id_area(self, db: Session, id_area: int) -> Query:
        return (
            db.query(
                LAreas.id_area.label("id"),
                LAreas.geojson_4326.label("geometry"),
            )
            .filter(LAreas.id_area == id_area)
            .first()
        )

    def get_by_area_type_and_code(
        self, db: Session, area_code: str, type_code: str, envelop: bool
    ) -> Query:
        id_type = bib_areas_types.get_id_from_code(db=db, code=type_code)
        geom = (
            geofunc.ST_Envelope(geofunc.ST_Transform(LAreas.geom, 4326))
            if envelop
            else geofunc.ST_Transform(LAreas.geom, 4326)
        )
        return (
            db.query(
                LAreas.id_area.label("id"),
                geofunc.ST_AsGeoJSON(geom).label("geometry"),
                func.json_build_object(
                    "area_code",
                    LAreas.area_code,
                    "area_name",
                    LAreas.area_name,
                ).label("properties"),
            )
            .filter(and_(LAreas.area_code == area_code, LAreas.id_type == id_type))
            .first()
        )

    def get_feature_list(
        self,
        db: Session,
        type_code: str = None,
        only_enable: bool = True,
        bbox: bool = False,
        coordinates: str = None,
        id_area: int = None,
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

        q = self.query_data4features(db=db, bbox=bbox)
        if type_code:
            id_type = bib_areas_types.get_id_from_code(db=db, code=type_code)
            q = q.filter(LAreas.id_type == id_type)
        q = q.filter(LAreas.enable) if only_enable else q
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
        if coordinates:
            q = q.filter(
                LAreas.geom.contains(
                    geofunc.ST_SetSRID(geofunc.ST_MakePoint(coordinates[0], coordinates[1]), 4326)
                )
            )
        q = q.filter(LAreas.id_area == id_area) if id_area else q
        q = q.limit(limit) if limit else q
        return q


bib_areas_types = BibAreasTypesActions(BibAreasTypes)
l_areas = LAreasActions(LAreas)
