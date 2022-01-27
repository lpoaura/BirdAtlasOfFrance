/*
EPOC Table
----------
Description
 */

DO
$$
    BEGIN
        /* Vue matérialisée finale */
--         DROP TABLE IF EXISTS atlas.t_epoc;



        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_realized_epoc;
        CREATE MATERIALIZED VIEW atlas.mv_realized_epoc AS
        (
        WITH
            t1 AS (
                SELECT DISTINCT
                    mv_forms_for_atlas.id_form_universal
                  , mv_data_for_atlas.project_code
                  , mv_forms_for_atlas.id_area
                  , mv_forms_for_atlas.timelength_secs
                  , mv_forms_for_atlas.timestamp_start::DATE AS date
                  , mv_forms_for_atlas.timestamp_start::TIME AS time
                  , mv_forms_for_atlas.geom
                    FROM
                        atlas.mv_data_for_atlas
                            JOIN atlas.mv_forms_for_atlas
                                 ON mv_data_for_atlas.id_form_universal = mv_forms_for_atlas.id_form_universal
                    WHERE
                          is_epoc
                      AND project_code IN ('EPOC', 'EPOC-ODF')
                      AND timelength_secs BETWEEN (60 * 5) AND (60 * 8)
            )
        SELECT
            row_number() OVER () AS id
          , t1.*
            FROM
                t1) WITH NO DATA;
        CREATE UNIQUE INDEX IF NOT EXISTS idx_realized_epoc_id_form_universal ON atlas.mv_realized_epoc (id_form_universal, project_code);
        CREATE INDEX gidx_realized_epoc ON atlas.mv_realized_epoc USING gist (geom);
        COMMIT;
    END
$$
;



GRANT SELECT ON ALL TABLES IN SCHEMA atlas to odfapp;