from ast import Str
from datetime import date
from tokenize import String
from typing import List, Optional

from geojson_pydantic.features import Feature, FeatureCollection
from pydantic import BaseModel
from sqlalchemy import Integer
from sqlalchemy.dialects.postgresql import INT4RANGE


class TaxaDistributionProperties(BaseModel):
    status: Optional[str]


class TaxaDistributionFeature(Feature):
    properties: TaxaDistributionProperties


class TaxaDistributionFeaturesCollection(FeatureCollection):
    features: List[TaxaDistributionFeature]

    class Config:
        orm_mode = True


class CommonDataStructure(BaseModel):
    label: int
    value: float

    # class Config:
    #     orm_mode = True


class CommonBlockStructure(BaseModel):
    label: str
    data: List[CommonDataStructure]
    color: str


class TaxaAltitudinalApiData(BaseModel):
    altitude: CommonBlockStructure
    globalAltitude: CommonBlockStructure


class TaxaPhenologyApiData(BaseModel):
    phenology: CommonBlockStructure
    frequency: CommonBlockStructure


class TaxaBreedingPhenologyApiData(BaseModel):
    breeding_start: CommonBlockStructure
    breeding_end: CommonBlockStructure


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


class HistoricAtlasInfosSchema(BaseModel):
    label: str
    name: str
    slug: Optional[str]
    seasons: List[str]
