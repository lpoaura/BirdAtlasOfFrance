import logging
from typing import List, Optional

from geoalchemy2 import functions as geofunc
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.actions.crud import BaseReadOnlyActions
from app.core.commons.models import AreaKnowledgeTaxaList
from app.core.ref_geo.models import LAreas


from .models import (
    THistoricAtlasesData,
    THistoricAtlasesInfo,
    MvAltitudeDistribution,
    MvTerritoryAltitudeRanges,
)

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
        q = (
            db.query(
                AreaKnowledgeTaxaList.id_area.label("id"),
                func.json_build_object("status", status_field[period]["status"]).label(
                    "properties"
                ),
                geom.label("geometry"),
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
                        4326,
                    ),
                )
            )

        logger.debug(f"<taxa_distribution> q {q}")
        return q.all()


class TaxaAltitudeDistributionActions(BaseReadOnlyActions[MvAltitudeDistribution]):
    """[summary]

    Args:
        BaseReadOnlyActions ([type]): [description]
    """

    def get(
        self, db: Session, id_area: int, cd_nom: int = None, period: str = "all_period"
    ):
        count_column = {
            "all_period": MvAltitudeDistribution.count_all_period,
            "breeding": MvAltitudeDistribution.count_breeding,
            "wintering": MvAltitudeDistribution.count_wintering,
        }
        q1 = (
            db.query(
                func.Sum(count_column[period]).label("count"),
            )
            .filter(MvAltitudeDistribution.id_area == id_area)
            .filter(MvAltitudeDistribution.cd_nom == cd_nom)
            .one()
        )

        q = (
            db.query(
                func.lower(MvAltitudeDistribution.range).label("label"),
                (count_column[period] / float(q1.count) * 100).label("percentage"),
            )
            .filter(MvAltitudeDistribution.id_area == id_area)
            .filter(MvAltitudeDistribution.cd_nom == cd_nom)
            .order_by(MvAltitudeDistribution.range)
        )
        logger.debug(q)
        return q.all()


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
altitude_distrib = TaxaAltitudeDistributionActions(MvAltitudeDistribution)
