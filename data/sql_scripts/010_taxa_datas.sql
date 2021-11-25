/*
TAXA DATAS
-----
Distribution
 */
DO
$$
    BEGIN
        /* Vue matérialisée finale */
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_taxa_alti_distribution;
        CREATE MATERIALIZED VIEW atlas.mv_taxa_alti_distribution AS
        (
        WITH
            maxalti AS (
                SELECT
                    cor_area_synthese.id_area
                  , (max(mv_data_for_atlas.altitude) + (20 - mod(max(mv_data_for_atlas.altitude), 20))) AS alti
                    FROM
                        atlas.mv_data_for_atlas
                            JOIN gn_synthese.cor_area_synthese
                                 ON mv_data_for_atlas.id_data = cor_area_synthese.id_synthese
                    WHERE
                            cor_area_synthese.id_area IN (
                            SELECT
                                id_area
                                FROM
                                    ref_geo.l_areas
                                WHERE
                                      id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
                                  AND enable)
                    GROUP BY cor_area_synthese.id_area
--                 SELECT
--                     87138                       AS id_area
--                   , (815 + (20 - mod(815, 20))) AS alti
--                 UNION
--                 SELECT
--                     87145
--                   , (4810 + (20 - mod(815, 20)))
            )
          , ranges (id_area, range) AS (
            SELECT
                id_area
              , int4range(i, i + (SELECT round(alti, -2) / 20)::INT, '[)')
                FROM
                    maxalti
                        CROSS JOIN generate_series(0, alti,
                                                   (SELECT round(alti, -2) / 20)::INT) t(i)
        )
        SELECT
            row_number() OVER () AS id
          , ranges.id_area
          , cd_group             AS cd_nom
          , ranges.range
          , count(data.altitude) AS count
            FROM
                ranges
                    LEFT JOIN atlas.mv_data_for_atlas data
                              ON data.altitude <@ ranges.range
                    JOIN gn_synthese.cor_area_synthese ON data.id_data = cor_area_synthese.id_synthese
                    JOIN atlas.mv_taxa_groups ON data.cd_nom = mv_taxa_groups.cd_nom
                    JOIN atlas.t_taxa ON t_taxa.cd_nom = mv_taxa_groups.cd_group
            WHERE
                  new_data_all_period
              AND ranges.id_area = cor_area_synthese.id_area
              AND (t_taxa.available AND t_taxa.enabled)
            GROUP BY
                ranges.id_area
              , ranges.range
              , mv_taxa_groups.cd_group
            ORDER BY
                ranges.id_area
              , ranges.range
              , mv_taxa_groups.cd_group);
        COMMIT;
    END
$$
;

--
-- SELECT
--     max(altitude_min)
--   , cor_area_synthese.id_area
--     FROM
--         atlas.mv_data_for_atlas ad
--             JOIN gn_synthese.synthese sy ON ad.id_data = sy.id_synthese
--             JOIN gn_synthese.cor_area_synthese ON sy.id_synthese = cor_area_synthese.id_synthese
--     WHERE
--             cor_area_synthese.id_area IN
--             (SELECT id_area FROM ref_geo.l_areas WHERE id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY') AND enable)
--       AND   new_data_all_period
--     GROUP BY
--         cor_area_synthese.id_area
-- ;
--
-- WITH
--     ranges (range) AS (
--         SELECT
--             int4range(i, i + 250, '[)')
--             FROM
--                 generate_series(0, (SELECT max(altitude_min) FROM gn_synthese.synthese), 250) AS i
--     )
-- SELECT
--     range
--   , cor_area_synthese.id_area
--   , l_areas.area_name
--   , sy.cd_nom
--   , sy.nom_cite
--   , count(sy.altitude_min) AS range_count
--     FROM
--         ranges l
--             LEFT JOIN gn_synthese.synthese sy
--                       ON sy.altitude_min <@ l.range
--             JOIN atlas.mv_data_for_atlas da ON da.id_data = sy.id_synthese
--             JOIN gn_synthese.cor_area_synthese ON sy.id_synthese = cor_area_synthese.id_synthese
--             JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
--             JOIN ref_geo.bib_areas_types ON l_areas.id_type = bib_areas_types.id_type
--     WHERE
--           type_code LIKE 'ATLAS_TERRITORY'
--       AND new_data_all_period
--     GROUP BY
--         sy.cd_nom
--       , sy.nom_cite
--       , cor_area_synthese.id_area
--       , l_areas.area_name
--       , range
--     ORDER BY
--         sy.cd_nom
--       , sy.nom_cite
--       , cor_area_synthese.id_area
--       , l_areas.area_name
--       , range
-- ;
--
-- SELECT
--     int4range(i, i + 250, '[)')
--     FROM
--         generate_series(0, (SELECT max(altitude_min) FROM gn_synthese.synthese WHERE id_source = 24), 250) AS i
--
-- ;
--
-- SELECT
--     count(*)
--     FROM
--         gn_synthese.cor_area_synthese
-- ;
--
-- WITH
--     maxalti AS (
-- --         SELECT
-- --             cor_area_synthese.id_area
-- --           , (max(synthese.altitude_min) + (20 - mod(max(synthese.altitude_min), 20))) AS alti
-- --             FROM
-- --                 gn_synthese.synthese
-- --                     JOIN gn_synthese.cor_area_synthese ON synthese.id_synthese = cor_area_synthese.id_synthese
-- --             WHERE
-- --                     cor_area_synthese.id_area IN (
-- --                     SELECT
-- --                         id_area
-- --                         FROM
-- --                             ref_geo.l_areas
-- --                         WHERE
-- --                               id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
-- --                           AND enable)
-- --             GROUP BY cor_area_synthese.id_area
--         SELECT
--             87138                       AS id_area
--           , (815 + (20 - mod(815, 20))) AS alti
--         UNION
--         SELECT
--             87145
--           , (4810 + (20 - mod(815, 20)))
--     )
--   , ranges (id_area, range) AS (
--     SELECT
--         id_area
--       , int4range(i, i + (SELECT round(alti, -2) / 20)::INT, '[)')
--         FROM
--             maxalti
--                 CROSS JOIN generate_series(0, alti,
--                                            (SELECT round(alti, -2) / 20)::INT) t(i)
-- )
-- SELECT
--     ranges.id_area
--   , ranges.range
--   , cd_nom
--   , count(sy.altitude_min) AS range_count
--     FROM
--         ranges
--             LEFT JOIN gn_synthese.synthese sy
--                       ON sy.altitude_min <@ ranges.range
--             LEFT JOIN gn_synthese.cor_area_synthese ON sy.id_synthese = cor_area_synthese.id_synthese
--     WHERE
--           cd_nom IN (2497, 2938)
--       AND date_min > '2018-12-31'
--       AND ranges.id_area = cor_area_synthese.id_area
--     GROUP BY
--         ranges.id_area
--       , ranges.range
--       , cd_nom
--     ORDER BY
--         ranges.id_area
--       , ranges.range
--       , cd_nom
-- ;
--
-- SELECT
--     round(max(altitude_min), -3) / 10
--     FROM
--         gn_synthese.synthese
-- ;
--
-- SELECT
--     id_area
--   , id_type
--   , area_name
--   , area_code
--     FROM
--         ref_geo.l_areas
--     WHERE
--           l_areas.id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
--       AND enable
-- ;
--
--
-- SELECT *
--     FROM
--         ref_geo.bib_areas_types
--     WHERE
--         type_code NOT LIKE 'ATLAS%'
-- ;
--
--
--
-- SELECT
--     87138                       AS id_area
--   , (815 + (20 - mod(815, 20))) AS alti
-- UNION
-- SELECT
--     87145
--   , (4810 + (20 - mod(815, 20)))
-- ;
--
-- SELECT 815, 20 - mod(815, 20), (815 + (20 - mod(815, 20))), (815 + (20 - mod(815, 20))) / 20.0
-- ;
--
-- SELECT
--     id_area
--   , cd_nom
--   , count(sy.id_synthese) AS range_count
--     FROM
--         gn_synthese.synthese sy
--             LEFT JOIN gn_synthese.cor_area_synthese ON sy.id_synthese = cor_area_synthese.id_synthese
--     WHERE
--           cd_nom IN (2497, 2938)
--       AND date_min > '2018-12-31'
--       AND id_area IN (
--         SELECT
--             id_area
--             FROM
--                 ref_geo.l_areas
--             WHERE
--                   id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
--               AND enable)
--     GROUP BY
--         id_area
--       , cd_nom