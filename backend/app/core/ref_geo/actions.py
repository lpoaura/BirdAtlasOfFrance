import logging
from typing import List, Optional

from geoalchemy2 import functions
from sqlalchemy.orm import Query, Session

from app.core.actions.crud import BaseReadOnlyActions

from .models import BibAreasTypes, LAreas

logger = logging.getLogger(__name__)


class BibAreasTypesActions(BaseReadOnlyActions[BibAreasTypes]):
    """Post actions with basic CRUD operations"""

    def get_id_from_code(self, db: Session, code: str) -> Optional[int]:
        q = db.query(self.model.id_type).filter(self.model.type_code == code)
        logger.debug(f"{q}")
        return q.first().id_type


bib_areas_types = BibAreasTypesActions(BibAreasTypes)


class LAreasActions(BaseReadOnlyActions[LAreas]):
    """Post actions with basic CRUD operations"""

    def query_data4features(self, db: Session) -> Query:
        q = db.query(
            LAreas.id_area,
            LAreas.area_code,
            LAreas.area_name,
            functions.ST_AsGeoJSON(functions.ST_Transform(LAreas.geom, 4326)).label("geometry"),
            # functions.ST_Envelope(LAreas.geom).label("bbox"),
        )
        return q

    def get_feature_list(
        self, db: Session, type_code: str = "COM", limit: Optional[int] = None
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
        q = q.filter(LAreas.id_type == id_type)
        if limit:
            q = q.limit(limit)
        logger.debug(q)
        return q.all()


bib_areas_types = BibAreasTypesActions(BibAreasTypes)
l_areas = LAreasActions(LAreas)
