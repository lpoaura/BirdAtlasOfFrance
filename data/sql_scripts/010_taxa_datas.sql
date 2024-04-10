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
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_taxa_territory_distribution;
        CREATE MATERIALIZED VIEW atlas.mv_taxa_territory_distribution AS
        WITH t1 AS (SELECT DISTINCT mtg.cd_group AS cd_nom,
                                    la.id_area,
                                    la.area_code,
                                    la.area_name
                    FROM atlas.mv_data_for_atlas
                             JOIN atlas.mv_grid_territories_matching ON id_area = id_area_grid
                             JOIN atlas.t_taxa ON mv_data_for_atlas.cd_nom = t_taxa.cd_nom
                             JOIN atlas.mv_taxa_groups mtg ON mtg.cd_nom = t_taxa.cd_nom
                             JOIN ref_geo.l_areas la ON id_area_territory = la.id_area)
        SELECT ROW_NUMBER() OVER () AS id, t1.*
        FROM t1
        ORDER BY t1.cd_nom, t1.id_area
        WITH NO DATA;

        CREATE INDEX ON atlas.mv_taxa_territory_distribution (cd_nom);
        CREATE UNIQUE INDEX ON atlas.mv_taxa_territory_distribution (cd_nom, id_area);
        COMMIT;
    END
$$
;

DO
$$
    BEGIN
        SET WORK_MEM = '10GB';
        /* Vue matérialisée finale */
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_territory_altitude_ranges CASCADE;

        CREATE MATERIALIZED VIEW atlas.mv_territory_altitude_ranges AS
        WITH maxalti AS (SELECT cor_area_synthese.id_area
                              , (MAX(mv_data_for_atlas.altitude) +
                                 (19 - MOD(MAX(mv_data_for_atlas.altitude), 19))) AS alti
                         FROM atlas.mv_data_for_atlas
                                  JOIN gn_synthese.cor_area_synthese
                                       ON mv_data_for_atlas.id_data = cor_area_synthese.id_synthese
                         WHERE cor_area_synthese.id_area IN (SELECT id_area
                                                             FROM ref_geo.l_areas
                                                             WHERE id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
                                                               AND enable)
                         GROUP BY cor_area_synthese.id_area)
        SELECT ROW_NUMBER() OVER ()                                       AS id
             , id_area
             , INT4RANGE(i, i + (SELECT ROUND(alti, -2) / 20)::INT, '[)') AS range
        FROM maxalti
                 CROSS JOIN GENERATE_SERIES(0, alti,
                                            (SELECT ROUND(alti, -2) / 20)::INT) t(i)
        WITH NO DATA;


        CREATE UNIQUE INDEX ON atlas.mv_territory_altitude_ranges (id);
        CREATE INDEX ON atlas.mv_territory_altitude_ranges (id_area);
        CREATE INDEX ON atlas.mv_data_for_atlas (altitude) WHERE new_data_all_period;

        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_alti_territory;
        CREATE MATERIALIZED VIEW atlas.mv_alti_territory AS
        WITH maxalti AS (SELECT id_area
                              , ROUND(MAX(altitude), -2) AS alti
                         FROM atlas.t_territory_altitude
                         GROUP BY id_area)
           , ranges AS (SELECT id_area
                             , INT4RANGE(i::INT, (i + (SELECT ROUND(alti, -2) / 10))::INT, '[)'::TEXT) AS range
                        FROM maxalti
                                 CROSS JOIN GENERATE_SERIES(0, alti,
                                                            (SELECT ROUND(alti, -2) / 10)::INT) t(i))
           , pixel_count_by_territory AS (SELECT id_area
                                               , SUM(pixel_count) AS total_pixel_count
                                          FROM atlas.t_territory_altitude
                                          GROUP BY id_area)
        SELECT ROW_NUMBER() OVER ()                                                     AS id
             , ranges.id_area
             , ranges.range                                                             AS range
             , ROUND(((SUM(pixel_count) / total_pixel_count::FLOAT) * 100)::NUMERIC, 1) AS percentage
             , total_pixel_count::FLOAT
        FROM ranges
                 LEFT JOIN atlas.t_territory_altitude
                           ON (t_territory_altitude.altitude <@ ranges.range AND
                               t_territory_altitude.id_area = ranges.id_area)
                 JOIN pixel_count_by_territory ON t_territory_altitude.
                                                      id_area = pixel_count_by_territory.id_area
        GROUP BY ranges.id_area, range, total_pixel_count
        WITH NO DATA;


        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_alti_distribution;
        CREATE MATERIALIZED VIEW atlas.mv_alti_distribution AS
        WITH t1 AS
                 (SELECT ROW_NUMBER() OVER ()                                    AS id
                       , id_area_territory                                       AS id_area
                       , ranges.id                                               AS id_range
                       , cd_group                                                AS cd_nom
                       , COUNT(data.altitude) FILTER (WHERE new_data_all_period) AS count_all_period
                       , COUNT(data.altitude) FILTER (WHERE new_data_breeding)   AS count_breeding
                       , COUNT(data.altitude) FILTER (WHERE new_data_wintering)  AS count_wintering
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

        SELECT ROW_NUMBER() OVER ()             AS id
             , mv_territory_altitude_ranges.id_area
             , t_taxa.cd_nom
             , mv_territory_altitude_ranges.range
             , COALESCE(t1.count_all_period, 0) AS count_all_period
             , COALESCE(t1.count_breeding, 0)   AS count_breeding
             , COALESCE(t1.count_wintering, 0)  AS count_wintering
        FROM atlas.mv_territory_altitude_ranges
                 CROSS JOIN atlas.t_taxa
                 LEFT JOIN t1 ON (t1.cd_nom = t_taxa.cd_nom
            AND mv_territory_altitude_ranges.id = t1.id_range AND
                                  mv_territory_altitude_ranges.id_area =
                                  t1.id_area)
        ORDER BY mv_territory_altitude_ranges.id_area
               , t_taxa.cd_nom, range
        WITH NO DATA;

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
                        FROM GENERATE_SERIES(1, 36) AS t(decade)
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
                           , TRUNC(EXTRACT(DOY FROM date_min) / 10)              AS decade
                           , COUNT(mv_data_for_atlas.id_data)                    AS count_data
                           , COUNT(DISTINCT mv_data_for_atlas.id_form_universal) AS count_list
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
                             , TRUNC(EXTRACT(DOY FROM date_min) / 10)
                      ORDER BY mv_grid_territories_matching.id_area_territory
                             , mv_taxa_groups.cd_group
                             , TRUNC(EXTRACT(DOY FROM date_min) / 10))
        SELECT ROW_NUMBER() OVER ()         AS id
             , matrix.id_area
             , matrix.cd_nom
             , matrix.decade
             , COALESCE(data.count_data, 0) AS count_data
             , COALESCE(data.count_list, 0) AS count_list
        FROM matrix
                 LEFT JOIN data ON (matrix.cd_nom, matrix.id_area, matrix.decade) =
                                   (data.cd_nom, data.id_area, data.decade)
        ORDER BY matrix.id_area, matrix.cd_nom, matrix.decade
        WITH NO DATA;

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
                                      , UNNEST(ARRAY ['breeding_start', 'breeding_end']::VARCHAR[]) AS status
                                      , decade
                        FROM GENERATE_SERIES(1, 36) AS t(decade)
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
                           , TRUNC(EXTRACT(DOY FROM date_min) / 10)         AS decade
                           , CASE
                                 WHEN mv_data_for_atlas.bird_breed_code = ANY (ARRAY [3]) THEN 'breeding_start'
                                 WHEN mv_data_for_atlas.bird_breed_code = ANY (ARRAY [13])
                                     THEN 'breeding_end' END                AS status
                           , COUNT(mv_data_for_atlas.*)                     AS count_data
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
                             , TRUNC(
                                  EXTRACT(
                                          DOY FROM date_min) / 10)
                             , CASE
                                   WHEN mv_data_for_atlas.bird_breed_code = ANY (ARRAY [3]) THEN 'breeding_start'
                                   WHEN mv_data_for_atlas.bird_breed_code = ANY (ARRAY [13])
                                       THEN 'breeding_end' END
                      ORDER BY mv_grid_territories_matching.id_area_territory
                             , mv_taxa_groups.cd_group
                             , TRUNC(
                                  EXTRACT(
                                          DOY FROM date_min) / 10)
                             , CASE
                                   WHEN mv_data_for_atlas.bird_breed_code = ANY (ARRAY [3]) THEN 'breeding_start'
                                   WHEN mv_data_for_atlas.bird_breed_code = ANY (ARRAY [13])
                                       THEN 'breeding_end' END)
        SELECT ROW_NUMBER() OVER ()                 AS id
             , matrix.id_area
             , matrix.cd_nom
             , COALESCE(data.status, matrix.status) AS status
             , matrix.decade
             , COALESCE(data.count_data, 0)         AS count_data
        FROM matrix
                 LEFT JOIN data
                           ON (matrix.cd_nom, matrix.id_area, matrix.decade, matrix.status) =
                              (data.cd_nom, data.id_area, data.decade, data.status)
        ORDER BY matrix.id_area, matrix.cd_nom, matrix.decade
        WITH NO DATA;

        CREATE INDEX ON atlas.mv_taxa_breeding_phenology (cd_nom);
        CREATE INDEX ON atlas.mv_taxa_breeding_phenology (id_area);
        CREATE INDEX ON atlas.mv_taxa_breeding_phenology (decade);
        CREATE INDEX ON atlas.mv_taxa_breeding_phenology (status);
        CREATE UNIQUE INDEX ON atlas.mv_taxa_breeding_phenology (id);

        DROP TABLE IF EXISTS atlas.t_taxa_migration_quantile_data;
        CREATE TABLE IF NOT EXISTS atlas.t_taxa_migration_quantile_data
        (
            id               INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
            cd_nom           INT REFERENCES atlas.t_taxa (cd_nom),
            id_area          INT REFERENCES ref_geo.l_areas (id_area),
            processing       VARCHAR,
            phenology_period public.phenology_period,
            q2_5             INT,
            q5               INT,
            q25              INT,
            median           INT,
            q75              INT,
            q95              INT,
            q97_5            INT
        );

        CREATE INDEX ON atlas.t_taxa_migration_quantile_data (cd_nom, id_area);
        COMMENT ON TABLE atlas.t_taxa_migration_quantile_data IS 'Migration quartile data';

        DROP TABLE IF EXISTS atlas.t_taxa_migration_decade_data;
        CREATE TABLE IF NOT EXISTS atlas.t_taxa_migration_decade_data
        (
            id             INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
            cd_nom         INT REFERENCES atlas.t_taxa (cd_nom),
            id_area        INT REFERENCES ref_geo.l_areas (id_area),
            processing     VARCHAR,
            decade         INT,
            count          INT,
            pivotal_decade BOOLEAN
        );

        CREATE INDEX ON atlas.t_taxa_migration_decade_data (cd_nom, id_area);
        COMMENT ON TABLE atlas.t_taxa_migration_decade_data IS 'Migration decade data';

        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_historic_atlases_data;
        CREATE MATERIALIZED VIEW atlas.mv_historic_atlases_data AS
        WITH area_type
                 AS (SELECT DISTINCT UNNEST(ARRAY [breeding_area_type, wintering_area_type, all_period_area_type]) AS id_type
                     FROM atlas.t_taxa),
             grid AS (SELECT id_area, centroid
                      FROM ref_geo.l_areas
                      WHERE id_area IN (SELECT DISTINCT id_area FROM atlas.t_historic_atlases_data)),
             area AS (SELECT id_type, id_area, geom
                      FROM ref_geo.l_areas
                      WHERE id_type IN (SELECT id_type FROM area_type))
        SELECT ROW_NUMBER() OVER ()                                      AS id,
               id_historic_atlas_info,
               CASE
                   WHEN (CASE
                             WHEN t_historic_atlases_info.season_period = 'breeding'::phenology_period
                                 THEN t_taxa.breeding_area_type
                             WHEN t_historic_atlases_info.season_period = 'wintering'::phenology_period
                                 THEN t_taxa.wintering_area_type
                             ELSE t_taxa.all_period_area_type
                       END) != ref_geo.get_id_area_type('ATLAS_GRID') THEN area.id_area
                   ELSE t_historic_atlases_data.id_area END              AS id_area,
               t_historic_atlases_data.cd_nom,
               CASE
                   WHEN 'Nicheur certain' = ANY (ARRAY_AGG(status)) THEN 'Nicheur certain'
                   WHEN 'Nicheur probable' = ANY (ARRAY_AGG(status)) THEN 'Nicheur probable'
                   WHEN 'Nicheur possible' = ANY (ARRAY_AGG(status)) THEN 'Nicheur possible'
                   WHEN 'Hivernant' = ANY (ARRAY_AGG(status)) THEN 'Hivernant'
                   WHEN 'rare' = ANY (ARRAY_AGG(status)) THEN 'rare' END AS status
        FROM atlas.t_historic_atlases_data
                 JOIN atlas.t_historic_atlases_info
                      ON t_historic_atlases_data.id_historic_atlas_info = t_historic_atlases_info.id
                 JOIN atlas.t_taxa ON t_historic_atlases_data.cd_nom = t_taxa.cd_nom
                 JOIN grid ON t_historic_atlases_data.id_area = grid.id_area
                 JOIN area ON st_within(grid.centroid, area.geom)
            AND grid.id_area IN (SELECT DISTINCT id_area FROM atlas.t_historic_atlases_data)
            AND area.id_type IN (SELECT id_type FROM area_type)
        WHERE area.id_type = CASE
                                 WHEN t_historic_atlases_info.season_period = 'breeding' THEN breeding_area_type
                                 WHEN t_historic_atlases_info.season_period = 'wintering' THEN wintering_area_type
                                 ELSE all_period_area_type END
        GROUP BY id_historic_atlas_info,
                 CASE
                     WHEN (CASE
                               WHEN t_historic_atlases_info.season_period = 'breeding'::phenology_period
                                   THEN t_taxa.breeding_area_type
                               WHEN t_historic_atlases_info.season_period = 'wintering'::phenology_period
                                   THEN t_taxa.wintering_area_type
                               ELSE t_taxa.all_period_area_type
                         END) != ref_geo.get_id_area_type('ATLAS_GRID') THEN area.id_area
                     ELSE t_historic_atlases_data.id_area END,
                 t_historic_atlases_data.cd_nom;

        CREATE INDEX ON atlas.mv_historic_atlases_data (id_historic_atlas_info);
        CREATE INDEX ON atlas.mv_historic_atlases_data (id_area);
        CREATE INDEX ON atlas.mv_historic_atlases_data (cd_nom);
        CREATE INDEX ON atlas.mv_historic_atlases_data (status);

        COMMENT ON TABLE atlas.mv_historic_atlases_data IS 'Historic atlases data (one data is on specie on one area (grid) with one status from one source';

        COMMIT;
    END
$$
;
