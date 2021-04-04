set search_path to vineyards,public;

SELECT
    geom
FROM
    training
WHERE
    class = 'vineyard'