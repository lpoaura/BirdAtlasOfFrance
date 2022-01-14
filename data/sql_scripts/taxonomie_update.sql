/*
Main structured data used to generate atlas data
-------------------------------------------------
Observation and forms data
*/

DO
$$
    BEGIN

            UPDATE taxonomie.cor_c_vn_taxref
            SET
                taxref_id = cd_ref
                FROM
                    taxonomie.taxref
                WHERE
                      cd_nom = taxref_id
                  AND taxref.cd_nom != taxref.cd_ref;
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
            WITH
                species AS (SELECT
                                taxref.cd_nom
                              , taxref.lb_nom                                     AS latin_name
                              , coalesce(item ->> 'french_name',
                                         split_part(taxref.nom_vern, ',', 1))     AS french_name
                              , coalesce(item ->> 'english_name',
                                         split_part(taxref.nom_vern_eng, ',', 1)) AS english_name
                                FROM
                                    src_vn_json.species_json
                                        JOIN taxonomie.cor_c_vn_taxref ON vn_id = species_json.id
                                        JOIN taxonomie.taxref ON cor_c_vn_taxref.taxref_id = taxref.cd_nom
                                WHERE
                                      site = (SELECT DISTINCT site FROM src_vn_json.species_json LIMIT 1)
                                      --              AND cast(item ->> 'id_taxo_group' as int) = 1
                                  AND taxref.classe LIKE 'Aves'
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
            COMMIT;
        END
$$
;

