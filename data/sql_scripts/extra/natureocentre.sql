-- odf_imports.natureocentre_data definition

-- Drop table

-- DROP TABLE odf_imports.natureocentre_data;

CREATE TABLE odf_imports.natureocentre_data
(
    entity_source_pk_value             INT4                                                                                  NOT NULL,
    uuid                               UUID                                                                                  NULL,
    cd_nom                             INT4                                                                                  NOT NULL,
    altitude_min                       INT4                                                                                  NULL,
    date_min                           DATE                                                                                  NOT NULL,
    bird_breed_code                    INT4                                                                                  NULL,
    "Migration active"                 VARCHAR                                                                               NOT NULL,
    cd_nomenclature_observation_status VARCHAR                                                                               NOT NULL,
    geom                               VARCHAR                                                                               NULL,
    cd_sig                             VARCHAR                                                                               NULL,
    commentaire                        TEXT                                                                                  NULL,
    date_maj                           DATE                                                                                  NOT NULL,
    precision_geometry                 INT4                                                                                  NULL,
    generated_geom                     public.GEOMETRY(point, 4326) GENERATED ALWAYS AS (st_geomfromtext(geom::TEXT)) STORED NULL,
    CONSTRAINT natureocentre_data_cd_nom_fkey FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom)
);
CREATE UNIQUE INDEX natureocentre_data_entity_source_pk_value_idx ON odf_imports.natureocentre_data USING btree(entity_source_pk_value);
CREATE INDEX natureocentre_data_entity_source_pk_value_idx1 ON odf_imports.natureocentre_data USING btree(((entity_source_pk_value)::TEXT));
CREATE INDEX natureocentre_data_generated_geom_idx ON odf_imports.natureocentre_data USING gist(generated_geom);


CREATE TABLE odf_imports.natureocentre_data_delete
(
    entity_source_pk_value INT4 NOT NULL,
    uuid                   UUID NULL,
    date_sup               DATE NOT NULL
);
CREATE UNIQUE INDEX natureocentre_data_delete_entity_source_pk_value_idx ON odf_imports.natureocentre_data_delete USING btree(entity_source_pk_value);
CREATE INDEX natureocentre_data_delete_entity_source_pk_value_idx1 ON odf_imports.natureocentre_data_delete USING btree(((entity_source_pk_value)::TEXT));


CREATE OR REPLACE FUNCTION odf_imports.refreash_natureocentre()
    RETURNS VOID
    LANGUAGE plpgsql
AS
$function$
DECLARE
    the_last_update                    DATE ;
    the_last_delete                    DATE;
    the_insert_synthese_count          INT;
    the_insert_synthese_extended_count INT;
    the_delete_count                   INT;
BEGIN
    RAISE DEBUG '~~~ Start NOC Update ~~~';
    /* Créer la variable the_last_update correspondant à la dernière maj */
    SELECT max(date_maj) INTO the_last_update FROM odf_imports.natureocentre_data;
    RAISE DEBUG '-- Last update is %', the_last_update;
    /* Réinitialisation/purge des données NatureOCentre */
    RAISE DEBUG '-- Truncate odf_imports.natureocentre_data';
    TRUNCATE odf_imports.natureocentre_data;
    /* Copie des données téléchargées dans la table data */
    RAISE DEBUG '-- Copie des données téléchargées dans la table data';
    COPY odf_imports.natureocentre_data(entity_source_pk_value, uuid, cd_nom, altitude_min, date_min, bird_breed_code,
                                        "Migration active", cd_nomenclature_observation_status, geom, cd_sig,
                                        commentaire,
                                        date_maj, precision_geometry)
--         FROM '/home/gestionnaire/sql_scripts/do_not_delete/natureOcentre/odf.csv' HEADER CSV DELIMITER E'\t';
        FROM PROGRAM 'curl https://natureocentre.org/odf/odf.csv' WITH HEADER CSV DELIMITER E'\t';
    /* Insertion des la synthese et extended_synthese */
    RAISE DEBUG '-- Insertion des données NOC dans la synthese et extended_synthese';
    WITH irows AS (
        INSERT INTO gn_synthese.synthese(unique_id_sinp, unique_id_sinp_grp, id_source, id_module,
                                         entity_source_pk_value,
                                         id_dataset, grp_method, id_nomenclature_diffusion_level,
                                         id_nomenclature_sensitivity,
                                         id_nomenclature_observation_status, id_nomenclature_valid_status,
                                         reference_biblio, count_min, count_max, cd_nom, cd_hab, nom_cite,
                                         sample_number_proof,
                                         digital_proof, non_digital_proof, altitude_min, altitude_max, depth_min,
                                         depth_max,
                                         place_name, the_geom_4326, the_geom_point, the_geom_local, precision,
                                         id_area_attachment, date_min, date_max, validator, validation_comment,
                                         observers,
                                         determiner, id_digitiser, comment_context, comment_description,
                                         additional_data,
                                         meta_validation_date, last_action)
            SELECT DISTINCT noc.uuid                                                   AS unique_id_sinp,
                            NULL::UUID                                                 AS unique_id_sinp_grp,
                            id_source,
                            NULL::INT                                                  AS id_module,
                            string_agg(noc.entity_source_pk_value::TEXT, '|')          AS entity_source_pk_value,
                            id_dataset                                                 AS id_dataset,
                            NULL::INT                                                  AS grp_method,
                            ref_nomenclatures.get_id_nomenclature('NIV_PRECIS', '5')   AS id_nomenclature_diffusion_level,
                            ref_nomenclatures.get_id_nomenclature('SENSIBILITE', '0')  AS id_nomenclature_sensitivity,
                            nom_obs_status.id_nomenclature                             AS id_nomenclature_observation_status,
                            ref_nomenclatures.get_id_nomenclature('STATUT_VALID', '2') AS id_nomenclature_observation_status,
                            NULL                                                          reference_biblio,
                            1                                                             count_min,
                            NULL::INT                                                     count_max,
                            noc.cd_nom                                                 AS cd_nom,
                            NULL::INT                                                     cd_hab,
                            taxref.lb_nom                                              AS nom_cite,
                            NULL                                                          sample_number_proof,
                            NULL                                                          digital_proof,
                            NULL                                                          non_digital_proof,
                            altitude_min                                               AS altitude_min,
                            NULL::INT                                                  AS altitude_max,
                            NULL::INT                                                  AS depth_min,
                            NULL::INT                                                  AS depth_max,
                            NULL                                                       AS place_name,
                            generated_geom                                             AS the_geom_4326,
                            st_centroid(generated_geom)                                AS the_geom_point,
                            generated_geom                                             AS the_geom_local,
                            NULL::INT                                                  AS precision,
                            NULL::INT                                                  AS id_area_attachment,
                            date_min,
                            date_min                                                   AS date_max,
                            NULL::TEXT                                                 AS validator,
                            NULL::TEXT                                                 AS validation_comment,
                            NULL::TEXT                                                 AS observers,
                            NULL::TEXT                                                 AS determiner,
                            NULL::INT                                                  AS id_digitiser,
                            NULL::TEXT                                                 AS comment_context,
                            string_agg(commentaire, '|')                               AS comment_description,
                            NULL::JSONB                                                AS additional_data,
                            NULL::TIMESTAMP                                            AS meta_validation_date,
                            'I'                                                        AS last_action
            FROM odf_imports.natureocentre_data noc
                     LEFT JOIN ref_nomenclatures.t_nomenclatures nom_obs_status
                               ON nom_obs_status.cd_nomenclature = cd_nomenclature_observation_status AND
                                  nom_obs_status.id_type = ref_nomenclatures.get_id_nomenclature_type('STATUT_OBS')
                     JOIN taxonomie.taxref ON noc.cd_nom = taxref.cd_nom,
                 gn_synthese.t_sources,
                 gn_meta.t_datasets
            WHERE name_source = 'Nature O Centre'
              AND dataset_shortname LIKE 'natureocentre'
              AND date_maj::DATE >= the_last_update::DATE
            GROUP BY noc.uuid, id_source, id_dataset, nom_obs_status.id_nomenclature, noc.cd_nom,
                     taxref.lb_nom, altitude_min, generated_geom,
                     st_centroid(generated_geom), generated_geom, date_min, date_min
            ON CONFLICT (unique_id_sinp) DO UPDATE
                SET entity_source_pk_value = excluded.entity_source_pk_value,
                    id_nomenclature_observation_status = excluded.id_nomenclature_observation_status,
                    cd_nom = excluded.cd_nom,
                    nom_cite = excluded.nom_cite,
                    altitude_min = excluded.altitude_min,
                    the_geom_4326 = excluded.the_geom_4326,
                    the_geom_local = excluded.the_geom_local,
                    the_geom_point = excluded.the_geom_point,
                    date_min = excluded.date_min,
                    date_max = excluded.date_max,
                    comment_description = excluded.comment_description,
                    last_action = 'U'
            RETURNING 1)
    SELECT count(*)
    INTO the_insert_synthese_count
    FROM irows;

    RAISE DEBUG '-- % rows inserted in synthese since %', the_insert_synthese_count::VARCHAR, the_last_update;

    RAISE DEBUG '-- Insertion des données NOC dans synthese_extended';

    WITH irows AS (INSERT INTO src_lpodatas.t_c_synthese_extended(id_synthese,
                                                                  bird_breed_code, bird_breed_status,
                                                                  date_year, is_valid)
        WITH t1 AS (SELECT id_synthese,
                           string_to_array(entity_source_pk_value, '|') AS entity_source_pk_values,
                           date_min
                    FROM gn_synthese.synthese
                    WHERE id_source = 34)
        SELECT id_synthese,
               max(bird_breed_code),
               ref_nomenclatures.get_nomenclature_label_by_cdnom_mnemonique('VN_ATLAS_CODE',
                                                                            max(bird_breed_code)::TEXT),
               extract(YEAR FROM t1.date_min) AS date_year,
               TRUE                           AS is_valid
        FROM odf_imports.natureocentre_data
                 JOIN t1 ON natureocentre_data.entity_source_pk_value::TEXT = ANY (entity_source_pk_values)
        WHERE date_maj::DATE >= the_last_update::DATE
        GROUP BY id_synthese, extract(YEAR FROM t1.date_min)
        ON CONFLICT (id_synthese) DO UPDATE SET bird_breed_code = excluded.bird_breed_code,
            bird_breed_status = excluded.bird_breed_status,
            date_year = excluded.date_year
        RETURNING 1)

    SELECT count(*)
    INTO the_insert_synthese_extended_count
    FROM irows;
    RAISE DEBUG '-- % rows inserted in synthese_extended', the_insert_synthese_extended_count::VARCHAR;

    /* Créer la variable the_last_delete correspondant à la dernière maj */
    SELECT max(date_sup)
    INTO the_last_delete
    FROM odf_imports.natureocentre_data_delete;

    RAISE DEBUG '-- Last delete is %', the_last_update;
    /* Réinitialisation/purge des données delete NatureOCentre */
    RAISE DEBUG '-- Truncate odf_imports.natureocentre_data';
    TRUNCATE odf_imports.natureocentre_data_delete;
    /* Copie des données téléchargées dans la table data_delete */
    RAISE DEBUG '-- Copie des données de suppression téléchargées dans la table delete';
    COPY odf_imports.natureocentre_data_delete(entity_source_pk_value, uuid, date_sup)
        FROM PROGRAM 'curl https://natureocentre.org/odf/supodf.csv' WITH HEADER CSV DELIMITER E'\t';
    /*Suppression des données dans la synthese et extended_synthese*/
    RAISE DEBUG '-- Suppression des données NOC dans la synthese et extended_synthese';
    WITH drows AS (DELETE
        FROM gn_synthese.synthese
            WHERE entity_source_pk_value IN (SELECT entity_source_pk_value::VARCHAR
                                             FROM odf_imports.natureocentre_data_delete
                                             WHERE date_sup::DATE >= the_last_delete::DATE)
                AND id_source = (SELECT id_source
                                 FROM gn_synthese.t_sources
                                 WHERE name_source = 'Nature O Centre') RETURNING 1)
    SELECT count(*)
    INTO the_delete_count
    FROM drows;
    RAISE DEBUG '-- % rows deleted in synthese since %', the_delete_count::VARCHAR, the_last_delete;

END
$function$
;

SET LOG_MIN_MESSAGES TO debug;

/* Test grandeur nature */
SELECT odf_imports.refreash_natureocentre();
