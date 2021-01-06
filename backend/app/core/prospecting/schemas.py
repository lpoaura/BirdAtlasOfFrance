#!/usr/bin/python

import logging
from typing import List, Optional, Union

from geojson_pydantic.features import Feature, FeatureCollection
from pydantic import BaseModel

logger = logging.getLogger(__name__)


class AreaKnowledgeLevelDetailSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    old_count: Union[None, int]
    new_count: Union[None, int]
    percent_knowledge: Union[None, float]


class AreaKnowledgeLevelPropertiesSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    area_name: str
    area_code: str
    all_period: AreaKnowledgeLevelDetailSchema
    breeding: AreaKnowledgeLevelDetailSchema
    wintering: AreaKnowledgeLevelDetailSchema

    class Config:
        orm_mode = True


class AreaKnowledgeLevelFeatureSchema(Feature):
    """[summary]

    Args:
        Feature ([type]): [description]
    """

    properties: AreaKnowledgeLevelPropertiesSchema

    class Config:
        orm_mode = True


class AreaKnowledgeLevelGeoJson(FeatureCollection):
    """[summary]

    Args:
        FeatureCollection ([type]): [description]
    """

    features: List[AreaKnowledgeLevelFeatureSchema]

    class Config:
        orm_mode = True
