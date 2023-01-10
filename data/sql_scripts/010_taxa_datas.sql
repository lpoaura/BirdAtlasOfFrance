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
        WITH maxalti AS (SELECT cor_area_synthese.id_area
                              , (max(mv_data_for_atlas.altitude) +
                                 (19 - mod(max(mv_data_for_atlas.altitude), 19))) AS alti
                         FROM atlas.mv_data_for_atlas
                                  JOIN gn_synthese.cor_area_synthese
                                       ON mv_data_for_atlas.id_data = cor_area_synthese.id_synthese
                         WHERE cor_area_synthese.id_area IN (SELECT id_area
                                                             FROM ref_geo.l_areas
                                                             WHERE id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
                                                               AND enable)
                         GROUP BY cor_area_synthese.id_area)
        SELECT row_number() OVER ()                                       AS id
             , id_area
             , int4range(i, i + (SELECT round(alti, -2) / 20)::INT, '[)') AS range
        FROM maxalti
                 CROSS JOIN generate_series(0, alti,
                                            (SELECT round(alti, -2) / 20)::INT) t(i);


        CREATE UNIQUE INDEX ON atlas.mv_territory_altitude_ranges (id);
        CREATE INDEX ON atlas.mv_territory_altitude_ranges (id_area);
        CREATE INDEX ON atlas.mv_data_for_atlas (altitude) WHERE new_data_all_period;

        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_alti_territory;
        CREATE MATERIALIZED VIEW atlas.mv_alti_territory AS
        WITH maxalti AS (SELECT id_area
                              , round(max(altitude), -2) AS alti
                         FROM atlas.t_territory_altitude
                         GROUP BY id_area)
           , ranges AS (SELECT id_area
                             , int4range(i::INT, (i + (SELECT round(alti, -2) / 10))::INT, '[)'::TEXT) AS range
                        FROM maxalti
                                 CROSS JOIN generate_series(0, alti,
                                                            (SELECT round(alti, -2) / 10)::INT) t(i))
           , pixel_count_by_territory AS (SELECT id_area
                                               , sum(pixel_count) AS total_pixel_count
                                          FROM atlas.t_territory_altitude
                                          GROUP BY id_area)
        SELECT row_number() OVER ()                                                     AS id
             , ranges.id_area
             , ranges.range                                                             AS range
             , round(((sum(pixel_count) / total_pixel_count::FLOAT) * 100)::NUMERIC, 1) AS percentage
             , total_pixel_count::FLOAT
        FROM ranges
                 LEFT JOIN atlas.t_territory_altitude
                           ON (t_territory_altitude.altitude <@ ranges.range AND
                               t_territory_altitude.id_area = ranges.id_area)
                 JOIN pixel_count_by_territory ON t_territory_altitude.
                                                      id_area = pixel_count_by_territory.id_area
        GROUP BY ranges.id_area, range, total_pixel_count;


        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_alti_distribution;
        CREATE MATERIALIZED VIEW atlas.mv_alti_distribution AS
        WITH t1 AS
                 (SELECT row_number() OVER ()                                    AS id
                       , id_area_territory                                       AS id_area
                       , ranges.id                                               AS id_range
                       , cd_group                                                AS cd_nom
                       , count(data.altitude) FILTER (WHERE new_data_all_period) AS count_all_period
                       , count(data.altitude) FILTER (WHERE new_data_breeding)   AS count_breeding
                       , count(data.altitude) FILTER (WHERE new_data_wintering)  AS count_wintering
                  FROM atlas.mv_territory_altitude_ranges AS ranges
                           LEFT JOIN atlas.mv_data_for_atlas data
                                     ON data.altitude <@ ranges.range AND new_data_all_period
                           JOIN atlas.mv_grid_territories_matching
                                ON data.id_area = mv_grid_territories_matching.id_area_grid AND
                                   ranges.id_area = mv_grid_territories_matching.id_area_territory
                           JOIN ref_geo.l_areas
                                ON l_areas.id_area = mv_grid_territories_matching.id_area_territory AND l_areas.enable
                           JOIN atlas.mv_taxa_groups ON data.cd_nom = mv_taxa_groups.cd_nom
                           JOIN atlas.t_taxa
                                ON t_taxa.cd_nom = mv_taxa_groups.cd_group AND (t_taxa.available AND t_taxa.enabled)
                  GROUP BY id_area_territory, mv_taxa_groups.cd_group, ranges.id
                  ORDER BY id_area_territory, mv_taxa_groups.cd_group, ranges.id)

        SELECT row_number() OVER ()             AS id
             , mv_territory_altitude_ranges.id_area
             , t_taxa.cd_nom
             , mv_territory_altitude_ranges.range
             , coalesce(t1.count_all_period, 0) AS count_all_period
             , coalesce(t1.count_breeding, 0)   AS count_breeding
             , coalesce(t1.count_wintering, 0)  AS count_wintering
        FROM atlas.mv_territory_altitude_ranges
                 CROSS JOIN atlas.t_taxa
                 LEFT JOIN t1 ON (t1.cd_nom = t_taxa.cd_nom
            AND mv_territory_altitude_ranges.id = t1.id_range AND
                                  mv_territory_altitude_ranges.id_area =
                                  t1.id_area)
        ORDER BY mv_territory_altitude_ranges.id_area
               , t_taxa.cd_nom, range;
        ;
        CREATE UNIQUE INDEX ON atlas.mv_alti_distribution (id);
        CREATE INDEX ON atlas.mv_alti_distribution (cd_nom);
        CREATE INDEX ON atlas.mv_alti_distribution (id_area);
        COMMIT;
    END
$$
;


DO
$$
    BEGIN
        /* Phenology des obs */

        /* Vue matérialisée finale */
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_taxa_allperiod_phenology;

        CREATE MATERIALIZED VIEW atlas.mv_taxa_allperiod_phenology AS
        WITH matrix AS (SELECT DISTINCT decade
                                      , l_areas.id_area         AS id_area
                                      , mv_taxa_groups.cd_group AS cd_nom
                        FROM generate_series(1, 36) AS t(decade)
                                 CROSS JOIN (atlas.mv_taxa_groups
                            JOIN atlas.t_taxa
                                             ON t_taxa.cd_nom = mv_taxa_groups.cd_group AND
                                                (t_taxa.available AND t_taxa.enabled))
                           , ref_geo.l_areas
                        WHERE l_areas.id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
                          AND l_areas.enable
                        ORDER BY id_area, cd_nom, decade)
           , data AS (SELECT mv_grid_territories_matching.id_area_territory      AS id_area
                           , mv_taxa_groups.cd_group                             AS cd_nom
                           , trunc(extract(DOY FROM date_min) / 10)              AS decade
                           , count(mv_data_for_atlas.id_data)                    AS count_data
                           , count(DISTINCT mv_data_for_atlas.id_form_universal) AS count_list
                      FROM atlas.mv_data_for_atlas
                               JOIN atlas.mv_grid_territories_matching
                                    ON mv_data_for_atlas.id_area = mv_grid_territories_matching.id_area_grid
                               JOIN ref_geo.l_areas
                                    ON mv_grid_territories_matching.id_area_territory = l_areas.id_area
                               JOIN atlas.t_taxa ON mv_data_for_atlas.cd_nom = t_taxa.cd_nom
                               JOIN atlas.mv_taxa_groups ON t_taxa.cd_nom = mv_taxa_groups.cd_nom
                      WHERE new_data_all_period
                        AND (t_taxa.available AND t_taxa.enabled)
                        AND l_areas.enable
                      GROUP BY mv_grid_territories_matching.id_area_territory
                             , mv_taxa_groups.cd_group
                             , trunc(extract(DOY FROM date_min) / 10)
                      ORDER BY mv_grid_territories_matching.id_area_territory
                             , mv_taxa_groups.cd_group
                             , trunc(extract(DOY FROM date_min) / 10))
        SELECT row_number() OVER ()         AS id
             , matrix.id_area
             , matrix.cd_nom
             , matrix.decade
             , coalesce(data.count_data, 0) AS count_data
             , coalesce(data.count_list, 0) AS count_list
        FROM matrix
                 LEFT JOIN data ON (matrix.cd_nom, matrix.id_area, matrix.decade) =
                                   (data.cd_nom, data.id_area, data.decade)
        ORDER BY matrix.id_area, matrix.cd_nom, matrix.decade;

        CREATE INDEX ON atlas.mv_taxa_allperiod_phenology (cd_nom);
        CREATE INDEX ON atlas.mv_taxa_allperiod_phenology (id_area);
        CREATE UNIQUE INDEX ON atlas.mv_taxa_allperiod_phenology (id);
        COMMIT;
    END
$$
;

DO
$$
    BEGIN
        /* Phenology des obs */

        /* Vue matérialisée finale */
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_taxa_breeding_phenology;

        CREATE MATERIALIZED VIEW atlas.mv_taxa_breeding_phenology AS
        WITH matrix AS (SELECT DISTINCT l_areas.id_area                                             AS id_area
                                      , mv_taxa_groups.cd_group                                     AS cd_nom
                                      , unnest(ARRAY ['breeding_start', 'breeding_end']::VARCHAR[]) AS status
                                      , decade
                        FROM generate_series(1, 36) AS t(decade)
                                 CROSS JOIN (atlas.mv_taxa_groups
                            JOIN atlas.t_taxa
                                             ON t_taxa.cd_nom = mv_taxa_groups.cd_group AND
                                                (t_taxa.available AND t_taxa.enabled))
                           , ref_geo.l_areas
                        WHERE l_areas.id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
                          AND l_areas.enable
                        ORDER BY 1, 2, 3, 4)
           , data AS (SELECT mv_grid_territories_matching.id_area_territory AS id_area
                           , mv_taxa_groups.cd_group                        AS cd_nom
                           , trunc(extract(DOY FROM date_min) / 10)         AS decade
                           , CASE
                                 WHEN mv_data_for_atlas.bird_breed_code = ANY (ARRAY [3]) THEN 'breeding_start'
                                 WHEN mv_data_for_atlas.bird_breed_code = ANY (ARRAY [13])
                                     THEN 'breeding_end' END                AS status
                           , count(mv_data_for_atlas.*)                     AS count_data
                      FROM atlas.mv_data_for_atlas
                               JOIN atlas.mv_grid_territories_matching
                                    ON mv_data_for_atlas.id_area = mv_grid_territories_matching.id_area_grid
                               JOIN ref_geo.l_areas
                                    ON mv_grid_territories_matching.id_area_territory = l_areas.id_area
                               JOIN atlas.t_taxa ON mv_data_for_atlas.cd_nom = t_taxa.cd_nom
                               JOIN atlas.mv_taxa_groups ON t_taxa.cd_nom = mv_taxa_groups.cd_nom
                      WHERE new_data_breeding
                        AND (
                              t_taxa.available
                              AND t_taxa.enabled)
                        AND l_areas.enable
                        AND mv_data_for_atlas.bird_breed_code = ANY (ARRAY [3, 13])
                      GROUP BY mv_grid_territories_matching.id_area_territory
                             , mv_taxa_groups.cd_group
                             , trunc(
                                  extract(
                                          DOY FROM date_min) / 10)
                             , CASE
                                   WHEN mv_data_for_atlas.bird_breed_code = ANY (ARRAY [3]) THEN 'breeding_start'
                                   WHEN mv_data_for_atlas.bird_breed_code = ANY (ARRAY [13])
                                       THEN 'breeding_end' END
                      ORDER BY mv_grid_territories_matching.id_area_territory
                             , mv_taxa_groups.cd_group
                             , trunc(
                                  extract(
                                          DOY FROM date_min) / 10)
                             , CASE
                                   WHEN mv_data_for_atlas.bird_breed_code = ANY (ARRAY [3]) THEN 'breeding_start'
                                   WHEN mv_data_for_atlas.bird_breed_code = ANY (ARRAY [13])
                                       THEN 'breeding_end' END)
        SELECT row_number() OVER ()         AS id
             , matrix.id_area
             , matrix.cd_nom
             , data.status
             , matrix.decade
             , coalesce(data.count_data, 0) AS count_data
        FROM matrix
                 LEFT JOIN data
                           ON (matrix.cd_nom, matrix.id_area, matrix.decade, matrix.status) =
                              (data.cd_nom, data.id_area, data.decade, data.status)
        ORDER BY matrix.id_area, matrix.cd_nom, matrix.decade;

        CREATE INDEX ON atlas.mv_taxa_breeding_phenology (cd_nom);
        CREATE INDEX ON atlas.mv_taxa_breeding_phenology (id_area);
        CREATE INDEX ON atlas.mv_taxa_breeding_phenology (decade);
        CREATE INDEX ON atlas.mv_taxa_breeding_phenology (status);
        CREATE UNIQUE INDEX ON atlas.mv_taxa_breeding_phenology (id);
        COMMIT;
    END
$$
;

--
-- DO
-- $$
--     BEGIN
--         /* Vue matérialisée finale */
--         DROP MATERIALIZED VIEW IF EXISTS atlas.mv_taxa_breeding_phenology;
--         CREATE MATERIALIZED VIEW atlas.mv_taxa_breeding_phenology AS
--         SELECT row_number() OVER ()                              AS id
--              , id_area_territory                                 AS id_area
--              , cd_group                                          AS cd_nom
--              , t.decade                                          AS decade
--              , count(data.*) FILTER (WHERE bird_breed_code = 3)  AS breeding_start
--              , count(data.*) FILTER (WHERE bird_breed_code = 13) AS breeding_end
--         FROM generate_series(1, 36) AS t(decade)
--                  LEFT JOIN atlas.mv_data_for_atlas data ON trunc(extract(DOY FROM date_min) / 10) = t.decade
--                  JOIN atlas.mv_taxa_groups ON data.cd_nom = mv_taxa_groups.cd_nom
--                  JOIN atlas.t_taxa
--                       ON t_taxa.cd_nom = mv_taxa_groups.cd_group AND (t_taxa.available AND t_taxa.enabled)
--                  JOIN atlas.mv_grid_territories_matching ON id_area_grid = data.id_area
--         WHERE coalesce(new_data_breeding, TRUE)
-- -- new_data_breeding
--         GROUP BY id_area_territory, mv_taxa_groups.cd_group, t.decade
--         ORDER BY id_area_territory, mv_taxa_groups.cd_group, t.decade;
--         CREATE UNIQUE INDEX ON atlas.mv_taxa_breeding_phenology (id);
--         CREATE INDEX ON atlas.mv_taxa_breeding_phenology (cd_nom);
--         CREATE INDEX ON atlas.mv_taxa_breeding_phenology (id_area);
--
--         COMMIT;
--     END
-- $$
-- ;


DO
$$
    BEGIN
        SET WORK_MEM = '10GB';
        /* Migration phenology */
        WITH selected_taxa AS (SELECT id_area_territory
                                    , cd_nom
                                    , count(*)
                               FROM atlas.mv_data_for_atlas
                                        JOIN atlas.mv_grid_territories_matching
                                             ON mv_data_for_atlas.id_area = mv_grid_territories_matching.id_area_grid
                                        JOIN ref_geo.l_areas ON id_area_territory = l_areas.id_area
                               WHERE mv_data_for_atlas.active_migration
                                 AND l_areas.enable
                               GROUP BY id_area_territory, cd_nom
                               HAVING count(*) > 200)
           , matrix AS (SELECT FROM generate_series(1, 36))
        SELECT atlas.mv_alcross JOIN atlas.mv_taxa_groups
                                 JOIN atlas.t_taxa
        ON t_taxa.
        cd_nom = mv_taxa_groups.cd_group AND
                 (t_taxa.available AND t_taxa.enabled)
                 ,
                 atlas.mv_grid_territories_matching;

        COMMIT;
    END
$$
;


GRANT SELECT ON ALL TABLES IN SCHEMA atlas TO odfapp
;

SELECT *
FROM atlas.mv_alti_territory
;

GRANT SELECT ON ALL TABLES IN SCHEMA atlas TO odfapp
;