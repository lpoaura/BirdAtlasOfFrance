/*
MIGRATION DATA
-------------
Population migration data from LPOFrance calculations
 */
DO
$$
    BEGIN
        TRUNCATE atlas.t_taxa_migration_decade_data;
        INSERT INTO atlas.t_taxa_migration_decade_data (cd_nom, id_area, processing, decade, count, pivotal_decade)
        SELECT cd_nom, id_area, traitement, decade, nb_donnees, decade_charniere
        FROM lpofrance_mte.pheno_migration_etape7_2_nb_donnees_esp_decade dec
                 LEFT JOIN lpofrance_mte.pheno_migration_etape7_quantiles_choix_traitement_esp_d qnt
                           ON dec.cd_nom = qnt.cd_nom,
             ref_geo.l_areas
        WHERE id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
          AND area_code LIKE 'FRMET';

        TRUNCATE atlas.t_taxa_migration_quartile_data;
        INSERT INTO atlas.t_taxa_migration_quartile_data(cd_nom, id_area, processing, period, q2_5, q5, q25, median,
                                                         q75, q95,
                                                         q97_5)
        SELECT cd_nom,
               id_area,
               traitement,
               'migration_prenuptial',
               q2_5_printemps_d,
               q5_printemps_d,
               q25_printemps_d,
               mediane_printemps_d,
               q75_printemps_d,
               q95_printemps_d,
               q97_5_printemps_d
        FROM lpofrance_mte.pheno_migration_etape7_quantiles_choix_traitement_esp_d,
             ref_geo.l_areas
        WHERE id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
          AND area_code LIKE 'FRMET';


        INSERT INTO atlas.t_taxa_migration_quartile_data(cd_nom, id_area, processing, period, q2_5, q5, q25, median,
                                                         q75, q95,
                                                         q97_5)
        SELECT cd_nom,
               id_area,
               traitement,
               'migration_postnuptial',
               q2_5_automne_d,
               q5_automne_d,
               q25_automne_d,
               mediane_automne_d,
               q75_automne_d,
               q95_automne_d,
               q97_5_automne_d
        FROM lpofrance_mte.pheno_migration_etape7_quantiles_choix_traitement_esp_d,
             ref_geo.l_areas
        WHERE id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
          AND area_code LIKE 'FRMET');

        COMMIT;
    END
$$
;