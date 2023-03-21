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
        SELECT row_number() OVER ()                     AS id,
               id_area_atlas_territory,
               id_area,
               cd_nom,
               phenologie                               AS phenology_period,
               array_agg(ARRAY [unite, (coalesce(value,0))::VARCHAR]) AS data
        FROM src_survey.vm_carto_reg_information
        GROUP BY id_area_atlas_territory,
                 id_area,
                 cd_nom,
                 phenologie
        ORDER BY 1, 2, 3, 4;

        COMMIT;
    END
$$
;

SELECT DISTINCT *
FROM atlas.mv_survey_map_data
WHERE cd_nom = 3089;
SELECT row_number() OVER ()                     AS id,
               id_area_atlas_territory,
               id_area,
               cd_nom,
               phenologie                               AS phenology_period,
               unite,
               value
        FROM src_survey.vm_carto_reg_information
        where cd_nom =3089
;