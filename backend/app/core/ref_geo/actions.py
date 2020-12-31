from app.core.actions.crud import BaseReadOnlyActions

from .models import BibAreasTypes, LAreas


class BibAreasTypesActions(BaseReadOnlyActions[BibAreasTypes]):
    """Post actions with basic CRUD operations"""

    pass


bib_areas_types = BibAreasTypesActions(BibAreasTypes)


class LAreasActions(BaseReadOnlyActions[LAreas]):
    """Post actions with basic CRUD operations"""

    pass


bib_areas_types = BibAreasTypesActions(BibAreasTypes)
l_areas = LAreasActions(LAreas)
