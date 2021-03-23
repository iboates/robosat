import geopandas as gpd
from sqlalchemy import create_engine, text

buildings_query = text("""

    DROP TABLE IF EXISTS ml_buildings;
    CREATE TABLE ml_buildings AS (
    SELECT
        ST_Transform(geom, 4326) AS geom
    FROM
        building_clusters
    WHERE
        cid < 250
    );
    SELECT * FROM ml_buildings;
    
""")

engine = create_engine('postgresql://test_user:test_user@172.17.0.2:5432/test_user')

i = 0
while True:
    gdf = gpd.GeoDataFrame.from_postgis(buildings_query, engine)
    if not gdf.empty:
        gdf.to_file(f"buildings-postgis-{str(i).zfill(3)}.geojson", driver="GeoJSON")
        i += 1
        break
    else:
        break
