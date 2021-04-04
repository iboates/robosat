set search_path to myanmar,public;

drop table if exists buildings;

create table buildings as (

    select
        osm_id,
        ST_Transform(way, 6933) as geom,
        ST_Area(ST_Transform(way, 6933)) as area_m2
    from
        public.planet_osm_polygon
    where
        building is not null

);

CREATE INDEX
  ON buildings
  USING GIST (geom);