/*
AREAS
-----
Filter terrestrial Areas based on municipalities geom
Required: first execute atlas_4_web.sql
*/


DO
$$
    BEGIN
        /* SET enable=TRUE when intersects with municipality datas else FALSE */

        CREATE
            TEMPORARY TABLE com_geom AS
        SELECT
            --(st_dump(st_union(geom))).geom AS geom
            st_union(geom) AS geom
        FROM ref_geo.l_areas
        WHERE id_type = (SELECT id_type FROM ref_geo.bib_areas_types WHERE type_code LIKE 'COM');

        CREATE INDEX ON com_geom USING gist (geom);

        UPDATE ref_geo.l_areas
        SET enable = st_intersects(l_areas.geom, com_geom.geom)
        FROM com_geom;
        COMMIT;

        INSERT INTO ref_geo.bib_areas_types(type_name, type_code, type_desc, ref_name, ref_version, num_version)
        VALUES ( 'Territoires de l''Atlas'
               , 'ATLAS_TERRITORY'
               , 'Territoires utilisés pour l''Atlas ODF'
               , NULL
               , NULL
               , NULL)
        ON CONFLICT DO NOTHING;

        INSERT INTO ref_geo.l_areas( id_type
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
        SELECT ref_geo.get_id_area_type('ATLAS_TERRITORY')
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

        FROM ref_geo.l_areas
        WHERE id_type = ref_geo.get_id_area_type('REG')
        UNION
        SELECT ref_geo.get_id_area_type('ATLAS_TERRITORY')
             , 'France métropolitaine'
             , 'FRMET'
             , st_union(geom)
             , st_centroid(st_union(geom))
             , st_asgeojson(st_union(geom))
             , source || '(Fusion des régions)'
             , 'Généré par fusion des régions de France métropolitaine'
             , TRUE
             , NOW()
             , NOW()
        FROM ref_geo.l_areas
        WHERE id_type = ref_geo.get_id_area_type('REG')
          AND area_code::INT > 10
        GROUP BY source
        ON CONFLICT DO NOTHING;

        CREATE
            TEMPORARY TABLE tmp_area_atlas_territory AS
        SELECT *
        FROM ref_geo.l_areas
        WHERE id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
          AND area_code NOT LIKE 'FRMET';


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
             , '{}'::jsonb
             , NOW()
             , NOW()
        FROM simplifylayerpreservetopology('', 'tmp_area_atlas_territory', 'id_area', 'geom',
                                           0.01) AS t(gid INT, geom geometry)
                 JOIN ref_geo.l_areas ON t.gid = l_areas.id_area;

        INSERT INTO ref_geo.l_areas (id_type, area_name, area_code, geom, centroid, geojson_4326, source, comment,
                                     additional_data, meta_create_date, meta_update_date)
        SELECT DISTINCT ref_geo.get_id_area_type('ATLAS_TERRITORY_SIMPLIFY'),
                        'France métropolitaine',
                        'FRMET',
                        st_union(geom)              AS geom,
                        st_centroid(st_union(geom)) AS centroid,
                        st_asgeojson(st_union(geom))   geojson_4326,
                        source,
                        comment,
                        additional_data,
                        NOW(),
                        NOW()
        FROM ref_geo.l_areas
        WHERE area_code IN (
                            '11',
                            '24',
                            '27',
                            '28',
                            '32',
                            '44',
                            '52',
                            '53',
                            '75',
                            '76',
                            '84',
                            '93',
                            '94'
            )
          AND id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY_SIMPLIFY')
        GROUP BY ref_geo.get_id_area_type('ATLAS_TERRITORY_SIMPLIFY'), source, comment, additional_data, NOW(), NOW();

    END
$$
;
