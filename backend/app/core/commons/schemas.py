from typing import Literal

from geojson_pydantic import Feature, FeatureCollection
from pydantic import BaseModel, Field


class BaseFeature(Feature):
    type: Literal["Feature"] = Field("Feature")


class BaseFeatureCollection(FeatureCollection):
    type: Literal["FeatureCollection"] = Field("FeatureCollection")


class Message(BaseModel):
    message: str
