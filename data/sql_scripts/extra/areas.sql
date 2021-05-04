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

        INSERT INTO
            ref_geo.bib_areas_types(type_name, type_code, type_desc, ref_name, ref_version, num_version)
            VALUES
            ('Territoires de l''Atlas', 'ATLAS_TERRITORY', 'Territoires utilisés pour l''Atlas ODF', NULL, NULL, NULL)
        ON CONFLICT DO NOTHING;

        INSERT INTO
            ref_geo.l_areas( id_type
                           , area_name
                           , area_code
                           , geom
                           , centroid
                           , geojson_4326
                           , source
                           , comment
                           , enable
                           , meta_create_date
                           , meta_update_date)
        SELECT
            ref_geo.get_id_area_type('ATLAS_TERRITORY')
          , area_name
          , area_code
          , geom
          , centroid
          , geojson_4326
          , source
          , comment
          , area_code::INT < 10 AS enable
          , meta_create_date
          , meta_update_date

            FROM
                ref_geo.l_areas
            WHERE
                id_type = ref_geo.get_id_area_type('REG')
        UNION
        SELECT
            ref_geo.get_id_area_type('ATLAS_TERRITORY')
          , 'France métropolitaine'
          , 'FRMET'
          , st_union(geom)
          , st_centroid(st_union(geom))
          , st_asgeojson(st_union(geom))
          , source || '(Fusion des régions)'
          , 'Généré par fusion des régions de France métropolitaine'
          , TRUE
          , now()
          , now()
            FROM
                ref_geo.l_areas
            WHERE
                  id_type = ref_geo.get_id_area_type('REG')
              AND area_code::INT > 10
            GROUP BY source
        ON CONFLICT DO NOTHING;

    END
$$
;
