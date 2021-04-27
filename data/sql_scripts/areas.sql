/*
AREAS
-----
Filter terrestrial Areas based on municipalities geom
*/


DO
$$
    BEGIN
        /* SET enable=TRUE when intersects with municipality datas else FALSE */

        CREATE TEMPORARY TABLE com_geom AS
        SELECT
            --(st_dump(st_union(geom))).geom AS geom
            st_union(geom) AS geom
            FROM
                ref_geo.l_areas
            WHERE
                    id_type = (SELECT id_type FROM ref_geo.bib_areas_types WHERE type_code LIKE 'COM');

        CREATE INDEX ON com_geom USING gist (geom);

        UPDATE ref_geo.l_areas
        SET
            enable = st_intersects(l_areas.geom, com_geom.geom)
            FROM
                com_geom;
        COMMIT;
    END
$$
;