import logging
from typing import List, Optional, Literal

from geojson_pydantic.features import FeatureCollection

# from geojson_pydantic.geometries import Geometry
from pydantic import BaseModel

from ..commons.schemas import BaseFeature

logger = logging.getLogger(__name__)


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
        from_attributes = True


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
        from_attributes = True


class LAreasIdArea(LAreasBase):
    id_area: int

    class Config:
        from_attributes = True


class LAreasBaseInDBase(LAreasBase):
    id_area: int
    id_type: int
    source: Optional[str]

    class Config:
        from_attributes = True


class LAreasFeatureProperties(BaseFeature):
    properties: LAreasBase

    class Config:
        from_attributes = True


class LAreasGeoJsonList(FeatureCollection):
    features: List[LAreasFeatureProperties]

    class Config:
        from_attributes = True
