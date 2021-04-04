import geopandas as gpd
from sqlalchemy import create_engine

buildings_query = open("sql/03_extract_buildings_geojson.sql").read()

engine = create_engine('postgresql://test_user:test_user@172.17.0.2:5432/test_user')

i = 0
gdf = gpd.GeoDataFrame.from_postgis(buildings_query, engine)
gdf.to_file(f"buildings-postgis-{str(i).zfill(3)}.geojson", driver="GeoJSON")
