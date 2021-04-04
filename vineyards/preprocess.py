import geopandas as gpd
from sqlalchemy import create_engine

vineyards_query = open("sql/vineyards.sql").read()
all_classes_query = open("sql/all_classes.sql").read()

engine = create_engine('postgresql://test_user:test_user@172.17.0.2:5432/test_user')

gdf = gpd.GeoDataFrame.from_postgis(vineyards_query, engine)
gdf.to_file(f"data/vineyards.geojson", driver="GeoJSON")

gdf = gpd.GeoDataFrame.from_postgis(all_classes_query, engine)
gdf.to_file(f"data/all_classes.geojson", driver="GeoJSON")