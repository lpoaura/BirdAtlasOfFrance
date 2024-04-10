/*
AREAS 4 WEB
-----------
Work to properly simplify geom for web usage
*/

-- SOURCE: https://trac.osgeo.org/postgis/wiki/UsersWikiSimplifyPreserveTopology

-- Simplify the given table of multipolygon with the given tolerance.
-- This function preserves the connection between polygons and try to avoid generating gaps between objects.
-- To identify objects after simplification, area comparison is performed, instead of PIP test, that may fail
-- with odd-shaped polygons. Area comparison may also failed on some cases

-- Example: (table 'departement' is in the public schema)
-- select * from simplifyLayerPreserveTopology('', 'departement', 'gid', 'geom', 10000) as (gid int, geom geometry);
--
-- @param schename: text, the schema name of the table to simplify. set to null or empty string to use search_path-defined schemas
-- @param tablename: text, the name of the table to simplify
-- @param idcol: text, the name of a unique table identifier column. This is the gid returned by the function
-- @param tolerance: float, the simplify tolerance, in object's unit
-- @return a setof (gid, geom) where gid is the identifier of the multipolygon, geom is the simplified geometry

BEGIN
;

CREATE OR REPLACE FUNCTION simplifylayerpreservetopology(schemaname TEXT, tablename TEXT, idcol TEXT, geom_col TEXT
, tolerance FLOAT)
    RETURNS SETOF RECORD AS
$$
DECLARE
    schname ALIAS FOR $1;
    tabname ALIAS FOR $2;
    tid ALIAS FOR $3;
    geo ALIAS FOR $4;
    tol ALIAS FOR $5;
    numpoints INT  := 0;
    time      TEXT := '';
    fullname  TEXT := '';

BEGIN
    IF schname IS NULL OR length(schname) = 0 THEN
        fullname := quote_ident(tabname);
    ELSE
        fullname := quote_ident(schname) || '.' || quote_ident(tabname);
    END IF;

    RAISE NOTICE 'fullname: %', fullname;

    EXECUTE 'select sum(st_npoints(' || quote_ident(geo) || ')), to_char(clock_timestamp(), ''MI:ss:MS'') from '
        || fullname INTO numpoints, time;
    RAISE NOTICE 'Num points in %: %. Time: %', tabname, numpoints, time;

    EXECUTE 'create unlogged table public.poly as ('
                || 'select ' || quote_ident(tid) || ', (st_dump(' || quote_ident(geo) || ')).* from ' || fullname ||
            ')';

    -- extract rings out of polygons
    CREATE UNLOGGED TABLE rings AS
    SELECT st_exteriorring((st_dumprings(geom)).geom) AS g FROM public.poly;

    SELECT to_char(clock_timestamp(), 'MI:ss:MS') INTO time;
    RAISE NOTICE 'rings created: %', time;

    DROP TABLE poly;

    -- Simplify the rings. Here, no points further than 10km:
    CREATE UNLOGGED TABLE gunion AS
    SELECT st_union(g) AS g FROM rings;

    SELECT to_char(clock_timestamp(), 'MI:ss:MS') INTO time;
    RAISE NOTICE 'union done: %', time;

    DROP TABLE rings;

    CREATE UNLOGGED TABLE mergedrings AS
    SELECT st_linemerge(g) AS g FROM gunion;

    SELECT to_char(clock_timestamp(), 'MI:ss:MS') INTO time;
    RAISE NOTICE 'linemerge done: %', time;

    DROP TABLE gunion;

    CREATE UNLOGGED TABLE simplerings AS
    SELECT st_simplifypreservetopology(g, tol) AS g FROM mergedrings;


    SELECT to_char(clock_timestamp(), 'MI:ss:MS') INTO time;
    RAISE NOTICE 'rings simplified: %', time;

    DROP TABLE mergedrings;

    -- extract lines as individual objects, in order to rebuild polygons from these
    -- simplified lines
    CREATE UNLOGGED TABLE simplelines AS
    SELECT (st_dump(g)).geom AS g FROM simplerings;

    DROP TABLE simplerings;

    -- Rebuild the polygons, first by polygonizing the lines, with a
    -- distinct clause to eliminate overlaping segments that may prevent polygon to be created,
    -- then dump the collection of polygons into individual parts, in order to rebuild our layer.
    DROP TABLE IF EXISTS simplepolys;
    CREATE TABLE simplepolys AS
    SELECT (st_dump(st_polygonize(DISTINCT g))).geom AS g
    FROM simplelines;

    SELECT count(*) FROM simplepolys INTO numpoints;
    SELECT to_char(clock_timestamp(), 'MI:ss:MS') INTO time;
    RAISE NOTICE 'rings polygonized. num rings: %. time: %', numpoints, time;

    DROP TABLE simplelines;

    -- some spatial indexes
    CREATE INDEX simplepolys_geom_gist ON simplepolys USING gist (g);

    RAISE NOTICE 'spatial index created...';

    -- works better: comparing percentage of overlaping area gives better results.
    -- as input set is multipolygon, we first explode multipolygons into their polygons, to
    -- be able to find islands and set them the right departement code.
    RETURN QUERY EXECUTE 'select ' || quote_ident(tid) || ', st_collect(' || quote_ident(geo) || ') as geom '
                             || 'from ('
                             --||'    select distinct on (d.'||quote_ident(tid)||') d.'||quote_ident(tid)||', s.g as geom '
                             || '    select d.' || quote_ident(tid) || ', s.g as geom '
                             || '   from ' || fullname || ' d, simplepolys s '
                             --||'    where (st_intersects(d.'||quote_ident(geo)||', s.g) or st_contains(d.'||quote_ident(geo)||', s.g))'
                             || '    where st_intersects(d.' || quote_ident(geo) || ', s.g) '
                             || '    and st_area(st_intersection(s.g, d.' || quote_ident(geo) ||
                         '))/st_area(s.g) > 0.5 '
                             || '    ) as foo '
                             || 'group by ' || quote_ident(tid);

    --drop table simplepolys;

    RETURN;

END;
$$ LANGUAGE plpgsql STRICT
;

--
-- SELECT
--     id_type
--   , type_code
--   , type_name
--     FROM
--         ref_geo.bib_areas_types
-- ;

CREATE VIEW ref_geo.v_c_area_atlas_territory AS
SELECT *
FROM ref_geo.l_areas
WHERE id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
  AND area_code NOT LIKE 'FRMET'
;

--
-- DROP TABLE tmp.atlas_territory_simp
-- ;
--
-- CREATE TEMPORARY TABLE atlas_territory_simp AS
-- SELECT
--     t.*
--   , l_areas.area_name
--   , l_areas.area_code
--     FROM
--         simplifylayerpreservetopology('ref_geo', 'v_c_area_atlas_territory', 'id_area', 'geom',
--                                       0.01) AS t(gid INT, geom GEOMETRY)
--             JOIN ref_geo.l_areas ON t.gid = l_areas.id_area
-- ;
--
-- SELECT populate_geometry_columns()
-- ;

INSERT INTO ref_geo.bib_areas_types (type_name, type_code, type_desc, ref_name, ref_version, num_version)
VALUES ( 'Territoires de l''atlas pour un usage web'
       , 'ATLAS_TERRITORY_SIMPLIFY'
       , 'Zonages simplifiés pour un usage web'
       , NULL
       , NULL
       , NULL)
;

INSERT INTO ref_geo.l_areas ( id_type
                            , area_name
                            , area_code
                            , geom
                            , centroid
                            , geojson_4326
                            , source
                            , comment
                            , enable
                            , additional_data
                            , meta_create_date
                            , meta_update_date)
SELECT ref_geo.get_id_area_type('ATLAS_TERRITORY_SIMPLIFY')
     , l_areas.area_name
     , l_areas.area_code
     , t.geom
     , st_centroid(t.geom)
     , st_asgeojson(t.geom)
     , source
     , 'Zonages simplifiés pour un usage web'
     , TRUE
     , '{}'::JSONB
     , now()
     , now()
FROM simplifylayerpreservetopology('ref_geo', 'v_c_area_atlas_territory', 'id_area', 'geom',
                                   0.01) AS t(gid INT, geom GEOMETRY)
         JOIN ref_geo.l_areas ON t.gid = l_areas.id_area
;


DROP VIEW ref_geo.v_c_area_atlas_territory
;

/* DEP_SIMPLIFY */
CREATE VIEW ref_geo.v_c_area_atlas_dep AS
SELECT *
FROM ref_geo.l_areas
WHERE id_type = ref_geo.get_id_area_type('DEP')
;


INSERT INTO ref_geo.bib_areas_types (type_name, type_code, type_desc, ref_name, ref_version, num_version)
VALUES ( 'Départements simplifiés pour un usage web'
       , 'DEP_SIMPLIFY'
       , 'Départements simplifiés pour un usage web'
       , NULL
       , NULL
       , NULL)
;

INSERT INTO ref_geo.l_areas ( id_type
                            , area_name
                            , area_code
                            , geom
                            , centroid
                            , geojson_4326
                            , source
                            , comment
                            , enable
                            , additional_data
                            , meta_create_date
                            , meta_update_date)
SELECT ref_geo.get_id_area_type('DEP_SIMPLIFY')
     , l_areas.area_name
     , l_areas.area_code
     , st_multi(st_union(t.geom))
     , st_centroid(st_union(t.geom))
     , st_asgeojson(st_union(t.geom))
     , source
     , 'Zonages simplifiés pour un usage web'
     , FALSE
     , '{}'::JSONB
     , now()
     , now()
FROM simplifylayerpreservetopology('ref_geo', 'v_c_area_atlas_dep', 'id_area', 'geom',
                                   0.01) AS t(gid INT, geom GEOMETRY)
         JOIN ref_geo.l_areas ON t.gid = l_areas.id_area
GROUP BY ref_geo.get_id_area_type('DEP_SIMPLIFY')
       , l_areas.area_name
       , l_areas.area_code
       , l_areas.source
;


COMMIT
;
