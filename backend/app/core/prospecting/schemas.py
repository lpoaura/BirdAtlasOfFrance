#!/usr/bin/python

import logging
from typing import List, Optional

from geojson_pydantic.features import Feature, FeatureCollection
from pydantic import BaseModel

logger = logging.getLogger(__name__)


class AreaKnowledgeLevelPropertiesSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    area_name: str
    area_code: str
    count_taxa_old: int
    count_taxa_new: int
    percent_knowledge: float

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
