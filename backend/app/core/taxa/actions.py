import logging
from typing import List, Optional

from geoalchemy2 import functions as geofunc
from sqlalchemy import VARCHAR, String, and_, case, cast, distinct, func, literal_column
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import Session, aliased
from fastapi_cache.decorator import cache

from app.core.actions.crud import BaseReadOnlyActions
from app.core.commons.models import AreaKnowledgeTaxaList
from app.core.ref_geo.models import BibAreasTypes, LAreas

from .models import (
    MvAltitudeDistribution,
    MvAltitudeTerritory,
    MvSurveyMapData,
    MvTaxaAllPeriodPhenology,
    MvTaxaBreedingPhenology,
    THistoricAtlasesData,
    THistoricAtlasesInfo,
)

# from .models import MvTaxaAltitudeDistribution

logger = logging.getLogger(__name__)


class TaxaDistributionActions(BaseReadOnlyActions[AreaKnowledgeTaxaList]):
    """Post actions with basic CRUD operations"""

    def taxa_distribution(
        self,
        db: Session,
        atlas_period: str,
        phenology_period: str,
        cd_nom: int,
        grid: bool,
        envelope: Optional[List] = None,
    ) -> List:
        geom = (
            LAreas.geojson_4326
            if grid
            else geofunc.ST_AsGeoJSON(
                geofunc.ST_Transform(geofunc.ST_Centroid(LAreas.geom), 4326)
            )  # pylint: disable=E1101
        )

        if atlas_period in ("new", "old"):
            values = {
                "condition": AreaKnowledgeTaxaList.__table__.c[  # pylint: disable=E1101
                    phenology_period + "_count_data_" + atlas_period
                ]
                > 0,
                "status": AreaKnowledgeTaxaList.__table__.c[  # pylint: disable=E1101
                    phenology_period + "_status_" + atlas_period
                ]
                if phenology_period == "breeding"
                else "Presence",
            }

        if atlas_period == "compare":
            values = {
                "condition": (
                    AreaKnowledgeTaxaList.__table__.c[
                        phenology_period + "_count_data_new"
                    ]  # pylint: disable=E1101
                    + AreaKnowledgeTaxaList.__table__.c[
                        phenology_period + "_count_data_old"
                    ]  # pylint: disable=E1101
                )
                > 0,
                "status": case(
                    (
                        and_(
                            AreaKnowledgeTaxaList.__table__.c[  # pylint: disable=E1101
                                phenology_period + "_count_data_new"
                            ]
                            > 0,
                            AreaKnowledgeTaxaList.__table__.c[  # pylint: disable=E1101
                                phenology_period + "_count_data_old"
                            ]
                            > 0,
                        ),
                        "AOFM & ODF",
                    ),
                    (
                        and_(
                            AreaKnowledgeTaxaList.__table__.c[  # pylint: disable=E1101
                                phenology_period + "_count_data_new"
                            ]
                            > 0,
                            AreaKnowledgeTaxaList.__table__.c[  # pylint: disable=E1101
                                phenology_period + "_count_data_old"
                            ]
                            == 0,
                        ),
                        "ODF",
                    ),
                    (
                        and_(
                            AreaKnowledgeTaxaList.__table__.c[  # pylint: disable=E1101
                                phenology_period + "_count_data_new"
                            ]
                            == 0,
                            AreaKnowledgeTaxaList.__table__.c[  # pylint: disable=E1101
                                phenology_period + "_count_data_old"
                            ]
                            > 0,
                        ),
                        "AOFM",
                    ),
                    else_=None,
                ),
            }

        q = (
            db.query(
                AreaKnowledgeTaxaList.id_area.label("id"),
                func.json_build_object("status", values["status"]).label("properties"),
                geom.label("geometry"),
            )
            .join(LAreas, LAreas.id_area == AreaKnowledgeTaxaList.id_area)
            .filter(AreaKnowledgeTaxaList.cd_nom == cd_nom)
            .filter(values["condition"])
        )

        if envelope:
            q = q.filter(
                geofunc.ST_Intersects(  # pylint: disable=E1101
                    LAreas.geom,
                    geofunc.ST_Transform(  # pylint: disable=E1101
                        geofunc.ST_MakeEnvelope(  # pylint: disable=E1101
                            envelope[0], envelope[1], envelope[2], envelope[3], 4326
                        ),
                        4326,
                    ),
                )
            )

        logger.debug("<taxa_distribution> q %s", q)
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
        query1 = (
            db.query(
                func.Sum(count_column[period]).label("count"),
            )
            .filter(MvAltitudeDistribution.id_area == id_area)
            .filter(MvAltitudeDistribution.cd_nom == cd_nom)
            .one()
        )
        logger.debug(query1)
        if query1 and query1.count > 0:
            query2 = (
                db.query(
                    func.lower(MvAltitudeDistribution.range).label("label"),
                    (count_column[period] / float(query1.count) * 100).label("value"),
                )
                .filter(MvAltitudeDistribution.id_area == id_area)
                .filter(MvAltitudeDistribution.cd_nom == cd_nom)
                .order_by(MvAltitudeDistribution.range)
            )
            logger.debug(query2)
            return query2.all()

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
        query = (
            db.query(
                MvTaxaAllPeriodPhenology.decade.label("label"),
                MvTaxaAllPeriodPhenology.count_data.label("value"),
            )
            .filter(MvTaxaAllPeriodPhenology.id_area == id_area)
            .filter(MvTaxaAllPeriodPhenology.cd_nom == cd_nom)
            .order_by(MvTaxaAllPeriodPhenology.decade)
        )
        return query.all()


    def get_list_occurrence(self, db: Session, id_area: int, cd_nom: int = None):
        total = (
            db.query(
                func.sum(MvTaxaAllPeriodPhenology.count_list).label("total"),
            )
            .filter(MvTaxaAllPeriodPhenology.id_area == id_area)
            .filter(MvTaxaAllPeriodPhenology.cd_nom == cd_nom)
        ).one()
        query = (
            db.query(
                MvTaxaAllPeriodPhenology.decade.label("label"),
                case(
                    (
                        total.total > 0,
                        (MvTaxaAllPeriodPhenology.count_list / float(total.total) * 100),
                    ),
                    else_=0,
                ).label("value"),
            )
            .filter(MvTaxaAllPeriodPhenology.id_area == id_area)
            .filter(MvTaxaAllPeriodPhenology.cd_nom == cd_nom)
            .order_by(MvTaxaAllPeriodPhenology.decade)
        )
        return query.all()


class TaxaBreedingPhenologyActions(BaseReadOnlyActions[MvTaxaBreedingPhenology]):
    """[summary]

    Args:
        BaseReadOnlyActions ([type]): [description]
    """

    def get_data_occurrence(self, db: Session, id_area: int, status: str, cd_nom: int = None):
        q = (
            db.query(
                MvTaxaBreedingPhenology.decade.label("label"),
                MvTaxaBreedingPhenology.count_data.label("value"),
            )
            .filter(MvTaxaBreedingPhenology.id_area == id_area)
            .filter(MvTaxaBreedingPhenology.cd_nom == cd_nom)
            .filter(MvTaxaBreedingPhenology.status == status)
            .order_by(MvTaxaBreedingPhenology.decade)
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
        if not id_historic_atlas and atlas_period:
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
                func.json_build_object("status", THistoricAtlasesData.status).label("properties"),
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
        """_summary_

        :param db: Database session
        :type db: Session
        :param cd_nom: Taxa cd_nom, defaults to None
        :type cd_nom: int, optional
        :return: Historic atlases list
        :rtype: List
        """
        seasons_agg = cast(
            func.array_agg(distinct(THistoricAtlasesInfo.season_period), type_=VARCHAR),
            ARRAY(String),
        ).label("seasons")
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


class SurveyMapDataActions(BaseReadOnlyActions[MvSurveyMapData]):
    """Post actions with basic CRUD operations"""

    def data_distribution(
        self, db: Session, cd_nom: int, id_area_atlas_territory: str, phenology_period: str
    ) -> List:
        dept = aliased(LAreas)
        dept_simp = aliased(LAreas)

        DEP_SIMPLIFY_ID_TYPE = (
            db.query(BibAreasTypes.id_type)
            .filter(BibAreasTypes.type_code == "DEP_SIMPLIFY")
            .first()
            .id_type
        )
        DEP_ID_TYPE = (
            db.query(BibAreasTypes.id_type)
            .filter(BibAreasTypes.type_code == "DEP")
            .first()
            .id_type
        )

        query = (
            db.query(
                MvSurveyMapData.id,
                func.json_build_object(
                    "area_name",
                    dept.area_name,
                    "area_code",
                    dept.area_code,
                    "data",
                    MvSurveyMapData.data,
                ).label("properties"),
                dept_simp.geojson_4326.label("geometry"),
            )
            .join(
                MvSurveyMapData,
                and_(
                    dept.id_area == MvSurveyMapData.id_area,
                    MvSurveyMapData.cd_nom == cd_nom,
                    MvSurveyMapData.id_area_atlas_territory == id_area_atlas_territory,
                    MvSurveyMapData.phenology_period == phenology_period,
                ),
                isouter=True,
            )
            .join(dept_simp, dept_simp.area_code == dept.area_code)
            .filter(
                dept.id_type == DEP_ID_TYPE,
                dept_simp.id_type == DEP_SIMPLIFY_ID_TYPE,
            )
        )
        return query.all()


taxa_distrib = TaxaDistributionActions(AreaKnowledgeTaxaList)
historic_atlas_distrib = HistoricAtlasesActions(THistoricAtlasesData)
altitude_distrib = TaxaAltitudeDistributionActions(MvAltitudeDistribution)
all_period_phenology_distrib = TaxaGlobalPhenologyActions(MvTaxaAllPeriodPhenology)
breeding_phenology_distrib = TaxaBreedingPhenologyActions(MvTaxaBreedingPhenology)
survey_map_data = SurveyMapDataActions(MvSurveyMapData)
