set search_path to myanmar,public;

drop table if exists building_clusters;

create table building_clusters as (

	with buffers as (
		select
			ST_Buffer(ST_Transform(ST_Union(way), 6933), 30000) as geom
		from
			public.planet_osm_point
		where
			place = 'city'
	),

	buildings_outside_cities as (

		 select
		 	b.osm_id,
		 	b.geom
		 from
		 	buildings as b,
		 	buffers as c
		 where
		 	not ST_Intersects(b.geom, c.geom)
		 	and
		 	area_m2 > 50
		 	and
		 	area_m2 < 500
	),

	cluster_result as (
		SELECT
			geom,
			ST_ClusterDBSCAN(b.geom, eps := 20, minpoints := 2) over () AS cid
		FROM
			buildings_outside_cities b
	),

	cluster_counts as (
		select distinct
			cid,
			count(cid) as num_buildings
		from
			cluster_result
		group by
			cid
	),

	cluster_boundaries as (
		select
			ST_Buffer(ST_ConcaveHull(ST_Union(cr.geom), 0.99), 10) as geom,
			cr.cid,
			cc.num_buildings
		from
			cluster_result cr
			left join cluster_counts cc on cr.cid = cc.cid
		where
			cr.cid is not null
			--and
			--cc.num_buildings > 5
		group by
			cr.cid,
			cc.num_buildings
	)

	select * from cluster_boundaries where ST_Area(geom) > 1000

)
;

CREATE INDEX
  ON building_clusters
  USING GIST (geom);