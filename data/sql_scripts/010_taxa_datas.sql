/*
TAXA DATAS
-----
Taxa relative data (generally by atlas territories)
* Altitude distribution:
    TODO: Altitude distribution, actually returns 21 classes...
    TODO: Phenology distribution (count by decade, frequency in lists by decade)
        - Generate a materialized view with columns:
            - cd_nom
            - decade
            - count data
            - count list
        - Generate materialized view with list count by decade for frequency comparision
* ...
 */


DO
$$
    BEGIN
        SET WORK_MEM = '10GB';
        /* Vue matérialisée finale */
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_territory_altitude_ranges;

        CREATE MATERIALIZED VIEW atlas.mv_territory_altitude_ranges AS
        WITH
            maxalti AS (SELECT
                            cor_area_synthese.id_area
                          , (max(mv_data_for_atlas.altitude) + (19 - mod(max(mv_data_for_atlas.altitude), 19))) AS alti
                            FROM
                                atlas.mv_data_for_atlas
                                    JOIN gn_synthese.cor_area_synthese
                                         ON mv_data_for_atlas.id_data = cor_area_synthese.id_synthese
                            WHERE
                                    cor_area_synthese.id_area IN (SELECT
                                                                      id_area
                                                                      FROM
                                                                          ref_geo.l_areas
                                                                      WHERE
                                                                            id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
                                                                        AND enable)
                            GROUP BY cor_area_synthese.id_area)
        SELECT
            row_number() OVER ()                                       AS id
          , id_area
          , int4range(i, i + (SELECT round(alti, -2) / 20)::INT, '[)') AS range
            FROM
                maxalti
                    CROSS JOIN generate_series(0, alti,
                                               (SELECT round(alti, -2) / 20)::INT) t(i);


        CREATE UNIQUE INDEX ON atlas.mv_territory_altitude_ranges (id);
        CREATE INDEX ON atlas.mv_territory_altitude_ranges (id_area);
        CREATE INDEX ON atlas.mv_data_for_atlas (altitude) WHERE new_data_all_period;

        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_alti_distribution;
        CREATE MATERIALIZED VIEW atlas.mv_alti_distribution AS
        (
        SELECT
            row_number() OVER () AS id
          , id_area_territory    AS id_area
          , ranges.id            AS id_range
          , cd_group             AS cd_nom
          , count(data.altitude) AS count
            FROM
                atlas.mv_territory_altitude_ranges AS ranges
                    LEFT JOIN atlas.mv_data_for_atlas data
                              ON data.altitude <@ ranges.range AND new_data_all_period
                    JOIN atlas.mv_grid_territories_matching
                         ON data.id_area = mv_grid_territories_matching.id_area_grid AND
                            ranges.id_area = mv_grid_territories_matching.id_area_territory
                    JOIN atlas.mv_taxa_groups ON data.cd_nom = mv_taxa_groups.cd_nom
                    JOIN atlas.t_taxa
                         ON t_taxa.cd_nom = mv_taxa_groups.cd_group AND (t_taxa.available AND t_taxa.enabled)
            GROUP BY
                id_area_territory, mv_taxa_groups.cd_group, ranges.id
            ORDER BY
                id_area_territory, mv_taxa_groups.cd_group, ranges.id);
        CREATE UNIQUE INDEX ON atlas.mv_alti_distribution (id);
        CREATE INDEX ON atlas.mv_alti_distribution (cd_nom);
        CREATE INDEX ON atlas.mv_alti_distribution (id_area);
        CREATE INDEX ON atlas.mv_alti_distribution (id_range);
        COMMIT;
    END
$$
;


DO
$$
    BEGIN
        /* Vue matérialisée finale */
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_taxa_breeding_phenology;
        CREATE MATERIALIZED VIEW atlas.mv_taxa_breeding_phenology AS
        SELECT
            row_number() OVER ()                              AS id
          , id_area_territory                                 AS id_area
          , cd_group                                          AS cd_nom
          , t.decade                                          AS decade
          , count(data.*) FILTER (WHERE bird_breed_code = 3)  AS breeding_start
          , count(data.*) FILTER (WHERE bird_breed_code = 13) AS breeding_end
            FROM
                generate_series(1, 36, 1) AS t(decade)
                    LEFT JOIN atlas.mv_data_for_atlas data ON trunc(extract(DOY FROM date_min) / 10) = t.decade
                    JOIN atlas.mv_taxa_groups ON data.cd_nom = mv_taxa_groups.cd_nom
                    JOIN atlas.t_taxa
                         ON t_taxa.cd_nom = mv_taxa_groups.cd_group AND (t_taxa.available AND t_taxa.enabled)
                    JOIN atlas.mv_grid_territories_matching ON id_area_grid = data.id_area
            WHERE
                coalesce(new_data_breeding, TRUE)
-- new_data_breeding
            GROUP BY
                id_area_territory, mv_taxa_groups.cd_group, t.decade
            ORDER BY
                id_area_territory, mv_taxa_groups.cd_group, t.decade;
        CREATE UNIQUE INDEX ON atlas.mv_taxa_breeding_phenology (id);
        CREATE INDEX ON atlas.mv_taxa_breeding_phenology (cd_nom);
        CREATE INDEX ON atlas.mv_taxa_breeding_phenology (id_area);

        COMMIT;
    END
$$
;

SELECT *
    FROM
        generate_series(1, 36, 1) AS t(decade)
;

DO
$$
    BEGIN
        SET WORK_MEM = '10GB';

        COMMIT;
    END
$$
;

SELECT *
    FROM
        atlas.mv_taxa_breeding_phenology
    WHERE
        cd_nom = 4117
;

--
-- SELECT *
--     FROM
--         atlas.mv_alti_distribution
-- ;
--
-- GRANT SELECT ON atlas.mv_alti_distribution TO odfapp
-- ;
--
-- SELECT
--     atlas.mv_alti_distribution.range AS atlas_mv_alti_distribution_range
--   , atlas.mv_alti_distribution.count AS atlas_mv_alti_distribution_count
--     FROM
--         atlas.mv_alti_distribution
--     WHERE
--         atlas.mv_alti_distribution.id_area = 87138
-- ;

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
--
-- CREATE TABLE tmp.max_alti_by_territory AS
-- SELECT
--     cor_area_synthese.id_area
--   , (max(mv_data_for_atlas.altitude) + (20 - mod(max(mv_data_for_atlas.altitude), 20))) AS alti
--     FROM
--         atlas.mv_data_for_atlas
--             JOIN gn_synthese.cor_area_synthese
--                  ON mv_data_for_atlas.id_data = cor_area_synthese.id_synthese
--     WHERE
--             cor_area_synthese.id_area IN (
--             SELECT
--                 id_area
--                 FROM
--                     ref_geo.l_areas
--                 WHERE
--                       id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
--                   AND enable)
--     GROUP BY
--         cor_area_synthese.id_area
-- ;
--
-- SELECT
--     row_number() OVER ()                                       AS id
--   , id_area
--   , int4range(i, i + (SELECT round(alti, -2) / 20)::INT, '[)') AS range
--     FROM
--         tmp.max_alti_by_territory
--             CROSS JOIN generate_series(0, round(alti, -2)::int,
--                                        (round(alti, -2) / 20)::INT) t(i)
-- ;
--
-- SELECT *
--     FROM
--         tmp.max_alti_by_territory
-- ;
--
-- SELECT
--     alti
--   , ceil(alti / pow(20, 2)) * pow(20, 2)
--   , ceil(alti / pow(20, 2)) * pow(20, 2)/20
--     FROM
--         tmp.max_alti_by_territory;

SELECT
    species_json.id
  , item ->> 'latin_name'  AS latin_name
  , item ->> 'french_name' AS french_name
    FROM
        src_vn_json.species_json
            LEFT JOIN taxonomie.cor_c_vn_taxref ON species_json.id = cor_c_vn_taxref.vn_id
    WHERE
          item ->> 'id_taxo_group' = '1'
      AND cor_c_vn_taxref.taxref_id IS NULL
;


SELECT *
    FROM
        src_historic_atlas.historic_atlas
;
