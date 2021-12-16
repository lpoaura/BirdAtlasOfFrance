/*
TITLE
-----
Description
*/

DO
$$
    BEGIN
        /* Vue matérialisée finale */
--         INSERT INTO
--             gn_synthese.t_sources (name_source, desc_source, meta_create_date, meta_update_date)
--         SELECT DISTINCT
--             source
--           , source
--           , now()
--           , now()
--             FROM
--                 tmp.aofm_2009_2012
--         ON CONFLICT DO NOTHING;
        RAISE NOTICE 'set session replication role to replica';
        SET SESSION_REPLICATION_ROLE TO REPLICA;
        RAISE NOTICE 'SET CONSTRAINTS ALL DEFERRED';
        SET CONSTRAINTS ALL DEFERRED;
        RAISE NOTICE 'disable triggers';
        ALTER TABLE gn_synthese.synthese
            DISABLE TRIGGER tri_insert_calculate_sensitivity;
        ALTER TABLE gn_synthese.synthese
            DISABLE TRIGGER tri_insert_cor_area_synthese;
        ALTER TABLE gn_synthese.synthese
            DISABLE TRIGGER tri_meta_dates_change_synthese;
        ALTER TABLE gn_synthese.synthese
            DISABLE TRIGGER tri_update_calculate_sensitivity;
        ALTER TABLE gn_synthese.synthese
            DISABLE TRIGGER tri_update_cor_area_synthese;
        RAISE NOTICE 'insert into synthese';
        INSERT INTO
            gn_synthese.synthese( unique_id_sinp
                                , id_source
                                , id_dataset
                                , id_nomenclature_diffusion_level
                                , id_nomenclature_sensitivity
                                , id_nomenclature_bio_status
                                , id_nomenclature_valid_status
                                , id_nomenclature_observation_status
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
                                , last_action
                                , meta_create_date
                                , meta_update_date)
        SELECT
            uuid_generate_v4()
          , id_source
          , id_dataset
          , ref_nomenclatures.get_id_nomenclature('NIV_PRECIS', '2')
          , ref_nomenclatures.get_id_nomenclature('SENSIBILITE', '2')
          , CASE
                WHEN aofm_2009_2012.source LIKE '%nicheur%'
                    THEN ref_nomenclatures.get_id_nomenclature('STATUT_BIO', '3')
                ELSE ref_nomenclatures.get_id_nomenclature('STATUT_BIO', '1') END
          , ref_nomenclatures.get_id_nomenclature('STATUT_VALID', '2')
          , ref_nomenclatures.get_id_nomenclature('STATUT_OBS', 'Pr')
          , 1
          , 1
          , cd_ref
          , lb_nom
          , area_name
          , l_areas.geom
          , st_centroid(l_areas.geom)
          , l_areas.geom
          , NULL
          , l_areas.id_area
          , CASE
                WHEN statut_nidif IS NOT NULL THEN '2009-02-01'::DATE
                ELSE '2009-01-01'::DATE END
          , CASE
                WHEN statut_nidif IS NOT NULL THEN '2012-11-30'::DATE
                ELSE '2012-12-31'::DATE END
          , 'Données de synthèse de l''atlas des oiseaux de France 2009-2012'
          , NULL
          , 'I'
          , now()
          , now()
            FROM
                tmp.aofm_2009_2012
                    JOIN taxonomie.cor_c_vn_taxref ON vn_id = id_espece_visionature
                    JOIN taxonomie.taxref
                         ON taxref_id = cd_nom
                    JOIN ref_geo.l_areas ON
                    replace(area_code, '10kmL93', '') = code_maille;

        INSERT INTO gn_synthese.cor_area_synthese(id_area, id_synthese)
        SELECT
            id_area
          , id_synthese
            FROM
                gn_synthese.synthese
              , ref_geo.l_areas
            WHERE
                  l_areas.enable
              AND st_intersects(the_geom_local, geom)
              AND id_source IN (SELECT DISTINCT id_source FROM tmp.aofm_2009_2012)
        ON CONFLICT (id_area, id_synthese) DO NOTHING;
        RAISE NOTICE 'insert into cor_area_synthese';
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
                    JOIN ref_geo.l_areas ON code_maille = replace(l_areas.area_code, '10kmL93', '')
                    JOIN taxonomie.cor_c_vn_taxref ON vn_id = id_espece_visionature
                    LEFT JOIN gn_synthese.synthese
                              ON (synthese.id_area_attachment, synthese.cd_nom, synthese.id_dataset) =
                                 (l_areas.id_area, cor_c_vn_taxref.taxref_id, aofm_2009_2012.id_dataset)
--             WHERE
--                 aofm_2009_2012.id_dataset = 5
        ON CONFLICT (id_synthese) DO NOTHING;
        RAISE NOTICE 'restore triggers';
        ALTER TABLE gn_synthese.synthese
            ENABLE TRIGGER tri_insert_calculate_sensitivity;
        ALTER TABLE gn_synthese.synthese
            ENABLE TRIGGER tri_insert_cor_area_synthese;
        ALTER TABLE gn_synthese.synthese
            ENABLE TRIGGER tri_meta_dates_change_synthese;
        ALTER TABLE gn_synthese.synthese
            ENABLE TRIGGER tri_update_calculate_sensitivity;
        ALTER TABLE gn_synthese.synthese
            ENABLE TRIGGER tri_update_cor_area_synthese;
        RAISE NOTICE 'SET CONSTRAINTS ALL IMMEDIATE';
        SET CONSTRAINTS ALL IMMEDIATE;
        COMMIT;
    END
$$
;

SELECT
    t_sources.name_source
  , count(*)
    FROM
        gn_synthese.synthese
            JOIN src_lpodatas.t_c_synthese_extended ON synthese.id_synthese = t_c_synthese_extended.id_synthese
            JOIN atlas.mv_data_for_atlas ON id_data = synthese.id_synthese
            JOIN gn_synthese.t_sources ON synthese.id_source = t_sources.id_source
            JOIN gn_synthese.cor_area_synthese ON synthese.id_synthese = cor_area_synthese.id_synthese
    GROUP BY
        name_source
;
select current_user;

grant select on taxonomie.taxref to odfapp;