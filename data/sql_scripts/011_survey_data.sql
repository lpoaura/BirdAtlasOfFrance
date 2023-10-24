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
        SELECT ROW_NUMBER() OVER ()                                                                                                                     AS id,
               id_area_atlas_territory,
               id_area,
               cd_nom,
               phenologie                                                                                                                               AS phenology_period,
               ARRAY_AGG(ARRAY [unite, COALESCE(value::VARCHAR, val_min::VARCHAR || '-' || val_max::VARCHAR), (EXTRACT(YEAR FROM last_date))::VARCHAR]) AS data
        FROM src_survey.vm_carto_reg_information
        GROUP BY id_area_atlas_territory,
                 id_area,
                 cd_nom,
                 phenologie
        ORDER BY 1, 2, 3, 4;

        SELECT * FROM atlas.mv_survey_map_data;


        CREATE INDEX ON atlas.mv_survey_map_data (id_area_atlas_territory);
        CREATE INDEX ON atlas.mv_survey_map_data (cd_nom);
        CREATE INDEX ON atlas.mv_survey_map_data (phenology_period);


        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_survey_chart_data;
        CREATE MATERIALIZED VIEW atlas.mv_survey_chart_data AS
        (
        SELECT ROW_NUMBER() OVER ()          AS id,
               id_area_atlas_territory,
               EXTRACT(YEAR FROM date_debut) AS year,
               cd_nom,
               phenologie                    AS phenology_period,
               unite                         AS unit,
               JSONB_BUILD_OBJECT('val', val, 'val_min', val_min, 'val_max',
                                  val_max)   AS data
        FROM src_survey.vm_graph_information
--         GROUP BY 2, 3, 4, 5, 6
            );

        CREATE INDEX ON atlas.mv_survey_chart_data (id_area_atlas_territory);
        CREATE INDEX ON atlas.mv_survey_chart_data (cd_nom);
        CREATE INDEX ON atlas.mv_survey_chart_data (phenology_period);

        COMMIT;
    END
$$
;


