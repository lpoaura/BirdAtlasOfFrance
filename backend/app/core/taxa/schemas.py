from typing import List

from geojson_pydantic.features import Feature, FeatureCollection, Geometry
from pydantic import BaseModel


class TaxaDistributionProperties(BaseModel):
    status: str


class TaxaDistributionFeature(Feature):
    properties: TaxaDistributionProperties


class TaxaDistributionFeaturesCollection(FeatureCollection):
    features: List[TaxaDistributionFeature]

    class Config:
        orm_mode = True


class TaxaAltitudeDistributionSchema(BaseModel):
    range: List
    count: int

    class Config:
        orm_mode = True
