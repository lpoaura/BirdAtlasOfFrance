#!/usr/bin/python

import logging

from pydantic import BaseModel

logger = logging.getLogger(__name__)


class GeneralStatsCountTaxaSubSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    all_period: int
    breeding: int
    wintering: int


class GeneralStatsProspectingHoursSubSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    other_period: int
    breeding: int
    wintering: int


class GeneralStatsSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    prospecting_hours: GeneralStatsProspectingHoursSubSchema
    count_taxa: GeneralStatsCountTaxaSubSchema

    class Config:
        from_attributes = True


class KnowledgeLevelGeneralStatsSchema(BaseModel):
    """[summary]

    Args:
        BaseModel ([type]): [description]
    """

    average: float
    from0to25: int
    from25to50: int
    from50to75: int
    from75to100: int
    over100: int

    class Config:
        from_attributes = True
