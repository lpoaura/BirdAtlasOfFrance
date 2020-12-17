from typing import Optional

from pydantic import BaseModel, UUID4


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
class BibAreasTypes(BibAreasTypesInDBase):
    pass


# Additional properties stored in DB
class BibAreasTypesInDB(BibAreasTypesInDBase):
    pass
