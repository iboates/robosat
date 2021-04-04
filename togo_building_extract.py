import geopandas as gpd
from sqlalchemy import create_engine, text

buildings_query = text("""

    DROP TABLE IF EXISTS ml_buildings;
    CREATE TABLE ml_buildings AS (
    
    WITH validated_clusters AS (
        SELECT
            cid
        FROM
            building_clusters_bbox
        WHERE
            validated
    )
    
    SELECT
        ST_Transform(geom, 4326) AS geom
    FROM
        building_clusters b
    WHERE
        b.cid in (select cid from validated_clusters)
    );
    SELECT * FROM ml_buildings;
    
""")

engine = create_engine('postgresql://test_user:test_user@172.17.0.2:5432/test_user')

i = 0
gdf = gpd.GeoDataFrame.from_postgis(buildings_query, engine)
gdf.to_file(f"buildings-postgis-{str(i).zfill(3)}.geojson", driver="GeoJSON")
