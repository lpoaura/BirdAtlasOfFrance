import json
import logging
from typing import Any, List, Optional

from fastapi import APIRouter, Depends, HTTPException
from geojson_pydantic.features import FeatureCollection
from sqlalchemy.orm import Session
from starlette.status import HTTP_404_NOT_FOUND

from app.utils.db import get_db

from .actions import taxa_distrib
from .schemas import FeatureCollection, TaxaDistributionFeature, TaxaDistributionFeaturesCollection

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
    period: str = "breeding_new",
    db: Session = Depends(get_db),
    envelope: Optional[str] = None,
) -> Any:
    if envelope:
        logger.debug(f"envelop qs: {envelope}")
        envelope = [float(c) for c in envelope.split(",")]
    logger.debug(f"envelop {envelope} {type(envelope)}")
    areas = taxa_distrib.taxa_distribution(db=db, cd_nom=cd_nom, period=period, envelope=envelope)
    features = [
        TaxaDistributionFeature(
            properties=a.properties,
            geometry=json.loads(a.geometry),
            id=a.id,
        )
        for a in areas
    ]
    # for a in areas:
    #     f = TaxaDistributionFeature(**a)
    #     features.append(f)
    # collection = TaxaDistributionFeatureCollection(features=features)
    return TaxaDistributionFeaturesCollection(features=features)
