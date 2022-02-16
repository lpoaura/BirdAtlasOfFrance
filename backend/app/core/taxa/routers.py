import json
import logging
from typing import Any, Optional, Union

from fastapi import APIRouter, Depends, Response
from sqlalchemy.orm import Session
from starlette.status import HTTP_204_NO_CONTENT

from app.utils.db import get_db

from .actions import taxa_distrib
from .schemas import TaxaDistributionFeature, TaxaDistributionFeaturesCollection

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get(
    "/taxa/{cd_nom}",
    response_model=TaxaDistributionFeaturesCollection,
    tags=["taxa"],
    summary="taxon geographic distribution",
    description="""# Taxon geographic distribution

This returns grid centroids with taxon presence for old or new atlas. For breeding period, status returned is breeding status.

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

# This returns grid centroids with taxon presence for old or new atlas. For breeding period, status returned is breeding status.

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
