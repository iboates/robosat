set search_path to myanmar,public;

DROP TABLE IF EXISTS training;
CREATE TABLE training AS (
SELECT
--    ST_MakeValid(ST_Transform(geom, 4326)) AS geom
    (ST_Dump(ST_Transform(geom, 4326))).geom AS geom
FROM
    building_clusters b
-- LIMIT
--     100
);
SELECT * FROM training;