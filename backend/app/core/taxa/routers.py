import json
import logging
from typing import Any, List, Optional, Union

from fastapi import APIRouter, Depends, Response
from sqlalchemy.orm import Session
from starlette.status import HTTP_204_NO_CONTENT

from app.utils.db import get_db

from .actions import (
    all_period_phenology_distrib,
    altitude_distrib,
    breeding_phenology_distrib,
    historic_atlas_distrib,
    taxa_distrib,
)
from .schemas import (  # HistoricAtlasFeature,; HistoricAtlasFeaturesCollection,
    CommonBlockStructure,
    HistoricAtlasInfosSchema,
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
""",
)
def list_lareas(
    cd_nom: int,
    period: str = "all_period_new",
    db: Session = Depends(get_db),
    grid: Optional[Union[bool, str]] = False,
    envelope: Optional[str] = None,
) -> Any:
    if isinstance(grid, str):
        grid: bool = True
    if envelope:
        logger.debug(f"envelop qs: {envelope}")
        envelope = [float(c) for c in envelope.split(",")]
    logger.debug(f"envelop {envelope} {type(envelope)}")
    q = taxa_distrib.taxa_distribution(
        db=db, cd_nom=cd_nom, period=period, grid=grid, envelope=envelope
    )
    if not q:
        return Response(status_code=HTTP_204_NO_CONTENT)
    features = [
        TaxaDistributionFeature(
            properties=a.properties,
            geometry=json.loads(a.geometry),
            id=a.id,
        )
        for a in q
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
def historic_atlases(
    cd_nom: int,
    atlas_period: str,
    period: str = "all_period",
    db: Session = Depends(get_db),
    envelope: Optional[str] = None,
    id_historic_atlas: Optional[int] = None,
) -> Any:
    if envelope:
        logger.debug(f"envelop qs: {envelope}")
        envelope = [float(c) for c in envelope.split(",")]
    logger.debug(f"envelop {envelope} {type(envelope)}")
    q = historic_atlas_distrib.historic_atlas_data(
        db=db,
        cd_nom=cd_nom,
        atlas_period=atlas_period,
        period=period,
        id_historic_atlas=id_historic_atlas,
        envelope=envelope,
    )
    if not q:
        return Response(status_code=HTTP_204_NO_CONTENT)
    features = [
        TaxaDistributionFeature(
            properties=a.properties,
            geometry=json.loads(a.geometry),
            id=a.id,
        )
        for a in q
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
def list_historic_atlases(db: Session = Depends(get_db), cd_nom: int = None) -> Any:
    q = historic_atlas_distrib.list_historic_atlas(db=db, cd_nom=cd_nom)
    if not q:
        return Response(status_code=HTTP_204_NO_CONTENT)
    return q


@router.get(
    "/altitude/{id_area}/{cd_nom}",
    response_model=TaxaAltitudinalApiData,
    tags=["taxa"],
    summary="Altitudinal distribution",
    description="""# coming soon

    get historic atlases list

""",
)
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
def all_period_phenology_distribution(
    id_area: str, cd_nom: int, db: Session = Depends(get_db)
) -> Any:
    q = all_period_phenology_distrib.get_data_occurrence(db=db, id_area=id_area, cd_nom=cd_nom)
    if q:
        phenology = CommonBlockStructure(
            label="Nombre de données",
            data=q,
            color="#435EF2",
        )
        frequency = CommonBlockStructure(
            label="Fréquence dans les listes complètes",
            data=all_period_phenology_distrib.get_list_occurrence(
                db=db, id_area=id_area, cd_nom=cd_nom
            ),
            color="#8CCB6E",
        )
        return TaxaPhenologyApiData(frequency=frequency, phenology=phenology)
    else:
        return Response(status_code=HTTP_204_NO_CONTENT)


@router.get(
    "/phenology/breeding/{id_area}/{cd_nom}",
    response_model=TaxaBreedingPhenologyApiData,
    tags=["taxa"],
    summary="Breeding phenology distribution",
    description="""# coming soon""",
)
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
