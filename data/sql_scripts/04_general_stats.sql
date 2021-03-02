/*
TITLE
-----
Description
*/

DO
$$
    BEGIN
        /* Vue matérialisée finale */
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_general_stats;
        CREATE MATERIALIZED VIEW atlas.mv_general_stats AS
        SELECT
                    count(DISTINCT cd_nom) FILTER (WHERE mv_data_for_atlas.new_data_all_period) AS count_taxa_all_period
          ,         count(DISTINCT cd_nom) FILTER (WHERE mv_data_for_atlas.new_data_breeding)   AS count_taxa_breeding
          ,         count(DISTINCT cd_nom)
                    FILTER (WHERE mv_data_for_atlas.new_data_wintering)                         AS count_taxa_wintering
          ,         '9999'                                                                      AS prospecting_hours_all_period
          ,         '7777'                                                                      AS prospecting_hours_breeding
          ,         '2222'                                                                      AS prospecting_hours_wintering
            FROM
                atlas.mv_data_for_atlas;

        COMMIT;
    END
$$
;

