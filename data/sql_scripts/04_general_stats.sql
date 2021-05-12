/*
Home - General stats
-----
Statistiques générales de la plateforme 
 */
DO
$$
    BEGIN
        /* Vue matérialisée finale */
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_general_stats;
        CREATE MATERIALIZED VIEW atlas.mv_general_stats AS
        WITH
            fromdata AS (
                SELECT
                            count(DISTINCT mv_taxa_groups.cd_group)
                            FILTER (WHERE mv_data_for_atlas.new_data_all_period) AS count_taxa_all_period
                  ,         count(DISTINCT mv_taxa_groups.cd_group)
                            FILTER (WHERE mv_data_for_atlas.new_data_breeding)   AS count_taxa_breeding
                  ,         count(DISTINCT mv_taxa_groups.cd_group)
                            FILTER (WHERE mv_data_for_atlas.new_data_wintering)  AS count_taxa_wintering
                    FROM
                        atlas.mv_data_for_atlas
                            JOIN atlas.t_taxa ON t_taxa.cd_nom = mv_data_for_atlas.cd_nom
                            JOIN atlas.mv_taxa_groups ON t_taxa.cd_nom = mv_taxa_groups.cd_nom
--                             JOIN atlas.t_taxa ON mv_data_for_atlas.cd_nom = t_taxa.cd_nom
            )
          , fromforms AS (
            SELECT
                ((sum(mv_forms_for_atlas.timelength_secs) FILTER (WHERE NOT is_breeding AND NOT is_wintering)) /
                 3600)::INT AS prospecting_hours_other_period
              , ((sum(mv_forms_for_atlas.timelength_secs) FILTER (WHERE is_breeding)) /
                 3600)::INT AS prospecting_hours_breeding
              , ((sum(mv_forms_for_atlas.timelength_secs) FILTER (WHERE is_wintering)) /
                 3600)::INT AS prospecting_hours_wintering
                FROM
                    atlas.mv_forms_for_atlas
        )
        SELECT
            1 AS id
          , fromdata.*
          , fromforms.*
            FROM
                fromdata
              , fromforms;
        COMMIT;
    END
$$
;

