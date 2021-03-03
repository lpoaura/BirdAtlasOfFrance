#!/usr/bin/python

import logging
from typing import List, Optional, Union

from geojson_pydantic.features import Feature, FeatureCollection
from pydantic import BaseModel

logger = logging.getLogger(__name__)


class GeneralStatsSubSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    all_period: int
    breeding: int
    wintering: int


class GeneralStatsSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    prospecting_hours: GeneralStatsSubSchema
    count_taxa: GeneralStatsSubSchema

    class Config:
        orm_mode = True
