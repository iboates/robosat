import geopandas as gpd
from sqlalchemy import create_engine, text

buildings_query = text("""

    SELECT
        way AS geom
    FROM
        planet_osm_polygon
    WHERE
        building IS NOT NULL
        AND
        building not in ('construction', 'houseboat', 'static_caravan', 'stadium', 'conservatory', 'digester', 'greenhouse', 'ruins')
        AND
        ST_IsValid(way)
        AND
        (4 * PI() * ST_Area(way)) / POWER(ST_Perimeter(way), 2) < 0.95  -- Polsby-Popper (https://en.wikipedia.org/wiki/Polsby%E2%80%93Popper_test)
        AND
        NOT ST_Intersects((select ST_Union(geom) from urban), way)
    LIMIT
        :limit
    OFFSET
        :offset
    
""")

huts_query = text("""

    SELECT
        way AS geom
    FROM
        planet_osm_polygon
    WHERE
        building IS NOT NULL
        AND
        building not in ('construction', 'houseboat', 'static_caravan', 'stadium', 'conservatory', 'digester', 'greenhouse', 'ruins')
        AND
        ST_IsValid(way)
        AND
        (4 * PI() * ST_Area(way)) / POWER(ST_Perimeter(way), 2) >= 0.95  -- Polsby-Popper (https://en.wikipedia.org/wiki/Polsby%E2%80%93Popper_test)
        AND
        NOT ST_Intersects((select ST_Union(geom) from urban), way)
    LIMIT
        :limit
    OFFSET
        :offset

""")

engine = create_engine('postgresql://test_user:test_user@172.17.0.2:5432/test_user')

# i = 0
# while True:
#     gdf = gpd.GeoDataFrame.from_postgis(buildings_query, engine, params={"limit": 100000, "offset": i*100000})
#     if not gdf.empty:
#         gdf.to_file(f"buildings-postgis-{str(i).zfill(3)}.geojson", driver="GeoJSON")
#         i += 1
#     else:
#         break

i = 0
while True:
    gdf = gpd.GeoDataFrame.from_postgis(huts_query, engine, params={"limit": 100000, "offset": i * 100000})
    if not gdf.empty:
        gdf.to_file(f"huts-postgis-{str(i).zfill(3)}.geojson", driver="GeoJSON")
        i += 1
    else:
        break
