from typing import List, Optional

from pydantic import BaseModel, Field

from ..commons.schemas import BaseFeature, BaseFeatureCollection


class TaxaTerritoryDistribution(BaseModel):
    cd_nom: int
    areas: List[str]


class TaxaDistributionProperties(BaseModel):
    status: Optional[str]
    radius: Optional[int] = Field(None)


class TaxaDistributionFeature(BaseFeature):
    properties: TaxaDistributionProperties


class TaxaDistributionFeaturesCollection(BaseFeatureCollection):
    features: Optional[List[TaxaDistributionFeature]]

    class Config:
        from_attributes = True


class CommonDataStructure(BaseModel):
    label: int
    value: float

    # class Config:
    #     from_attributes = True


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
#         from_attributes = True


# class HistoricAtlasProperties(BaseModel):
#     status: Optional[str]


# class HistoricAtlasFeature(Feature):
#     properties: HistoricAtlasProperties


# class HistoricAtlasFeaturesCollection(BaseFeatureCollection):
#     features: List[HistoricAtlasFeature]

#     class Config:
#         from_attributes = True


class HistoricAtlasInfosSchema(BaseModel):
    label: str
    name: str
    slug: Optional[str]
    seasons: List[str]

    class Config:
        from_attributes = True


class SurveyMapDataProperties(BaseModel):
    area_name: str
    area_code: str
    data: Optional[List[List[str]]]


class SurveyMapDataFeature(BaseFeature):
    properties: SurveyMapDataProperties


class SurveyMapDataFeaturesCollection(BaseFeatureCollection):
    features: List[SurveyMapDataFeature]


class SurveyChartDataDetailProperties(BaseModel):
    val: Optional[float]
    val_min: Optional[float]
    val_max: Optional[float]


class SurveyChartDataItem(BaseModel):
    year: int
    unit: str
    data: SurveyChartDataDetailProperties


class SurveyChartDescItem(BaseModel):
    title: str
    desc: str


class SurveyChartData(BaseModel):
    descriptions: List[SurveyChartDescItem]
    data: List[SurveyChartDataItem]


# class MigrationChartBaseModel(BaseModel):
#     processing: str


class MigrationDecadeDataItem(BaseModel):
    decade: int
    count: int
    pivotal_decade: bool


class MigrationQuantileDataItem(BaseModel):
    phenology_period: str
    q2_5: int
    q5: int
    q25: int
    median: int
    q75: int
    q95: int
    q2_5: int


class MigrationChartData(BaseModel):
    quantile: List[MigrationQuantileDataItem]
    distribution: List[MigrationDecadeDataItem]
