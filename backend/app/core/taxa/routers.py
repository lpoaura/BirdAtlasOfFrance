import json
import logging
from typing import Any, List, Optional, Union

from fastapi import APIRouter, Depends, Response
from fastapi_cache.decorator import cache
from sqlalchemy.orm import Session
from starlette.status import HTTP_204_NO_CONTENT

from app.utils.db import get_db

from .actions import (
    all_period_phenology_distrib,
    altitude_distrib,
    breeding_phenology_distrib,
    historic_atlas_distrib,
    survey_map_data,
    survey_chart_data,
    taxa_distrib,
)
from .schemas import (  # HistoricAtlasFeature,; HistoricAtlasFeaturesCollection,
    CommonBlockStructure,
    HistoricAtlasInfosSchema,
    SurveyMapDataFeature,
    SurveyMapDataFeaturesCollection,
    SurveyChartDataItem,
    TaxaAltitudinalApiData,
    TaxaBreedingPhenologyApiData,
    TaxaDistributionFeature,
    TaxaDistributionFeaturesCollection,
    TaxaPhenologyApiData,
)

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get(
    "/distribution",
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
        logger.debug("envelop qs: %s", envelope)
        envelope = [float(c) for c in envelope.split(",")]
    logger.debug("envelop %s %s", envelope, type(envelope))
    query = taxa_distrib.taxa_distribution(
        db=db,
        cd_nom=cd_nom,
        atlas_period=atlas_period,
        phenology_period=phenology_period,
        grid=grid,
        envelope=envelope,
    )
    if not query:
        return Response(status_code=HTTP_204_NO_CONTENT)
    features = [
        TaxaDistributionFeature(
            properties=row.properties,
            geometry=json.loads(row.geometry),
            id=row.id,
        )
        for row in query
    ]
    return TaxaDistributionFeaturesCollection(features=features)


# @router.get(
#     "/data/altitudes/{id_area}",
#     response_model=TaxaAltitudeDistributionSchema,
#     tags=["taxa"],
#     summary="taxon geographic distribution",
#     description="""# Taxon geographic distribution

# This returns grid centroids with taxon presence for old or new atlas.
# For breeding period, status returned is breeding status.

# Period choices must be one of following choices :
# * `breeding_new`: Breeding presence and status for new atlas
# * `breeding_old`: Breeding presence and status from previous atlas
# * `wintering_new`: Wintering presence for new atlas
# * `wintering_old`: Wintering presence from previous atlas
# * `all_period_new`: All period presence for new atlas
# * `all_period_old`: All period presence from previous atlas
# """,
# )
# def altitude_distribution(
#     id_area: int,
#     cd_nom: int = None,
#     db: Session = Depends(get_db),
# ) -> Any:
#     # for a in areas:
#     #     f = TaxaDistributionFeature(**a)
#     #     features.append(f)
#     # collection = TaxaDistributionFeatureCollection(features=features)
#     return altitude_distrib.taxa_alti_distribution(db=db, id_area=id_area, cd_nom=cd_nom)


@router.get(
    "/historic/atlas/data",
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
    if not query:
        return Response(status_code=HTTP_204_NO_CONTENT)
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
    "/historic/atlas/list",
    response_model=List[HistoricAtlasInfosSchema],
    tags=["taxa"],
    summary="List historic atlases",
    description="""# List historic atlases

    get historic atlases list

""",
)
@cache()
def list_historic_atlases(db: Session = Depends(get_db), cd_nom: int = None) -> Any:
    query = historic_atlas_distrib.list_historic_atlas(db=db, cd_nom=cd_nom)
    return query if query else Response(status_code=HTTP_204_NO_CONTENT)


@router.get(
    "/altitude/{id_area}/{cd_nom}",
    response_model=TaxaAltitudinalApiData,
    tags=["taxa"],
    summary="Altitudinal distribution",
    description="""# coming soon

    get historic atlases list

""",
)
@cache()
def altitudinal_distribution(
    id_area: str,
    cd_nom: int,
    db: Session = Depends(get_db),
    period: Optional[str] = "all_period",
) -> Any:
    q = altitude_distrib.get_specie_distribution(
        db=db, id_area=id_area, cd_nom=cd_nom, period=period
    )
    if q:
        altitude = CommonBlockStructure(
            label="Répartition des observations",
            data=q,
            color="#435EF2",
        )
        global_altitude = CommonBlockStructure(
            label="Répartition de l'altitude du territoire",
            data=altitude_distrib.get_territory_distribution(db=db, id_area=id_area),
            color="rgba(67, 94, 242, 0.3)",
        )
        return TaxaAltitudinalApiData(altitude=altitude, globalAltitude=global_altitude)
    else:
        return Response(status_code=HTTP_204_NO_CONTENT)


@router.get(
    "/phenology/allperiod/{id_area}/{cd_nom}",
    response_model=TaxaPhenologyApiData,
    tags=["taxa"],
    summary="Altitudinal distribution",
    description="""# coming soon

    get historic atlases list

""",
)
@cache()
def all_period_phenology_distribution(
    id_area: str, cd_nom: int, db: Session = Depends(get_db)
) -> Any:
    data_count = all_period_phenology_distrib.get_data_occurrence(
        db=db, id_area=id_area, cd_nom=cd_nom
    )
    list_frequency = all_period_phenology_distrib.get_list_occurrence(
        db=db, id_area=id_area, cd_nom=cd_nom
    )
    logger.debug("data_count %s", str(data_count))
    logger.debug("list_frequency %s", str(list_frequency))
    if data_count:
        phenology = CommonBlockStructure(
            label="Nombre de données",
            data=data_count,
            color="#435EF2",
        )
        frequency = CommonBlockStructure(
            label="Fréquence dans les listes complètes",
            data=list_frequency,
            color="#8CCB6E",
        )
        return TaxaPhenologyApiData(frequency=frequency, phenology=phenology)
    return Response(status_code=HTTP_204_NO_CONTENT)


@router.get(
    "/phenology/breeding/{id_area}/{cd_nom}",
    response_model=TaxaBreedingPhenologyApiData,
    tags=["taxa"],
    summary="Breeding phenology distribution",
    description="""# coming soon""",
)
@cache()
def breeding_phenology_distribution(
    id_area: str, cd_nom: int, db: Session = Depends(get_db)
) -> Any:
    q_start = breeding_phenology_distrib.get_data_occurrence(
        db=db, id_area=id_area, cd_nom=cd_nom, status="breeding_start"
    )
    q_end = breeding_phenology_distrib.get_data_occurrence(
        db=db, id_area=id_area, cd_nom=cd_nom, status="breeding_end"
    )
    if q_start or q_end:
        breeding_start = CommonBlockStructure(
            label="Début de période",
            data=q_start,
            color="#435EF2",
        )
        breeding_end = CommonBlockStructure(
            label="Fin de période",
            data=q_end,
            color="#8CCB6E",
        )
        return TaxaBreedingPhenologyApiData(
            breeding_start=breeding_start, breeding_end=breeding_end
        )
    else:
        return Response(status_code=HTTP_204_NO_CONTENT)


@router.get(
    "/survey/map",
    response_model=SurveyMapDataFeaturesCollection,
    tags=["taxa"],
    summary="taxon geographic distribution",
    description="""# Taxon geographic distribution
""",
)
@cache()
def get_survey_map_data(
    cd_nom: int, id_area_atlas_territory: int, phenology_period: str, db: Session = Depends(get_db)
) -> Any:
    query = survey_map_data.data_distribution(
        db,
        cd_nom=cd_nom,
        id_area_atlas_territory=id_area_atlas_territory,
        phenology_period=phenology_period,
    )
    if not query:
        return Response(status_code=HTTP_204_NO_CONTENT)
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
    "/survey/chart",
    response_model=List[SurveyChartDataItem],
    tags=["taxa"],
    summary="taxon geographic distribution",
    description="""# Taxon geographic distribution
""",
)
@cache()
def get_survey_chart_data(
    cd_nom: int, id_area_atlas_territory: int, phenology_period: str, db: Session = Depends(get_db)
) -> Any:
    query = survey_chart_data.get_data(
        db,
        cd_nom=cd_nom,
        id_area_atlas_territory=id_area_atlas_territory,
        phenology_period=phenology_period,
    )
    if not query:
        return Response(status_code=HTTP_204_NO_CONTENT)
    return query.all()
