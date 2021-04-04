set search_path to myanmar,public;
drop table if exists buildings_cluster_test_result;
create table buildings_cluster_test_result as (
	with foo as (
	SELECT
		geom,
		ST_ClusterDBSCAN(b.geom, eps := 10, minpoints := 2) over () AS cid
	FROM
		buildings_cluster_test b
		)
		select * from foo where cid is not null
);