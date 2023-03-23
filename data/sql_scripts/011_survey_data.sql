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
        SELECT row_number() OVER ()                                                                            AS id,
               id_area_atlas_territory,
               id_area,
               cd_nom,
               phenologie                                                                                      AS phenology_period,
               array_agg(ARRAY [unite, coalesce(value::VARCHAR, val_min::VARCHAR || '-' || val_max::VARCHAR)]) AS data
        FROM src_survey.vm_carto_reg_information
        GROUP BY id_area_atlas_territory,
                 id_area,
                 cd_nom,
                 phenologie
        ORDER BY 1, 2, 3, 4;


        CREATE INDEX ON atlas.mv_survey_map_data (id_area_atlas_territory);
        CREATE INDEX ON atlas.mv_survey_map_data (cd_nom);
        CREATE INDEX ON atlas.mv_survey_map_data (phenology_period);


        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_survey_chart_data;
        CREATE MATERIALIZED VIEW atlas.mv_survey_chart_data AS
        (
        SELECT row_number() OVER ()          AS id,
               id_area_atlas_territory,
               extract(YEAR FROM date_debut) AS year,
               cd_nom,
               phenologie                    AS phenology_period,
               unite                         AS unit,
               jsonb_build_object('val', val, 'val_min', val_min, 'val_max',
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

SELECT count(*)
FROM pr_vigienature.t_observation;

SELECT DISTINCT cd_nom, id_area_atlas_territory, phenology_period
FROM atlas.mv_survey_chart_data;

SELECT *
FROM atlas.mv_survey_chart_data;


SELECT atlas.mv_survey_chart_data.id   AS atlas_mv_survey_chart_data_id,
       atlas.mv_survey_chart_data.year AS atlas_mv_survey_chart_data_year,
       atlas.mv_survey_chart_data.data AS atlas_mv_survey_chart_data_data
FROM atlas.mv_survey_chart_data
WHERE atlas.mv_survey_chart_data.cd_nom = 4064
  AND atlas.mv_survey_chart_data.id_area_atlas_territory = 87145
  AND atlas.mv_survey_chart_data.phenology_period = 'breeding'