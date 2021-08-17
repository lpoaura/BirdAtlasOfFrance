/*
AREA DASHBOARD DATA
-------------------

 - Dernière actualisation
 - Complétude de prospection de la maille (%)
 - Nb de données
 - Nb d'espèces nicheuses / Nb d'espèces hiver / Nb d'espèces toutes saisons
 - Nb de données par décade (répartition temporelle des données)
 - Durée de prospection (en heures) :
 - Pour la période de repro
 - Pour la période d'hivernage
 - Hors repro et hivernage

 */
DO
$$
    BEGIN
        RAISE NOTICE 'INFO: (RE)CREATE MV atlas mv_area_dashboard';
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_area_dashboard;
        CREATE INDEX IF NOT EXISTS i_forms_json_id_form_universal ON src_vn_json.forms_json USING gin ((item -> 'id_form_universal'));
        -- some minimum date
        /* Materialized view to list all taxa in area */
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_area_dashboard;
        CREATE MATERIALIZED VIEW atlas.mv_area_dashboard AS
        WITH
            data_synth AS (
                SELECT
                    mv_data_for_atlas.id_area
                  , max(date_min)                                                              AS last_date
                  , count(*)                                                                   AS data_count
                  , count(DISTINCT mv_taxa_groups.cd_group) FILTER (WHERE new_data_all_period) AS taxa_count_all_period
                  , count(DISTINCT mv_taxa_groups.cd_group) FILTER (WHERE new_data_wintering)  AS taxa_count_wintering
                  , count(DISTINCT mv_taxa_groups.cd_group) FILTER (WHERE new_data_breeding)   AS taxa_count_breeding
                    FROM
                        atlas.mv_data_for_atlas
                            JOIN atlas.mv_taxa_groups ON mv_data_for_atlas.cd_nom = mv_taxa_groups.cd_nom
                            JOIN atlas.t_taxa ON t_taxa.cd_nom = mv_taxa_groups.cd_group
                    WHERE
                        new_data_all_period
                    GROUP BY
                        mv_data_for_atlas.id_area
            )
          , form_synth AS (
            SELECT
                mv_forms_for_atlas.id_area
              , round(((sum(timelength_secs) FILTER (WHERE NOT is_wintering
                AND NOT is_breeding)) / 3600)::NUMERIC, 1) AS prospecting_hours_other_period
              , round(((sum(timelength_secs) FILTER (WHERE is_wintering)) / 3600)::NUMERIC,
                      1)                                   AS prospecting_hours_wintering
              , round(((sum(timelength_secs) FILTER (WHERE is_breeding)) / 3600)::NUMERIC,
                      1)                                   AS prospecting_hours_breeding
                FROM
                    atlas.mv_forms_for_atlas
                GROUP BY
                    mv_forms_for_atlas.id_area
        )
        SELECT
            data_synth.*
          , form_synth.prospecting_hours_other_period
          , form_synth.prospecting_hours_wintering
          , form_synth.prospecting_hours_breeding
            FROM
                data_synth
                    FULL JOIN form_synth ON data_synth.id_area = form_synth.id_area;
        COMMENT ON MATERIALIZED VIEW atlas.mv_area_dashboard IS 'Statistiques générales par zonages';
        CREATE UNIQUE INDEX i_area_dashboard_id_area ON atlas.mv_area_dashboard (id_area);
        COMMIT;
    END
$$
;
