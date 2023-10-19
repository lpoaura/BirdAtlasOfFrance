from typing import Literal
from pydantic import BaseModel, Field
from geojson_pydantic import Feature, FeatureCollection


class BaseFeature(Feature):
    type: Literal["Feature"] = Field("Feature")

class BaseFeatureCollection(FeatureCollection):
    type: Literal['FeatureCollection'] = Field('FeatureCollection')

class Message(BaseModel):
    message: str
