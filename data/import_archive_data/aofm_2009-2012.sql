/*
TITLE
-----
Description
*/

DO
$$
    BEGIN
        /* Vue matérialisée finale */
        INSERT INTO
            gn_synthese.t_sources (name_source, desc_source, meta_create_date, meta_update_date)
        SELECT DISTINCT
            source
          , source
          , now()
          , now()
            FROM
                tmp.aofm_2009_2012
        ON CONFLICT DO NOTHING;

        INSERT INTO
            gn_synthese.synthese( unique_id_sinp
                                , unique_id_sinp_grp
                                , id_source
                                , id_dataset
                                , id_nomenclature_diffusion_level
                                , id_nomenclature_sensitivity
                                , id_nomenclature_bio_status
                                , count_min
                                , count_max
                                , cd_nom
                                , nom_cite
                                , place_name
                                , the_geom_4326
                                , the_geom_point
                                , the_geom_local
                                , precision
                                , id_area_attachment
                                , date_min
                                , date_max
                                , comment_context
                                , meta_validation_date
                                , last_action)
        SELECT
            uuid_generate_v4()
          , NULL
          , id_source
          , id_dataset
          , ref_nomenclatures.get_id_nomenclature('NIV_PRECIS', '2')
          , ref_nomenclatures.get_id_nomenclature('SENSIBILITE', '2')
          , CASE
                WHEN aofm_2009_2012.source LIKE '%nicheur%'
                    THEN ref_nomenclatures.get_id_nomenclature('STATUT_BIO', '3')
                ELSE ref_nomenclatures.get_id_nomenclature('STATUT_BIO', '1') END
          , 1
          , 1
          , cd_ref
          , nom_sci
          , area_name
          , l_areas.geom
          , st_centroid(l_areas.geom)
          , l_areas.geom
          , NULL
          , l_areas.id_area
          , '2009-01-01'::DATE
          , '2012-12-31'::DATE
          , 'Données de synthèse de l''atlas des oiseaux de France 2009-2012'
          , NULL
          , 'I'
            FROM
                tmp.aofm_2009_2012
                    JOIN taxonomie.taxref
                         ON nom_sci = lb_nom
                    JOIN ref_geo.l_areas ON
                    replace(area_code, '10kmL93', '') = id_maille
                    JOIN gn_synthese.t_sources ON name_source = aofm_2009_2012.source;

        INSERT INTO
            src_lpodatas.t_c_synthese_extended ( id_synthese
                                               , id_sp_source
                                               , taxo_group
                                               , taxo_real
                                               , common_name
                                               , bird_breed_code
                                               , bird_breed_status)
        SELECT
            id_synthese
          , vn_id
          , 'Oiseaux'
          , TRUE
          , nom_commun
          , aofm_2009_2012.indice_nidif
          , upper(left(aofm_2009_2012.statut_nidif, 1)) ||
            substr(aofm_2009_2012.statut_nidif, 2, length(aofm_2009_2012.statut_nidif))
            FROM
                tmp.aofm_2009_2012
                    JOIN ref_geo.l_areas ON id_maille = replace(l_areas.area_code, '10kmL93', '')
                    JOIN taxonomie.cor_c_vn_taxref ON vn_id = id_espece
                    JOIN gn_synthese.synthese
                         ON (synthese.id_area_attachment, synthese.cd_nom, synthese.id_dataset) =
                            (l_areas.id_area, cor_c_vn_taxref.taxref_id, aofm_2009_2012.id_dataset)
        where aofm_2009_2012.id_dataset = 5
        ON CONFLICT (id_synthese) DO NOTHING;
        COMMIT;
    END
$$
;

SELECT
    count(*)
    FROM
        (SELECT
             id_synthese
           , vn_id
           , 'Oiseaux'
           , TRUE
           , nom_commun
           , aofm_2009_2012.indice_nidif
           , upper(left(aofm_2009_2012.statut_nidif, 1)) ||
             substr(aofm_2009_2012.statut_nidif, 2, length(aofm_2009_2012.statut_nidif))
             FROM
                 tmp.aofm_2009_2012
                     JOIN ref_geo.l_areas ON id_maille = replace(l_areas.area_code, '10kmL93', '')
                     JOIN taxonomie.cor_c_vn_taxref ON vn_id = id_espece
                     JOIN gn_synthese.synthese
                          ON (synthese.id_area_attachment, synthese.cd_nom, synthese.id_dataset) =
                             (l_areas.id_area, cor_c_vn_taxref.taxref_id,
                              aofm_2009_2012.id_dataset)
             WHERE
                 aofm_2009_2012.id_dataset = 5) t
;

SELECT DISTINCT
    source
  , id_dataset
    FROM
        tmp.aofm_2009_2012
;

SELECT *
    FROM
        gn_meta.t_datasets
;

UPDATE tmp.aofm_2009_2012
SET
    id_espece = vn_id
    FROM
        (SELECT *
             FROM
                 taxonomie.cor_c_vn_taxref
                     JOIN taxonomie.taxref ON taxref_id = taxref.cd_nom) taxa
    WHERE
          nom_sci = lb_nom
      AND id_dataset = 5
;

select count(*) from tmp.aofm_2009_2012 group by id_dataset;