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
        (
        WITH
            selected_forms AS (
                SELECT DISTINCT
                    name_source AS site
                  , id_form     AS id
                    FROM
                        src_lpodatas.t_c_synthese_extended se
                            JOIN gn_synthese.synthese ON se.id_synthese = synthese.id_synthese
                            JOIN atlas.mv_data_for_atlas ON se.id_synthese = mv_data_for_atlas.id_synthese
                            JOIN gn_synthese.t_sources ON synthese.id_source = t_sources.id_source
                    WHERE
                        new_data_all_period)
          , forms AS (
            SELECT
                (cast(item ->> 'date_start' AS DATE) + cast(item ->> 'time_start' AS TIME))               AS ts_start
              , (cast(item ->> 'date_stop' AS DATE) + cast(item ->> 'time_stop' AS TIME))                 AS ts_stop
              , extract(EPOCH FROM
                        age((cast(item ->> 'date_stop' AS DATE) + cast(item ->> 'time_stop' AS TIME)),
                            (cast(item ->> 'date_start' AS DATE) + cast(item ->> 'time_start' AS TIME)))) AS delta_secs
              , extract(MONTH FROM cast(item ->> 'date_start' AS DATE)) IN (1, 12)                        AS wintering
              , extract(MONTH FROM cast(item ->> 'date_start' AS DATE)) BETWEEN 4 AND 7                   AS breeding
                FROM
                    import_vn.forms_json
                  , selected_forms
                WHERE
                      forms_json.item -> 'id_form_universal' ? selected_forms.id
                  AND forms_json.site = selected_forms.site
                  AND round(((extract(EPOCH FROM
                                      age((cast(item ->> 'date_stop' AS DATE) + cast(item ->> 'time_stop' AS TIME)),
                                          (cast(item ->> 'date_start' AS DATE) + cast(item ->> 'time_start' AS TIME))))) /
                             3600)::NUMERIC, 2) < 1
        )
        SELECT
            id_area
          , max(date_min)                                             AS last_date
          , count(*)                                                  AS data_count
          , count(DISTINCT cd_nom) FILTER (WHERE new_data_all_period) AS taxa_count_all_period
          , count(DISTINCT cd_nom) FILTER (WHERE new_data_wintering)  AS taxa_count_wintering
          , count(DISTINCT cd_nom) FILTER (WHERE new_data_breeding)   AS taxa_count_breeding
          , sum(delta_secs)                                           AS prospecting_hours_all_period
          , sum(delta_secs) FILTER (WHERE wintering)                  AS prospecting_hours_wintering
          , sum(delta_secs) FILTER (WHERE breeding)                   AS prospecting_hours_breeding
            FROM
                atlas.mv_data_for_atlas
              , forms
            WHERE
                new_data_all_period
            GROUP BY
                id_area);
        COMMENT ON MATERIALIZED VIEW atlas.mv_area_dashboard IS 'Statistiques générales par zonages';
        CREATE UNIQUE INDEX i_area_dashboard_id_area ON atlas.mv_area_dashboard (id_area);
        COMMIT;
    END
$$
;

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
--                        3600)::NUMERIC, 2) AS delta
--               , jsonb_pretty(item)
--                 FROM
--                     import_vn.forms_json
--                 WHERE
--
--                     cast(item ->> 'date_start' AS DATE) > '2019-01-31'
-- --           and ((cast(item ->> 'date_stop' AS DATE) + cast(item ->> 'time_stop' AS TIME)) -
-- --                  (cast(item ->> 'date_start' AS DATE) + cast(item ->> 'time_start' AS TIME))) > '01:00:00'::TIME
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
