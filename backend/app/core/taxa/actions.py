import logging
from typing import List, Optional


from geoalchemy2 import functions as geofunc
from sqlalchemy import func, case, distinct
from sqlalchemy.orm import Session

from app.core.actions.crud import BaseReadOnlyActions
from app.core.commons.models import AreaKnowledgeTaxaList
from app.core.ref_geo.models import LAreas


from .models import (
    THistoricAtlasesData,
    THistoricAtlasesInfo,
    MvAltitudeDistribution,
    MvAltitudeTerritory,
    MvTaxaAllPeriodPhenology,
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

    def get_specie_distribution(
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
        if q1.count > 0:
            q = (
                db.query(
                    func.lower(MvAltitudeDistribution.range).label("label"),
                    (count_column[period] / float(q1.count) * 100).label("value"),
                )
                .filter(MvAltitudeDistribution.id_area == id_area)
                .filter(MvAltitudeDistribution.cd_nom == cd_nom)
                .order_by(MvAltitudeDistribution.range)
            )
            logger.debug(q)
            return q.all()
        else:
            return None

    def get_territory_distribution(self, db: Session, id_area: int):

        q = (
            db.query(
                func.lower(MvAltitudeTerritory.range).label("label"),
                (MvAltitudeTerritory.percentage).label("value"),
            )
            .filter(MvAltitudeTerritory.id_area == id_area)
            .order_by(MvAltitudeTerritory.range)
        )
        logger.debug(q)
        return q.all()


class TaxaGlobalPhenologyActions(BaseReadOnlyActions[MvTaxaAllPeriodPhenology]):
    """[summary]

    Args:
        BaseReadOnlyActions ([type]): [description]
    """

    def get_data_occurrence(self, db: Session, id_area: int, cd_nom: int = None):
        q = (
            db.query(
                MvTaxaAllPeriodPhenology.decade.label("label"),
                MvTaxaAllPeriodPhenology.count_data.label("value"),
            )
            .filter(MvTaxaAllPeriodPhenology.id_area == id_area)
            .filter(MvTaxaAllPeriodPhenology.cd_nom == cd_nom)
            .order_by(MvTaxaAllPeriodPhenology.decade)
        )
        return q.all()

    def get_list_occurrence(self, db: Session, id_area: int, cd_nom: int = None):
        total = (
            db.query(
                func.sum(MvTaxaAllPeriodPhenology.count_list).label("total"),
            )
            .filter(MvTaxaAllPeriodPhenology.id_area == id_area)
            .filter(MvTaxaAllPeriodPhenology.cd_nom == cd_nom)
        ).one()
        q = (
            db.query(
                MvTaxaAllPeriodPhenology.decade.label("label"),
                case(
                    (
                        total.total > 0,
                        (
                            MvTaxaAllPeriodPhenology.count_list
                            / float(total.total)
                            * 100
                        ),
                    ),
                    else_=0,
                ).label("value"),
            )
            .filter(MvTaxaAllPeriodPhenology.id_area == id_area)
            .filter(MvTaxaAllPeriodPhenology.cd_nom == cd_nom)
            .order_by(MvTaxaAllPeriodPhenology.decade)
        )
        return q.all()


class HistoricAtlasesActions(BaseReadOnlyActions[THistoricAtlasesData]):
    """Get Historu"""

    def historic_atlas_data(
        self,
        db: Session,
        atlas_period: str,
        id_historic_atlas: str,
        cd_nom: int,
        period: str = "all_period",
        envelope: Optional[List] = None,
    ) -> List:
        id_historic_atlas = (
            id_historic_atlas
            if id_historic_atlas
            else db.query(THistoricAtlasesInfo.id)
            .filter(THistoricAtlasesInfo.atlas_period == atlas_period)
            .filter(THistoricAtlasesInfo.season_period == period)
        )

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

    def list_historic_atlas(self, db: Session, cd_nom: int = None) -> List:
        from sqlalchemy.dialects.postgresql import ARRAY, array_agg
        from sqlalchemy import VARCHAR, String, cast

        seasons_agg = cast(
            func.array_agg(distinct(THistoricAtlasesInfo.season_period), type_=VARCHAR),
            ARRAY(String),
        ).label("seasons")
        # func.array_agg(distinct((THistoricAtlasesInfo.season_period)), _type=ARRAY(String)).label('seasons')
        q = (
            db.query(
                THistoricAtlasesInfo.atlas_period.label("label"),
                THistoricAtlasesInfo.description.label("name"),
                THistoricAtlasesInfo.code.label("slug"),
                seasons_agg,
            )
            .filter(THistoricAtlasesInfo.is_active)
            .group_by(
                THistoricAtlasesInfo.atlas_period,
                THistoricAtlasesInfo.description,
                THistoricAtlasesInfo.code,
            )
            .order_by(THistoricAtlasesInfo.atlas_period.desc())
            .distinct()
        )
        if cd_nom:
            q = q.join(
                THistoricAtlasesData,
                THistoricAtlasesInfo.id == THistoricAtlasesData.id_historic_atlas_info,
            ).filter(THistoricAtlasesData.cd_nom == cd_nom)
        print("jlkjlk")
        print(q.all()[0])
        return q.all()


taxa_distrib = TaxaDistributionActions(AreaKnowledgeTaxaList)
historic_atlas_distrib = HistoricAtlasesActions(THistoricAtlasesData)
altitude_distrib = TaxaAltitudeDistributionActions(MvAltitudeDistribution)
phenology_distrib = TaxaGlobalPhenologyActions(MvTaxaAllPeriodPhenology)
