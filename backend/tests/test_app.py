import pytest
from geojson_pydantic.features import Feature, FeatureCollection
from geojson_pydantic.geometries import Point

from app import __version__


def test_version():
    assert __version__ == "0.0.1"


@pytest.mark.parametrize("coordinates", [(1, 2)])
def test_geometry_collection_iteration(coordinates):
    """test if feature collection is iterable"""
    print(coordinates, type(coordinates))
    polygon = Point(coordinates=coordinates)
    feature = Feature(geometry=polygon)
    gc = FeatureCollection(features=[feature, feature])
    iter(gc)


coordinates = [(1, 2)]
test_geometry_collection_iteration(coordinates)
