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
                aofm_2009_2012
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
                aofm_2009_2012
                    JOIN taxonomie.taxref
                         ON nom_sci = lb_nom
                    JOIN ref_geo.l_areas ON
                    replace(area_code, '10kmL93', '') = id_maille
                    JOIN gn_synthese.t_sources ON name_source = aofm_2009_2012.source;


        COMMIT;
    END
$$
;

