import json
import logging
from typing import Any, List, Optional, Union

from fastapi import APIRouter, Depends, Response
from fastapi_cache.decorator import cache
from sqlalchemy.orm import Session

from app.utils.db import get_db

from ..commons.schemas import BaseFeatureCollection
from .actions import (
    all_period_phenology_distrib,
    altitude_distrib,
    breeding_phenology_distrib,
    historic_atlas_distrib,
    survey_chart_data,
    survey_map_data,
    taxa_distrib,
    taxa_list_territory,
)
from .schemas import (  # HistoricAtlasFeature,; HistoricAtlasFeaturesCollection,
    CommonBlockStructure,
    HistoricAtlasInfosSchema,
    SurveyChartDataItem,
    SurveyMapDataFeature,
    SurveyMapDataFeaturesCollection,
    TaxaAltitudinalApiData,
    TaxaBreedingPhenologyApiData,
    TaxaDistributionFeature,
    TaxaDistributionFeaturesCollection,
    TaxaPhenologyApiData,
    TaxaTerritoryDistribution,
)

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get(
    "/list/distribution",
    response_model=Optional[TaxaTerritoryDistribution],
    tags=["taxa"],
    summary="Taxa territory distribution",
    description="""# Taxon territory distribution
This returns the list of concerned area_code for each taxon.
""",
)
@cache()
def list_territories(
    cd_nom: int,
    db: Session = Depends(get_db),
) -> Response:
    """Taxa territory distribution"""
    return taxa_list_territory.territory_list(db, cd_nom)


@router.get(
    "/map/distribution",
    response_model=TaxaDistributionFeaturesCollection,
    tags=["taxa"],
    summary="taxon geographic distribution",
    description="""# Taxon geographic distribution

This returns grid centroids with taxon presence for old or new atlas.
For breeding period, status returned is breeding status.

Period choices must be one of following choices :
* `breeding_new`: Breeding presence and status for new atlas
* `breeding_old`: Breeding presence and status from previous atlas
* `wintering_new`: Wintering presence for new atlas
* `wintering_old`: Wintering presence from previous atlas
* `all_period_new`: All period presence for new atlas
* `all_period_old`: All period presence from previous atlas
* `breeding_aofm`: 
""",
)
@cache()
def list_lareas(
    cd_nom: int,
    atlas_period: str = "new",
    phenology_period: str = "all_period",
    db: Session = Depends(get_db),
    grid: Optional[Union[bool, str]] = False,
    envelope: Optional[str] = None,
) -> Any:
    if isinstance(grid, str):
        grid: bool = True
    if envelope:
        envelope = [float(c) for c in envelope.split(",")]
    query = taxa_distrib.taxa_distribution(
        db=db,
        cd_nom=cd_nom,
        atlas_period=atlas_period,
        phenology_period=phenology_period,
        grid=grid,
        envelope=envelope,
    )
    features = [
        TaxaDistributionFeature(
            properties=row.properties,
            geometry=json.loads(row.geometry),
            id=row.id,
        )
        for row in query
    ]
    return TaxaDistributionFeaturesCollection(features=features)


@router.get(
    "/map/historic/atlas",
    response_model=TaxaDistributionFeaturesCollection,
    tags=["taxa"],
    summary="taxon geographic distribution (Historic atlases)",
    description="""# Taxon geographic distribution

    get historic atlases data

""",
)
@cache()
def historic_atlases(
    cd_nom: int,
    atlas_period: str,
    period: str = "all_period",
    db: Session = Depends(get_db),
    envelope: Optional[str] = None,
    id_historic_atlas: Optional[int] = None,
) -> Any:
    if envelope:
        envelope = [float(c) for c in envelope.split(",")]
    query = historic_atlas_distrib.historic_atlas_data(
        db=db,
        cd_nom=cd_nom,
        atlas_period=atlas_period,
        period=period,
        id_historic_atlas=id_historic_atlas,
        envelope=envelope,
    )
    features = [
        TaxaDistributionFeature(
            properties=row.properties,
            geometry=json.loads(row.geometry),
            id=row.id,
        )
        for row in query
    ]
    return TaxaDistributionFeaturesCollection(features=features)


@router.get(
    "/list/historic/atlas",
    response_model=List[HistoricAtlasInfosSchema],
    tags=["taxa"],
    summary="List historic atlases",
    description="""# List historic atlases

    get historic atlases list
""",
)
# @cache()
def list_historic_atlases(cd_nom: int, id_area: int, db: Session = Depends(get_db)) -> Any:
    query = historic_atlas_distrib.list_historic_atlas(db=db, cd_nom=cd_nom, id_area=id_area)
    return query


@router.get(
    "/chart/altitude",
    response_model=Union[TaxaAltitudinalApiData, dict],
    tags=["taxa"],
    summary="Altitudinal distribution",
    description="""# coming soon

    get historic atlases list

""",
)
@cache()
def altitudinal_distribution(
    id_area: int,
    cd_nom: int,
    db: Session = Depends(get_db),
    period: Optional[str] = "all_period",
) -> Any:
    query = altitude_distrib.get_specie_distribution(
        db=db, id_area=id_area, cd_nom=cd_nom, period=period
    )
    logger.debug(f"altitudinal_distribution_1 {query}")
    if query:
        logger.debug(f"altitudinal_distribution {dir(query[0])}")
        altitude = CommonBlockStructure(
            label="Répartition des observations",
            data=[q._asdict() for q in query],
            color="#435EF2",
        )
        global_altitude = CommonBlockStructure(
            label="Répartition de l'altitude du territoire",
            data=[
                q._asdict()
                for q in altitude_distrib.get_territory_distribution(db=db, id_area=id_area)
            ],
            color="rgba(67, 94, 242, 0.3)",
        )
        return TaxaAltitudinalApiData(altitude=altitude, globalAltitude=global_altitude)
    # raise HTTPException(status_code=404, detail="No data")
    return dict()


@router.get(
    "/chart/phenology",
    response_model=Union[dict, TaxaPhenologyApiData, TaxaBreedingPhenologyApiData],
    tags=["taxa"],
    summary="Altitudinal distribution",
    description="""# coming soon

    get historic atlases list

""",
)
@cache()
def phenology_distribution(
    id_area: int,
    cd_nom: int,
    db: Session = Depends(get_db),
    period: Optional[str] = "all_period",
) -> Any:
    try:
        if period == "all_period":
            data_count = all_period_phenology_distrib.get_data_occurrence(
                db=db, id_area=id_area, cd_nom=cd_nom
            )
            list_frequency = all_period_phenology_distrib.get_list_occurrence(
                db=db, id_area=id_area, cd_nom=cd_nom
            )
            if data_count:
                phenology = CommonBlockStructure(
                    label="Nombre de données",
                    data=[q._asdict() for q in data_count],
                    color="#435EF2",
                )
                frequency = CommonBlockStructure(
                    label="Fréquence dans les listes complètes",
                    data=[q._asdict() for q in list_frequency],
                    color="#8CCB6E",
                )
                return TaxaPhenologyApiData(frequency=frequency, phenology=phenology)
        if period == "breeding":
            q_start = breeding_phenology_distrib.get_data_occurrence(
                db=db, id_area=id_area, cd_nom=cd_nom, status="breeding_start"
            )
            q_end = breeding_phenology_distrib.get_data_occurrence(
                db=db, id_area=id_area, cd_nom=cd_nom, status="breeding_end"
            )
            if q_start or q_end:
                breeding_start = CommonBlockStructure(
                    label="Début de période",
                    data=[q._asdict() for q in q_start],
                    color="#435EF2",
                )
                breeding_end = CommonBlockStructure(
                    label="Fin de période",
                    data=[q._asdict() for q in q_end],
                    color="#8CCB6E",
                )
                return TaxaBreedingPhenologyApiData(
                    breeding_start=breeding_start, breeding_end=breeding_end
                )
    except:
        return dict()


@router.get(
    "/map/survey",
    response_model=SurveyMapDataFeaturesCollection,
    tags=["taxa"],
    summary="taxon geographic distribution",
    description="""# Taxon geographic distribution
""",
)
@cache()
def get_survey_map_data(
    cd_nom: int,
    id_area_atlas_territory: int,
    phenology_period: str,
    simplified_area_id_type: str = "DEP_SIMPLIFY",
    area_id_type: str = "DEP",
    db: Session = Depends(get_db),
) -> Any:
    """Get survey map data

    :param cd_nom: Taxa cd_nom
    :type cd_nom: int
    :param id_area_atlas_territory: Atlas territory pk
    :type id_area_atlas_territory: int
    :param phenology_period: _description_
    :type phenology_period: str
    :param db: _description_, defaults to Depends(get_db)
    :type db: Session, optional
    :return: _description_
    :rtype: Any
    """
    query = survey_map_data.data_distribution(
        db,
        cd_nom=cd_nom,
        id_area_atlas_territory=id_area_atlas_territory,
        phenology_period=phenology_period,
        simplified_area_id_type=simplified_area_id_type,
        area_id_type=area_id_type,
    )
    features = [
        SurveyMapDataFeature(
            properties=item.properties,
            geometry=json.loads(item.geometry),
            id=item.id,
        )
        for item in query
    ]
    return SurveyMapDataFeaturesCollection(features=features)


@router.get(
    "/chart/survey",
    response_model=Union[List[SurveyChartDataItem], List],
    tags=["taxa"],
    summary="taxon geographic distribution",
    description="""# Taxon geographic distribution
""",
)
@cache()
def get_survey_chart_data(
    cd_nom: int,
    id_area: int,
    phenology_period: str,
    chart_type: str,
    db: Session = Depends(get_db),
) -> Any:
    query = survey_chart_data.get_data(
        db,
        cd_nom=cd_nom,
        id_area_atlas_territory=id_area,
        chart_type=chart_type,
        phenology_period=phenology_period,
    )
    if query.count() > 0:
        return query.all()
    return list()
