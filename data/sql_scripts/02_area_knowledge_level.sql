/*
AREA KNOWLEDGE LEVEL
--------------------
Evaluate for each area and each season  knowledge level comparing old taxa count with new taxa count
*/

DO
$$
    BEGIN
        /* Vue matérialisée finale */
        RAISE NOTICE 'INFO: (RE)CREATE MV atlas mv_area_knowledge_level';
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_area_knowledge_level;
        CREATE MATERIALIZED VIEW atlas.mv_area_knowledge_level AS
        (
        WITH
            areas AS (
                SELECT
                    l_areas.id_area
                  , l_areas.area_name
                  , l_areas.area_code
                  , l_areas.id_type
                  , st_transform(l_areas.geom, 4326) AS geom
                    FROM
                        ref_geo.l_areas
                    WHERE
                          id_type = ref_geo.get_id_area_type('ATLAS_GRID')
                      AND l_areas.enable
            )
          , new_data_allperiod AS (
            SELECT DISTINCT
                areas.id_area
              , count(DISTINCT mv_taxa_groups.cd_group) AS count_cd_nom
                FROM
                    atlas.mv_data_for_atlas
                        JOIN atlas.mv_taxa_groups ON mv_data_for_atlas.cd_nom = mv_taxa_groups.cd_nom
                        JOIN atlas.t_taxa ON t_taxa.cd_nom = mv_taxa_groups.cd_group
                        JOIN gn_synthese.cor_area_synthese ON mv_data_for_atlas.id_data = cor_area_synthese.id_synthese
                        JOIN areas ON cor_area_synthese.id_area = areas.id_area
                WHERE
                      t_taxa.enabled
                  AND mv_data_for_atlas.date_min > '2019-01-31'::DATE
                GROUP BY areas.id_area
        )
          , old_data_allperiod AS (
            SELECT DISTINCT
                areas.id_area
              , count(DISTINCT mv_taxa_groups.cd_group) AS count_cd_nom
                FROM
                    atlas.mv_data_for_atlas
                        JOIN atlas.mv_taxa_groups ON mv_data_for_atlas.cd_nom = mv_taxa_groups.cd_nom
                        JOIN atlas.t_taxa ON t_taxa.cd_nom = mv_taxa_groups.cd_group
                        JOIN gn_synthese.cor_area_synthese ON mv_data_for_atlas.id_data = cor_area_synthese.id_synthese
                        JOIN areas ON cor_area_synthese.id_area = areas.id_area
                WHERE
                      t_taxa.enabled
                  AND mv_data_for_atlas.date_min < '2019-01-31'::DATE
                GROUP BY areas.id_area
        )
          , old_data_wintering AS (
            SELECT DISTINCT
                areas.id_area
              , count(DISTINCT mv_taxa_groups.cd_group) AS count_cd_nom
                FROM
                    atlas.mv_data_for_atlas
                        JOIN src_lpodatas.t_c_synthese_extended tcse ON mv_data_for_atlas.id_data = tcse.id_synthese
                        JOIN atlas.mv_taxa_groups ON mv_data_for_atlas.cd_nom = mv_taxa_groups.cd_nom
                        JOIN atlas.t_taxa ON t_taxa.cd_nom = mv_taxa_groups.cd_group
                        JOIN gn_synthese.cor_area_synthese ON mv_data_for_atlas.id_data = cor_area_synthese.id_synthese
                        JOIN areas ON cor_area_synthese.id_area = areas.id_area
                WHERE
                      t_taxa.enabled
                  AND tcse.bird_breed_code IS NULL
                  AND extract(
                              MONTH
                              FROM mv_data_for_atlas.date_min
                          ) IN (12, 1)
                  AND mv_data_for_atlas.date_min < '2019-01-31'
                GROUP BY areas.id_area
        )
          , new_data_wintering AS (
            SELECT DISTINCT
                areas.id_area
              , count(DISTINCT mv_taxa_groups.cd_group) AS count_cd_nom
                FROM
                    atlas.mv_data_for_atlas
                        JOIN src_lpodatas.t_c_synthese_extended tcse ON mv_data_for_atlas.id_data = tcse.id_synthese
                        JOIN atlas.mv_taxa_groups ON mv_data_for_atlas.cd_nom = mv_taxa_groups.cd_nom
                        JOIN atlas.t_taxa ON t_taxa.cd_nom = mv_taxa_groups.cd_group
                        JOIN gn_synthese.cor_area_synthese ON mv_data_for_atlas.id_data = cor_area_synthese.id_synthese
                        JOIN areas ON cor_area_synthese.id_area = areas.id_area
                WHERE
                      t_taxa.enabled
                  AND tcse.bird_breed_code IS NULL
                  AND extract(
                              MONTH
                              FROM mv_data_for_atlas.date_min
                          ) IN (12, 1)
                  AND mv_data_for_atlas.date_min > '2019-11-30'
                GROUP BY areas.id_area
        )
          , old_data_breeding AS (
            SELECT DISTINCT
                areas.id_area
              , count(DISTINCT mv_taxa_groups.cd_group) AS count_cd_nom
                FROM
                    atlas.mv_data_for_atlas
                        JOIN src_lpodatas.t_c_synthese_extended tcse ON mv_data_for_atlas.id_data = tcse.id_synthese
                        JOIN atlas.mv_taxa_groups ON mv_data_for_atlas.cd_nom = mv_taxa_groups.cd_nom
                        JOIN atlas.t_taxa ON t_taxa.cd_nom = mv_taxa_groups.cd_group
                        JOIN gn_synthese.cor_area_synthese ON mv_data_for_atlas.id_data = cor_area_synthese.id_synthese
                        JOIN areas ON cor_area_synthese.id_area = areas.id_area
                WHERE
                      t_taxa.enabled
                  AND tcse.bird_breed_code BETWEEN 2 AND 50
                  AND mv_data_for_atlas.date_min < '2019-01-01'
                GROUP BY areas.id_area
        )
          , new_data_breeding AS (
            SELECT DISTINCT
                areas.id_area
              , count(DISTINCT mv_taxa_groups.cd_group) AS count_cd_nom
                FROM
                    atlas.mv_data_for_atlas
                        JOIN src_lpodatas.t_c_synthese_extended tcse ON mv_data_for_atlas.id_data = tcse.id_synthese
                        JOIN atlas.mv_taxa_groups ON mv_data_for_atlas.cd_nom = mv_taxa_groups.cd_nom
                        JOIN atlas.t_taxa ON t_taxa.cd_nom = mv_taxa_groups.cd_group
                        JOIN gn_synthese.cor_area_synthese ON mv_data_for_atlas.id_data = cor_area_synthese.id_synthese
                        JOIN areas ON cor_area_synthese.id_area = areas.id_area
                WHERE
                      t_taxa.enabled
                  AND tcse.bird_breed_code BETWEEN 2 AND 50
                  AND mv_data_for_atlas.date_min > '2018-12-31'::DATE
                GROUP BY areas.id_area
        )
        SELECT
            areas.id_area
          , areas.area_name
          , areas.area_code
          , areas.id_type
          , old_data_allperiod.count_cd_nom AS allperiod_count_taxa_old
          , new_data_allperiod.count_cd_nom AS allperiod_count_taxa_new
          , CASE
                WHEN old_data_allperiod.count_cd_nom = 0 THEN 1
                ELSE (
                        new_data_allperiod.count_cd_nom::REAL / old_data_allperiod.count_cd_nom
                    )
                END                         AS allperiod_percent_knowledge
          , old_data_breeding.count_cd_nom  AS breeding_count_taxa_old
          , new_data_breeding.count_cd_nom  AS breeding_count_taxa_new
          , CASE
                WHEN old_data_breeding.count_cd_nom = 0 THEN 1
                ELSE (
                    new_data_breeding.count_cd_nom::REAL / old_data_breeding.count_cd_nom
                    )
                END                         AS breeding_percent_knowledge
          , old_data_wintering.count_cd_nom AS wintering_count_taxa_old
          , new_data_wintering.count_cd_nom AS wintering_count_taxa_new
          , CASE
                WHEN old_data_wintering.count_cd_nom = 0 THEN 1
                ELSE (
                        new_data_wintering.count_cd_nom::REAL / old_data_wintering.count_cd_nom
                    )
                END                         AS wintering_percent_knowledge
          , st_asgeojson(areas.geom)        AS geojson_geom
          , areas.geom                      AS geom
            FROM
                areas
                    LEFT JOIN old_data_allperiod ON old_data_allperiod.id_area = areas.id_area
                    LEFT JOIN new_data_allperiod ON new_data_allperiod.id_area = areas.id_area
                    LEFT JOIN old_data_breeding ON old_data_breeding.id_area = areas.id_area
                    LEFT JOIN new_data_breeding ON new_data_breeding.id_area = areas.id_area
                    LEFT JOIN new_data_wintering ON new_data_wintering.id_area = areas.id_area
                    LEFT JOIN old_data_wintering ON old_data_wintering.id_area = areas.id_area)

        WITH NO DATA;
        COMMENT ON MATERIALIZED VIEW atlas.mv_area_knowledge_level IS 'Synthèse de l''état des prospection par mailles comparativement à l''atlas précédent';
        CREATE INDEX i_area_knowledge_level_geom ON atlas.mv_area_knowledge_level USING gist (geom);
        CREATE UNIQUE INDEX i_uniq_area_knowledge_level_id_area ON atlas.mv_area_knowledge_level (id_area);
        CREATE INDEX i_area_knowledge_level_area_code ON atlas.mv_area_knowledge_level (area_code);
        CREATE INDEX i_area_knowledge_level_area_name ON atlas.mv_area_knowledge_level (area_name);
        CREATE INDEX i_area_knowledge_level_area_id_type ON atlas.mv_area_knowledge_level (id_type);
        COMMIT;
    END
$$
;


REFRESH MATERIALIZED VIEW atlas.mv_area_knowledge_level;