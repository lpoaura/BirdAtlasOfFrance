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
 */
DO
$$
    BEGIN
        RAISE NOTICE 'INFO: (RE)CREATE MV atlas mv_area_dashboard';
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_area_dashboard;
        CREATE INDEX IF NOT EXISTS i_forms_json_id_form_universal ON import_vn.forms_json USING gin ((item -> 'id_form_universal'));
        -- some minimum date
        /* Materialized view to list all taxa in area */
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_area_dashboard;
        CREATE MATERIALIZED VIEW atlas.mv_area_dashboard AS
        WITH
            data_synth AS (
                SELECT
                    mv_data_for_atlas.id_area
                  , max(date_min)                                             AS last_date
                  , count(*)                                                  AS data_count
                  , count(DISTINCT cd_nom) FILTER (WHERE new_data_all_period) AS taxa_count_all_period
                  , count(DISTINCT cd_nom) FILTER (WHERE new_data_wintering)  AS taxa_count_wintering
                  , count(DISTINCT cd_nom) FILTER (WHERE new_data_breeding)   AS taxa_count_breeding
                    FROM
                        atlas.mv_data_for_atlas
                    WHERE
                        new_data_all_period
                    GROUP BY
                        mv_data_for_atlas.id_area
            )
          , form_synth AS (
            SELECT
                mv_forms_for_atlas.id_area
              , round(((sum(timelength_secs) FILTER (WHERE NOT is_wintering
                AND NOT is_breeding)) / 3600)::NUMERIC, 1)                                     AS prospecting_hours_other_period
              , round(((sum(timelength_secs) FILTER (WHERE is_wintering)) / 3600)::NUMERIC,
                      1)                                                                       AS prospecting_hours_wintering
              , round(((sum(timelength_secs) FILTER (WHERE is_breeding)) / 3600)::NUMERIC,
                      1)                                                                       AS prospecting_hours_breeding
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
                    JOIN form_synth ON data_synth.id_area = form_synth.id_area;
        COMMENT ON MATERIALIZED VIEW atlas.mv_area_dashboard IS 'Statistiques générales par zonages';
        CREATE UNIQUE INDEX i_area_dashboard_id_area ON atlas.mv_area_dashboard (id_area);
        COMMIT;
    END
$$
;

--
-- SELECT
--     *
-- FROM
--     atlas.mv_area_dashboard;

--
-- SELECT *
--     FROM
--         atlas.mv_area_dashboard
--     LIMIT 10
-- ;
--
-- SELECT
--     id
--   , site
--   , jsonb_pretty(item)
--     FROM
--         import_vn.forms_json
--     LIMIT 10
-- ;
--
-- CREATE TABLE public.tstest AS (
--     WITH
--         ts AS (
--             SELECT
--                 site
--               , item ->> 'date_start'     AS date_start
--               , item ->> 'time_start'     AS time_start
--               , item ->> 'date_stop'      AS date_stop
--               , item ->> 'time_stop'      AS time_stop
--               , round(((extract(EPOCH FROM
--                                 age((cast(item ->> 'date_stop' AS DATE) + cast(item ->> 'time_stop' AS TIME)),
--                                     (cast(item ->> 'date_start' AS DATE) + cast(item ->> 'time_start' AS TIME))))) /
--                        3600)::numeric, 2) AS delta
--               , jsonb_pretty(item)
--                 FROM
--                     import_vn.forms_json
--                 WHERE
--
--                     cast(item ->> 'date_start' AS DATE) > '2019-01-31'
-- --           and ((cast(item ->> 'date_stop' AS DATE) + cast(item ->> 'time_stop' AS TIME)) -
-- --                  (cast(item ->> 'date_start' AS DATE) + cast(item ->> 'time_start' AS TIME))) > '01:00:00'::time
--
--                 ORDER BY
--                     (extract(EPOCH FROM age((cast(item ->> 'date_stop' AS DATE) + cast(item ->> 'time_stop' AS TIME)),
--                                             (cast(item ->> 'date_start' AS DATE) + cast(item ->> 'time_start' AS TIME))))) DESC)
--
--     SELECT
--         count(*) FILTER ( WHERE ts.delta > 24)                    AS "plus de 24h"
--       , count(*) FILTER ( WHERE ts.delta > 12 AND ts.delta <= 24) AS "entre 12 et 24h"
--       , count(*) FILTER ( WHERE ts.delta > 1 AND ts.delta <= 12 ) AS "entre 1 et 12h"
--       , count(*) FILTER (WHERE ts.delta < 1)                      AS "moins de 1h"
--         FROM
--             ts
-- ;
--
--
select id_area from ref_geo.l_areas where area_code like '07019';

SELECT atlas.mv_area_dashboard.last_date AS atlas_mv_area_dashboard_last_date, atlas.mv_area_dashboard.data_count AS atlas_mv_area_dashboard_data_count, atlas.mv_area_dashboard.taxa_count_all_period AS atlas_mv_area_dashboard_taxa_count_all_period, atlas.mv_area_dashboard.taxa_count_wintering AS atlas_mv_area_dashboard_taxa_count_wintering, atlas.mv_area_dashboard.taxa_count_breeding AS atlas_mv_area_dashboard_taxa_count_breeding, atlas.mv_area_dashboard.prospecting_hours_other_period AS atlas_mv_area_dashboard_prospecting_hours_other_period, atlas.mv_area_dashboard.prospecting_hours_wintering AS atlas_mv_area_dashboard_prospecting_hours_wintering, atlas.mv_area_dashboard.prospecting_hours_breeding AS atlas_mv_area_dashboard_prospecting_hours_breeding
FROM atlas.mv_area_dashboard
WHERE atlas.mv_area_dashboard.id_area = 5271
 LIMIT 1

select * from atlas.mv_area_dashboard join ref_geo.l_areas on l_areas.id_area = mv_area_dashboard.id_area limit 10;

SELECT
    atlas.mv_area_dashboard.last_date                      AS atlas_mv_area_dashboard_last_date
  , atlas.mv_area_dashboard.data_count                     AS atlas_mv_area_dashboard_data_count
  , atlas.mv_area_dashboard.taxa_count_all_period          AS atlas_mv_area_dashboard_taxa_count_all_period
  , atlas.mv_area_dashboard.taxa_count_wintering           AS atlas_mv_area_dashboard_taxa_count_wintering
  , atlas.mv_area_dashboard.taxa_count_breeding            AS atlas_mv_area_dashboard_taxa_count_breeding
  , atlas.mv_area_dashboard.prospecting_hours_other_period AS atlas_mv_area_dashboard_prospecting_hours_other_period
  , atlas.mv_area_dashboard.prospecting_hours_wintering    AS atlas_mv_area_dashboard_prospecting_hours_wintering
  , atlas.mv_area_dashboard.prospecting_hours_breeding     AS atlas_mv_area_dashboard_prospecting_hours_breeding
    FROM
        atlas.mv_area_dashboard
    WHERE
        atlas.mv_area_dashboard.id_area = 661701
    LIMIT 1