from typing import List, Optional

from geojson_pydantic.features import Feature, FeatureCollection, Geometry
from pydantic import BaseModel


class TaxaDistributionProperties(BaseModel):
    status: Optional[str]


class TaxaDistributionFeature(Feature):
    properties: TaxaDistributionProperties


class TaxaDistributionFeaturesCollection(FeatureCollection):
    features: List[TaxaDistributionFeature]

    class Config:
        orm_mode = True


# class TaxaAltitudeDistributionSchema(BaseModel):
#     range: List
#     count: int

#     class Config:
#         orm_mode = True


# class HistoricAtlasProperties(BaseModel):
#     status: Optional[str]


# class HistoricAtlasFeature(Feature):
#     properties: HistoricAtlasProperties


# class HistoricAtlasFeaturesCollection(FeatureCollection):
#     features: List[HistoricAtlasFeature]

#     class Config:
#         orm_mode = True
