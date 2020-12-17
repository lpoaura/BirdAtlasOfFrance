from app.core.actions.crud import BaseReadOnlyActions
from .models import BibAreasTypes


class BibAreasTypesActions(BaseReadOnlyActions[BibAreasTypes]):
    """Post actions with basic CRUD operations"""

    pass


bib_areas_types = BibAreasTypesActions(BibAreasTypes)