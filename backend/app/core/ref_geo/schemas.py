import logging
from typing import List, Optional

# from geojson_pydantic import Feature, Geometry
from geojson_pydantic.features import Feature, FeatureCollection

# from geojson_pydantic.geometries import Geometry
from pydantic import BaseModel

logger = logging.getLogger(__name__)


# Shared properties
class BibAreasTypesBase(BaseModel):
    type_name: Optional[str] = None
    type_code: str
    type_desc: Optional[str] = None
    ref_name: Optional[str] = None
    ref_version: Optional[str] = None
    num_version: Optional[str] = None


class BibAreasTypesInDBase(BibAreasTypesBase):
    id_type: Optional[int] = None

    class Config:
        orm_mode = True


# Additional properties to return via API
class BibAreasTypesSchema(BibAreasTypesInDBase):
    pass


# Additional properties stored in DB
class BibAreasTypesInDB(BibAreasTypesInDBase):
    pass


class LAreasBase(BaseModel):
    area_name: str
    area_code: str

    class Config:
        orm_mode = True


class LAreasIdArea(LAreasBase):
    id_area: str

    class Config:
        orm_mode = True


class LAreasBaseInDBase(LAreasBase):
    id_area: int
    id_type: int
    source: Optional[str]

    class Config:
        orm_mode = True


class LAreasFeatureProperties(Feature):
    properties: LAreasBase

    class Config:
        orm_mode = True


class LAreasGeoJsonList(FeatureCollection):
    features: List[LAreasFeatureProperties]

    class Config:
        orm_mode = True
