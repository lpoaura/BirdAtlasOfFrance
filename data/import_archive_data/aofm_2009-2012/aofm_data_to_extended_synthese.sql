/*
INSERT AOFM DATA INTO SYNTHESE EXTENDED
-----
???
 */
DO $$
BEGIN
    INSERT INTO src_lpodatas.t_c_synthese_extended (id_synthese, id_sp_source, taxo_group, taxo_real, common_name, bird_breed_code, bird_breed_status)
    SELECT
        id_synthese,
        vn_id,
        'Oiseaux',
        TRUE,
        nom_commun,
        aofm_2009_2012.indice_nidif,
        upper(
        LEFT (aofm_2009_2012.statut_nidif, 1)) || substr(aofm_2009_2012.statut_nidif, 2, length(aofm_2009_2012.statut_nidif))
    FROM
        tmp.aofm_2009_2012
        JOIN ref_geo.l_areas ON id_maille = replace(l_areas.area_code, '10kmL93', '')
        JOIN taxonomie.cor_c_vn_taxref ON vn_id = id_espece
        JOIN gn_synthese.synthese ON (synthese.id_area_attachment,
            synthese.cd_nom,
            synthese.id_dataset) = (l_areas.id_area,
            cor_c_vn_taxref.taxref_id,
            aofm_2009_2012.id_dataset)
    ON CONFLICT (id_synthese)
        DO NOTHING;
    COMMIT;
END
$$;

