import logging
from typing import List, Optional

from geoalchemy2 import functions as geofunc
from sqlalchemy import func
from sqlalchemy.orm import Query, Session

from app.core.actions.crud import BaseReadOnlyActions
from app.core.commons.models import AreaKnowledgeTaxaList
from app.core.ref_geo.models import LAreas

logger = logging.getLogger(__name__)


class TaxaDistributionActions(BaseReadOnlyActions[AreaKnowledgeTaxaList]):
    """Post actions with basic CRUD operations"""

    def taxa_distribution(
        self,
        db: Session,
        period: str,
        cd_nom: int,
        envelope: Optional[List] = None,
    ) -> List:
        status_field = {
            "breeding_old": {
                "condition": AreaKnowledgeTaxaList.breeding_count_data_old > 0,
                "status": AreaKnowledgeTaxaList.breeding_status_old,
            },
            "breeding_new": {
                "condition": AreaKnowledgeTaxaList.breeding_count_data_new > 0,
                "status": AreaKnowledgeTaxaList.breeding_status_new,
            },
            "wintering_old": {
                "condition": AreaKnowledgeTaxaList.wintering_count_data_old > 0,
                "status": "Presence",
            },
            "wintering_new": {
                "condition": AreaKnowledgeTaxaList.wintering_count_data_new > 0,
                "status": "Presence",
            },
            "all_period_old": {
                "condition": AreaKnowledgeTaxaList.all_period_count_data_old > 0,
                "status": "Presence",
            },
            "all_period_new": {
                "condition": AreaKnowledgeTaxaList.all_period_count_data_old > 0,
                "status": "Presence",
            },
        }
        q = (
            db.query(
                AreaKnowledgeTaxaList.id_area.label("id"),
                func.json_build_object("status", status_field[period]["status"]).label(
                    "properties"
                ),
                geofunc.ST_AsGeoJSON(
                    geofunc.ST_Transform(geofunc.ST_Centroid(LAreas.geom), 4326)
                ).label("geometry"),
            )
            .join(LAreas, LAreas.id_area == AreaKnowledgeTaxaList.id_area)
            .filter(AreaKnowledgeTaxaList.cd_nom == cd_nom)
            .filter(status_field[period]["condition"])
        )

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

        logger.debug(f"<taxa_distribution> q {q}")
        return q.all()


taxa_distrib = TaxaDistributionActions(AreaKnowledgeTaxaList)
