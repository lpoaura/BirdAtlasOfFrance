/*
TITLE
-----
Description
*/

DO
$$
    BEGIN
        /* Vue matérialisée finale */
        RAISE NOTICE 'INFO: (RE)CREATE MV atlas mv_data_for_atlas';
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_data_for_atlas;
        -- some minimum date
        /* Materialized view to list all taxa in area */
        CREATE MATERIALIZED VIEW atlas.mv_data_for_atlas AS
        WITH
            areas AS (
                SELECT
                    /* Zonages utilisés : Mailles */
                    l_areas.id_area
                    FROM
                        ref_geo.l_areas
                    WHERE
                          enable IS TRUE
                      AND id_type = (
                        SELECT
                            id_type
                            FROM
                                ref_geo.bib_areas_types
                            WHERE
                                type_code = 'M10'
                            LIMIT 1))
            --           , data AS (
            /* Filtrage des données et association au zonage */
        SELECT
            cor_area_synthese.id_area
          , synthese.id_synthese
          , synthese.cd_nom
          , synthese.date_min::DATE
          , synthese.date_min > '2019-01-31'::DATE  AS new_data_all_period
          , synthese.date_min <= '2019-01-31'::DATE AS old_data_all_period
          , (tcse.bird_breed_code IS NULL
            AND extract(MONTH FROM synthese.date_min) IN (12, 1)
            AND synthese.date_min <= '2019-01-31')  AS old_data_wintering
          , (tcse.bird_breed_code IS NULL
            AND extract(MONTH FROM synthese.date_min) IN (12, 1)
            AND synthese.date_min > '2019-11-30')   AS new_data_wintering
          , (tcse.bird_breed_code BETWEEN 2 AND 50
            AND synthese.date_min <= '2019-01-01')  AS old_data_breeding
          , (tcse.bird_breed_code BETWEEN 2 AND 50
            AND synthese.date_min > '2019-01-01')   AS new_data_breeding
          , tcse.bird_breed_code
            FROM
                gn_synthese.cor_area_synthese
                    JOIN areas ON areas.id_area = cor_area_synthese.id_area
                    JOIN gn_synthese.synthese ON cor_area_synthese.id_synthese = synthese.id_synthese
                    JOIN src_lpodatas.t_c_synthese_extended tcse ON synthese.id_synthese = tcse.id_synthese
                    JOIN taxonomie.taxref ON synthese.cd_nom = taxref.cd_nom
            WHERE
                  taxref.group2_inpn LIKE 'Oiseaux'
              AND taxref.cd_nom NOT IN (
                SELECT
                    cd_nom
                    FROM
                        atlas.t_excluded_taxa);
        CREATE UNIQUE INDEX i_unique_data_for_atlas_id_synthese ON atlas.mv_data_for_atlas (id_synthese);
        CREATE INDEX i_data_for_atlas_cdnom ON atlas.mv_data_for_atlas (cd_nom);
        CREATE INDEX i_data_for_atlas_idarea ON atlas.mv_data_for_atlas (idarea);
        CREATE INDEX i_data_for_atlas_idarea ON atlas.mv_data_for_atlas (bird_breed_code);

        COMMIT;
    END
$$
;

