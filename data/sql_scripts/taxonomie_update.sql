/*
Main structured data used to generate atlas data
-------------------------------------------------
Observation and forms data
*/

DO
$$
    BEGIN


        /* INFO: Ajout des différents attributs de l'atlas */
        INSERT INTO
            taxonomie.bib_themes (id_theme, nom_theme, desc_theme, ordre, id_droit)
            VALUES
                (4, 'ODF Noms', 'Informations relatives à Oiseaux de France (commun)', 1, 3)
              , (5, 'ODF Monographie', 'Informations relatives à Oiseaux de France (monographie espèce)', 2, 3)
              , (6, 'ODF Traits', 'Informations relatives à Oiseaux de France (bdd traits)', 3, 3)
        ON CONFLICT DO NOTHING;
        /* INFO: !!! de supprimer et regénérer une partie des vues matérialisées d'ODF :
            DROP MATERIALIZED VIEW IF EXISTS atlas.mv_search_taxa;
            DROP MATERIALIZED VIEW IF EXISTS atlas.mv_area_knowledge_list_taxa;
        */
        INSERT INTO
            taxonomie.bib_attributs ( id_attribut
                                    , nom_attribut
                                    , label_attribut
                                    , liste_valeur_attribut
                                    , obligatoire
                                    , desc_attribut
                                    , type_attribut
                                    , type_widget
                                    , regne
                                    , group2_inpn
                                    , id_theme
                                    , ordre)
            VALUES
                ( 202
                , 'odf_common_name_fr'
                , 'Nom vernaculaire français'
                , '{}'
                , FALSE
                , 'Nom vernaculaire français à afficher dans ODF'
                , 'text'
                , 'text'
                , NULL
                , NULL
                , 4
                , 1)
              , ( 203
                , 'odf_common_name_en'
                , 'Nom vernaculaire anglais'
                , '{}'
                , FALSE
                , 'Nom vernaculaire anglais à afficher dans ODF'
                , 'text'
                , 'text'
                , NULL
                , NULL
                , 4
                , 2)
              , ( 201
                , 'odf_sci_name'
                , 'Nom scientifique'
                , '{}'
                , FALSE
                , 'Nom scientifique à afficher dans ODF'
                , 'text'
                , 'text'
                , NULL
                , NULL
                , 4
                , 3)
              , (204, 'description', 'Description', '{}', FALSE, 'Description', 'text', 'textarea', NULL, NULL, 5, 1)
              , ( 205
                , 'distribution'
                , 'Répartition et déplacements'
                , '{}'
                , FALSE
                , 'Répartition et déplacements'
                , 'text'
                , 'textarea'
                , NULL
                , NULL
                , 5
                , 2)
              , (206, 'habitat', 'Habitat', '{}', FALSE, 'Habitat', 'text', 'textarea', NULL, NULL, 5, 3)
              , (207, 'feeding', 'Alimentation', '{}', FALSE, 'Alimentation', 'text', 'textarea', NULL, NULL, 5, 4)
              , (208, 'breeding', 'Reproduction', '{}', FALSE, 'Reproduction', 'text', 'textarea', NULL, NULL, 5, 5)
              , (210, 'pop_size', 'Taille de population', '{}', FALSE, 'Taille de population', 'text', 'textarea', NULL, NULL, 5, 6)
        ON CONFLICT DO NOTHING;

        /* INFO: Ajout des types de médias spécifiques */
        ALTER TABLE taxonomie.bib_types_media
            ADD UNIQUE (nom_type_media);

        INSERT INTO
            taxonomie.bib_types_media(id_type, nom_type_media, desc_type_media)
            VALUES
                ((SELECT max(id_type) + 1 FROM taxonomie.bib_types_media), 'xeno-canto', 'Lien https://xeno-canto.org')
        ON CONFLICT (nom_type_media) DO NOTHING;

        INSERT INTO
            taxonomie.bib_types_media(id_type, nom_type_media, desc_type_media)
            VALUES
                ( (SELECT max(id_type) + 1 FROM taxonomie.bib_types_media)
                , 'euro-bird-portal'
                , 'Lien https://eurobirdportal.org')
        ON CONFLICT (nom_type_media) DO NOTHING;

        /* Mise à jour des correspondances espèces VisioNature / TaxRef*/
        UPDATE taxonomie.cor_c_vn_taxref
        SET
            taxref_id = cd_ref
            FROM
                taxonomie.taxref
            WHERE
                  cd_nom = taxref_id
              AND taxref.cd_nom != taxref.cd_ref;

        /* INFO: Ajout/mise à jour des espèces de l'atlas à bib_noms */
        INSERT INTO
            taxonomie.bib_noms (cd_nom, cd_ref, nom_francais, comments)
        SELECT
            taxref.cd_nom
          , taxref.cd_ref
          , item ->> 'french_name' AS french_name
          , 'généré pour ODF'
            FROM
                src_vn_json.species_json
                    JOIN taxonomie.cor_c_vn_taxref ON vn_id = species_json.id
                    JOIN taxonomie.taxref ON cor_c_vn_taxref.taxref_id = taxref.cd_nom
                    JOIN atlas.t_taxa ON taxref.cd_nom = t_taxa.cd_nom
            WHERE
                  site = (SELECT DISTINCT site FROM src_vn_json.species_json LIMIT 1)
              AND taxref.classe LIKE 'Aves'
        ON CONFLICT (cd_nom) DO NOTHING;

        /* INFO: Ajout des attributs de noms à utiliser pour l'Atlas (source VisioNature prioritaire) */
        CREATE OR REPLACE FUNCTION array_diff(array1 ANYARRAY, array2 ANYARRAY)
            RETURNS ANYARRAY
            LANGUAGE sql
            IMMUTABLE AS
        $array_diff$

        SELECT
            coalesce(array_agg(elem), '{}')
            FROM
                unnest(array1) elem
            WHERE
                elem <> ALL (array2)
        $array_diff$;


        WITH
            species AS (SELECT
                            taxref.cd_nom
                          , taxref.lb_nom                                     AS latin_name
                          , coalesce(item ->> 'french_name',
                                     split_part(taxref.nom_vern, ',', 1))     AS french_name
                          , CASE
                                WHEN length(split_part(taxref.nom_vern, ', ', 2)) > 0
                                    THEN split_part(taxref.nom_vern, ', ', 2)
                                ELSE '-' END                                  AS synonyms
--                           , array_diff(string_to_array(taxref.nom_vern, ', '), ARRAY [coalesce(item ->> 'french_name',
--                                                                                                split_part(taxref.nom_vern, ',', 1))]) AS synonyms
--                           , taxref.nom_vern
                          , coalesce(item ->> 'english_name',
                                     split_part(taxref.nom_vern_eng, ',', 1)) AS english_name
                            FROM
                                src_vn_json.species_json
                                    JOIN taxonomie.cor_c_vn_taxref
                                         ON vn_id = species_json.id
                                    JOIN taxonomie.taxref ON cor_c_vn_taxref.taxref_id = taxref.cd_nom
                            WHERE
                                    site = (
                                    SELECT DISTINCT
                                        site
                                        FROM
                                            src_vn_json.species_json
                                        LIMIT 1)
                                    --              AND cast(item ->> 'id_taxo_group' as int) = 1
                              AND   taxref.classe LIKE 'Aves'
            )
          , attributs AS (
            SELECT
                (SELECT
                     id_attribut
                     FROM
                         taxonomie.bib_attributs
                     WHERE
                         bib_attributs.nom_attribut LIKE 'odf_sci_name') AS id_attribut
              , coalesce(species.latin_name, '-')                        AS valeur_attribut
              , species.cd_nom
                FROM
                    species
            UNION
            SELECT
                (SELECT
                     id_attribut
                     FROM
                         taxonomie.bib_attributs
                     WHERE
                         bib_attributs.nom_attribut LIKE 'odf_common_name_fr') AS id_attribut
              , coalesce(species.french_name, '-')                             AS valeur_attribut
              , species.cd_nom
                FROM
                    species
            UNION
            SELECT
                (SELECT
                     id_attribut
                     FROM
                         taxonomie.bib_attributs
                     WHERE
                         bib_attributs.nom_attribut LIKE 'odf_common_name_en') AS id_attribut
              , coalesce(species.english_name, '-')                            AS valeur_attribut
              , species.cd_nom
                FROM
                    species
            UNION
            SELECT
                (SELECT
                     id_attribut
                     FROM
                         taxonomie.bib_attributs
                     WHERE
                         bib_attributs.nom_attribut LIKE 'common_synonyms') AS id_attribut
              , synonyms                                                    AS valeur_attribut
              , species.cd_nom
                FROM
                    species)
        INSERT
            INTO
                taxonomie.cor_taxon_attribut(id_attribut, valeur_attribut, cd_ref)
        SELECT *
            FROM
                attributs
            ORDER BY
                cd_nom, id_attribut
        ON CONFLICT (id_attribut, cd_ref) DO NOTHING;


        INSERT INTO
            taxonomie.bib_noms (cd_nom, cd_ref, nom_francais, comments)
        SELECT
            taxref.cd_nom
          , taxref.cd_ref
          , (array_agg(item ->> 'french_name'))[1] AS french_name
          , 'généré pour ODF'
            FROM
                src_vn_json.species_json
                    JOIN taxonomie.cor_c_vn_taxref ON vn_id = species_json.id
                    JOIN taxonomie.taxref ON cor_c_vn_taxref.taxref_id = taxref.cd_nom
                    JOIN atlas.t_taxa ON taxref.cd_nom = t_taxa.cd_nom
            WHERE
                taxref.classe LIKE 'Aves'
            GROUP BY
                taxref.cd_nom
              , taxref.cd_ref
        ON CONFLICT (cd_nom) DO NOTHING;

        /* INFO : ajout des liens xeno-canto aux médias des espèces */
        INSERT INTO
            taxonomie.t_medias (cd_ref, titre, url, chemin, auteur, desc_media, date_media, id_type, source, licence)
        SELECT
            t_taxa.cd_nom
          , 'lien xeno-canto.org "' || lb_nom || '"'
          , 'https://xeno-canto.org/species/' || replace(lb_nom, ' ', '-')
          , NULL
          , 'xeno-canto'
          , NULL
          , now()
          , bib_types_media.id_type
          , 'xeno-canto.org'
          , NULL
            FROM
                atlas.t_taxa
                    JOIN taxonomie.taxref ON t_taxa.cd_nom = taxref.cd_nom
              , taxonomie.bib_types_media
            WHERE
                  nom_type_media = 'xeno-canto'
              AND t_taxa.enabled
              AND t_taxa.available;

        /* INFO : ajout des liens xeno-canto aux médias des espèces */
        CREATE TABLE tmp.euro_bird_portal_codes
        (
            cd_nom INT REFERENCES taxonomie.taxref NOT NULL PRIMARY KEY,
            lb_nom VARCHAR                         NOT NULL,
            code   VARCHAR                         NOT NULL
        );
        SELECT * FROM tmp.euro_bird_portal_codes;
        INSERT INTO
            taxonomie.t_medias (cd_ref, titre, url, chemin, auteur, desc_media, date_media, id_type, source, licence)
        SELECT
            t_taxa.cd_nom
          , 'lien https://eurobirdportal.org "' || euro_bird_portal_codes.lb_nom || '"'
          , 'https://eurobirdportal.org/ebp/en/#home/' || euro_bird_portal_codes.code || '/r52weeks'
          , NULL
          , 'EuroBirdPortal'
          , NULL
          , now()
          , bib_types_media.id_type
          , 'EuroBirdPortal'
          , NULL
            FROM
                atlas.t_taxa
--                     JOIN taxonomie.taxref ON t_taxa.cd_nom = taxref.cd_nom
                    JOIN tmp.euro_bird_portal_codes ON t_taxa.cd_nom = euro_bird_portal_codes.cd_nom
              , taxonomie.bib_types_media
            WHERE
                  nom_type_media = 'euro-bird-portal'
              AND t_taxa.enabled
              AND t_taxa.available;

        INSERT INTO
            taxonomie.t_medias (cd_ref, titre, url, chemin, auteur, desc_media, date_media, id_type, source, licence)
        SELECT
            t_taxa.cd_nom
          , 'lien xeno-canto.org "' || lb_nom || '"'
          , 'https://xeno-canto.org/species/' || replace(lb_nom, ' ', '-')
          , NULL
          , 'xeno-canto'
          , NULL
          , now()
          , bib_types_media.id_type
          , 'xeno-canto.org'
          , NULL
            FROM
                atlas.t_taxa
                    JOIN taxonomie.taxref ON t_taxa.cd_nom = taxref.cd_nom
              , taxonomie.bib_types_media
            WHERE
                  nom_type_media = 'xeno-canto'
              AND t_taxa.enabled
              AND t_taxa.available;

        COMMIT;
    END
$$
;

