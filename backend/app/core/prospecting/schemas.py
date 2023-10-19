#!/usr/bin/python

import datetime
import logging
from typing import List, Optional, Union

from pydantic import BaseModel

from ..commons.schemas import BaseFeature, BaseFeatureCollection

logger = logging.getLogger(__name__)


class AreaKnowledgeLevelDetailSchema(BaseModel):
    """[AreaKnowledgeLevel] Data schema for area > period detail"""

    old_count: Union[None, int]
    new_count: Union[None, int]
    percent_knowledge: Union[None, float]


class AreaKnowledgeLevelPropertiesSchema(BaseModel):
    """[AreaKnowledgeLevel] Data schema for area detail"""

    area_name: str
    area_code: str
    all_period: AreaKnowledgeLevelDetailSchema
    breeding: AreaKnowledgeLevelDetailSchema
    wintering: AreaKnowledgeLevelDetailSchema

    class Config:
        from_attributes = True


class AreaKnowledgeLevelFeatureSchema(BaseFeature):
    """[AreaKnowledgeLevel] AreaKnowledgeLevelPropertiesSchema as GeoJson properties"""

    properties: AreaKnowledgeLevelPropertiesSchema

    class Config:
        from_attributes = True


class AreaKnowledgeLevelGeoJson(BaseFeatureCollection):
    """[summary]

    Args:
        FeatureCollection ([type]): [description]
    """

    features: List[AreaKnowledgeLevelFeatureSchema]

    class Config:
        from_attributes = True


class AreaKnowledgeTaxaListGenericDetailSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    last_obs: Union[None, int]
    new_count: Union[None, int]
    old_count: Union[None, int]


class AreaKnowledgeTaxaListBreedingDetailSchema(AreaKnowledgeTaxaListGenericDetailSchema):
    """[summary]

    Args:
        AreaKnowledgeTaxaListGenericDetailSchema ([type]): [description]
    """

    new_status: Union[None, str]
    old_status: Union[None, str]


class AreaKnowledgeTaxaListSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    id_area: int
    cd_nom: int
    sci_name: str
    common_name_fr: Optional[str]
    common_name_en: Optional[str]
    all_period: AreaKnowledgeTaxaListGenericDetailSchema
    wintering: AreaKnowledgeTaxaListGenericDetailSchema
    breeding: AreaKnowledgeTaxaListBreedingDetailSchema
    phenology: List[int]

    class Config:
        from_attributes = True


class AreaDashboardSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    # id_area: int
    last_date: datetime.date
    data_count: int
    taxa_count_all_period: int
    taxa_count_wintering: int
    taxa_count_breeding: int
    prospecting_hours_other_period: float
    prospecting_hours_wintering: float
    prospecting_hours_breeding: float

    class Config:
        from_attributes = True


class AreaDashboardTimeDistribSchema(BaseModel):
    """[AreaDashboard] Schema for data time distribution

    * label: value label
    * count_data: value

    Args:
        BaseModel ([type]): [description]
    """

    label: int
    # year: int
    count_data: int

    class Config:
        from_attributes = True


class AreaDashboardIntersectAreas(BaseModel):
    id_area: str
    area_code: str
    area_name: str

    class Config:
        from_attributes = True


class EpocFeaturePropertiesSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    id_epoc: int
    id_ff: str
    status: str
    rang_rsv: Optional[int]

    class Config:
        from_attributes = True


class EpocFeatureSchema(BaseFeature):
    """[summary]

    Args:
        Feature ([type]): [description]
    """

    properties: EpocFeaturePropertiesSchema


class EpocSchema(BaseFeatureCollection):
    """[summary]

    Args:
        FeatureCollection ([type]): [description]
    """

    features: List[Optional[EpocFeatureSchema]]

    class Config:
        from_attributes = True


class RealizedEpocFeaturePropertiesSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    project_code: str
    timelength_secs: int
    date: datetime.date
    time: datetime.time

    class Config:
        from_attributes = True


class RealizedEpocFeatureSchema(BaseFeature):
    """[summary]

    Args:
        Feature ([type]): [description]
    """

    properties: RealizedEpocFeaturePropertiesSchema


class RealizedEpocSchema(BaseFeatureCollection):
    """[summary]

    Args:
        FeatureCollection ([type]): [description]
    """

    features: List[Optional[RealizedEpocFeatureSchema]]

    class Config:
        from_attributes = True


class TaxonCountClassesByTerritorySchema(BaseModel):
    ntile: int
    min: Optional[int]
    max: Optional[int]

    class Config:
        from_attributes = True
