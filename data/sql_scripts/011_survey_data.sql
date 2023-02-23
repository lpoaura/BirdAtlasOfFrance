/*
SURVEY DATAS
-----

TODO COMMENT

* ...
 */

DO
$$
    BEGIN
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_survey_map_data;
        CREATE MATERIALIZED VIEW atlas.mv_survey_map_data AS
        SELECT row_number() OVER () AS id, id_area, cd_nom, array_agg(ARRAY [unite_graph, value::VARCHAR]) AS data
        FROM src_survey.vm_carto_reg_information
        GROUP BY id_area, cd_nom
        ORDER BY 1, 2;

        COMMIT;
    END
$$
;