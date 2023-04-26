import logging
from typing import List, Optional

from geoalchemy2 import functions as geofunc
from sqlalchemy import func, cast
from sqlalchemy.orm import Session
from sqlalchemy.types import Integer

from app.core.actions.crud import BaseReadOnlyActions
from app.core.commons.models import AreaKnowledgeTaxaList
from app.core.ref_geo.models import LAreas

from .models import THistoricAtlasesData, THistoricAtlasesInfo

# from .models import MvTaxaAltitudeDistribution

logger = logging.getLogger(__name__)


class TaxaDistributionActions(BaseReadOnlyActions[AreaKnowledgeTaxaList]):
    """Post actions with basic CRUD operations"""

    def taxa_distribution(
        self,
        db: Session,
        period: str,
        cd_nom: int,
        grid: bool,
        envelope: Optional[List] = None,
    ) -> List:
        geom = (
            LAreas.geojson_4326
            if grid
            else geofunc.ST_AsGeoJSON(
                geofunc.ST_Transform(geofunc.ST_Centroid(LAreas.geom), 4326)
            )
        )
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
                "condition": AreaKnowledgeTaxaList.all_period_count_data_new > 0,
                "status": "Presence",
            },
        }

        query = (
            db.query(
                AreaKnowledgeTaxaList.id_area.label("id"),
                func.json_build_object(
                    "status",
                    status_field[period]["status"],
                    "radius",
                    (
                        func.round(
                            cast(
                                (
                                    geofunc.ST_DistanceSphere(
                                        geofunc.ST_MakePoint(
                                            geofunc.ST_XMin(LAreas.geom),
                                            geofunc.ST_YMin(LAreas.geom),
                                        ),
                                        geofunc.ST_MakePoint(
                                            geofunc.ST_XMax(LAreas.geom),
                                            geofunc.ST_YMin(LAreas.geom),
                                        ),
                                    )
                                    / 2*0.9
                                ),
                                Integer,
                            ),
                            -2,
                        )
                    ),
                ).label("properties"),
                geom.label("geometry"),
            )
            .join(LAreas, LAreas.id_area == AreaKnowledgeTaxaList.id_area)
            .filter(AreaKnowledgeTaxaList.cd_nom == cd_nom)
            .filter(status_field[period]["condition"])
        )

        if envelope:
            query = query.filter(
                geofunc.ST_Intersects(
                    LAreas.geom,
                    geofunc.ST_Transform(
                        geofunc.ST_MakeEnvelope(
                            envelope[0], envelope[1], envelope[2], envelope[3], 4326
                        ),
                        4326,
                    ),
                )
            )
        return query.all()


# class TaxaAltitudeDistributionActions(BaseReadOnlyActions[MvTaxaAltitudeDistribution]):
#     """[summary]

#     Args:
#         BaseReadOnlyActions ([type]): [description]
#     """

#     def taxa_alti_distribution(self, db: Session, id_area: int, cd_nom: int = None):

#         q = (
#             db.query(
#                 MvTaxaAltitudeDistribution.range,
#                 func.sum(MvTaxaAltitudeDistribution.count).label("count"),
#             )
#             .filter(MvTaxaAltitudeDistribution.id_area == id_area)
#             .group_by(MvTaxaAltitudeDistribution.range)
#             .order_by(MvTaxaAltitudeDistribution.range)
#         )
#         q = q.filter(MvTaxaAltitudeDistribution.cd_nom == cd_nom) if cd_nom is not None else q
#         return q.all()


class HistoricAtlasesActions(BaseReadOnlyActions[THistoricAtlasesData]):
    """Get Historu"""

    def historic_atlases_distribution(
        self,
        db: Session,
        id_historic_atlas: str,
        cd_nom: int,
        envelope: Optional[List] = None,
    ) -> List:
        q = (
            db.query(
                THistoricAtlasesData.id_area.label("id"),
                THistoricAtlasesData.status,
                func.json_build_object("status", THistoricAtlasesData.status).label(
                    "properties"
                ),
                LAreas.geojson_4326.label("geometry"),
            )
            .join(LAreas, LAreas.id_area == THistoricAtlasesData.id_area)
            .filter(THistoricAtlasesData.cd_nom == cd_nom)
            .filter(THistoricAtlasesData.id_historic_atlas_info == id_historic_atlas)
        )

        if envelope:
            q = q.filter(
                geofunc.ST_Intersects(
                    LAreas.geom,
                    geofunc.ST_Transform(
                        geofunc.ST_MakeEnvelope(
                            envelope[0], envelope[1], envelope[2], envelope[3], 4326
                        ),
                        4326,
                    ),
                )
            )

        logger.debug(f"<taxa_distribution> q {q}")
        return q.all()

    def list_historic_atlases(self, db: Session) -> List:
        q = db.query(
            THistoricAtlasesInfo.id,
            THistoricAtlasesInfo.atlas_period,
            THistoricAtlasesInfo.atlas_period,
            THistoricAtlasesInfo.date_start,
            THistoricAtlasesInfo.date_end,
            THistoricAtlasesInfo.season_period,
            THistoricAtlasesInfo.description,
            # THistoricAtlasesInfo.is_active,
        ).filter(THistoricAtlasesInfo.is_active)
        return q.all()


taxa_distrib = TaxaDistributionActions(AreaKnowledgeTaxaList)
historic_atlas_distrib = HistoricAtlasesActions(THistoricAtlasesData)
# altitude_distrib = TaxaAltitudeDistributionActions(MvTaxaAltitudeDistribution)
