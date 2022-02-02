/*
INIT ATLAS DB
-------------
Require to be executed on installed GeoNature DB
 */
DO
$$
    BEGIN
        WITH
            t1 AS (SELECT DISTINCT
                       cd_nom
                     , dict_period_profiles.id        AS period_profile
                     , dict_breeding_code_profiles.id AS breeding_codes
                     , mv_grid_territories_matching.id_area_territory
                       FROM
                           atlas.mv_data_for_atlas
                               JOIN atlas.mv_grid_territories_matching
                                    ON mv_data_for_atlas.id_area = mv_grid_territories_matching.id_area_grid
                               JOIN ref_geo.l_areas ON id_area_territory = l_areas.id_area
                         , atlas.dict_period_profiles
                         , atlas.dict_breeding_code_profiles
                       WHERE
                             dict_period_profiles.code LIKE 'FRMET_%_DEFAULT'
                         AND dict_breeding_code_profiles.code LIKE 'DEFAULT'
                         AND (l_areas.area_code LIKE 'FRMET' AND
                              l_areas.id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY'))
            )
        INSERT
            INTO
                atlas.cor_specie_territory_profile (cd_nom, period_profile, breeding_codes, id_area)
        SELECT *
            FROM
                t1
        ON CONFLICT (cd_nom, period_profile, breeding_codes, id_area) DO NOTHING;

        


        COMMIT;
    END
$$
;
