/*
INIT ATLAS DB
-------------
Require to be executed on installed GeoNature DB
 */
DO
$$


    DECLARE
        geonature_status BOOLEAN;

    BEGIN
        RAISE NOTICE 'INFO: INIT atlas requirements on existing PostgreSQL DB';

        PERFORM
            1
            FROM
                gn_commons.t_modules
            LIMIT 1;

        DROP SCHEMA IF EXISTS atlas CASCADE;


/* Create dedicated db schema */
        CREATE SCHEMA IF NOT EXISTS atlas;


/* Create table to list excluded taxa */
        DROP TABLE IF EXISTS atlas.t_taxa CASCADE;

        CREATE TABLE IF NOT EXISTS atlas.t_taxa
        (
            cd_nom    INT REFERENCES taxonomie.taxref (cd_nom) PRIMARY KEY,
            cd_sp     INT REFERENCES taxonomie.taxref (cd_nom) NOT NULL,
            has_subsp BOOLEAN                                  NOT NULL DEFAULT FALSE,
            rank      VARCHAR                                  NOT NULL,
            enabled   BOOLEAN                                  NOT NULL DEFAULT TRUE,
            available BOOLEAN                                  NOT NULL DEFAULT TRUE
        );

        COMMENT ON TABLE atlas.t_taxa IS 'Included taxa for ODF atlas';
        COMMENT ON COLUMN atlas.t_taxa.cd_nom IS 'TaxRef official id (cd_nom)';
        COMMENT ON COLUMN atlas.t_taxa.cd_sp IS 'TaxRef official taxa id (cd_nom, specie level), useful for sub-species';
        COMMENT ON COLUMN atlas.t_taxa.has_subsp IS 'Taxonomy rank level (es or sses)';
        COMMENT ON COLUMN atlas.t_taxa.rank IS 'include (es or sses)';
        COMMENT ON COLUMN atlas.t_taxa.enabled IS 'Taxa enabled for atlas (False = hidden)';
        COMMENT ON COLUMN atlas.t_taxa.available IS 'Independently searchable taxon for atlas';

        CREATE UNIQUE INDEX i_unique_cd_nom_taxa ON atlas.t_taxa (cd_nom);

        CREATE INDEX i_unique_cd_sp_taxa ON atlas.t_taxa (cd_sp);


/* Populate t_taxa table */
        INSERT INTO atlas.t_taxa (cd_nom, cd_sp, rank, enabled, available)
        SELECT DISTINCT
            taxref.cd_nom
          , CASE
                WHEN id_rang LIKE 'SSES' THEN
                    cd_sup
                ELSE
                    cd_ref
                END                                                           AS cd_sp
            --  , FALSE                                                             AS has_subsp
          , taxref.id_rang
          , NOT taxref.cd_nom IN (2852, 2856, 2657, 836345, 3811, 2848, 3076) AS enabled
          , taxref.id_rang LIKE 'ES'
                OR (taxref.id_rang LIKE 'SSES'
                AND taxref.cd_nom IN (3745, 886211, 886212, 961306, 804727))  AS available
            FROM
                gn_synthese.synthese
                    JOIN taxonomie.taxref ON synthese.cd_nom = taxref.cd_nom
            WHERE
                  taxref.classe LIKE 'Aves'
              AND taxref.cd_nom = taxref.cd_ref
                  --       AND (
                  --                   (
                  --                       taxref.id_rang LIKE 'ES')
                  --                   OR (
                  --                           taxref.id_rang LIKE 'SSES'
                  --                           AND taxref.cd_nom IN (
                  --                                                 3745, 886211, 886212, 961306, 804727, -3420)))
        ON CONFLICT (cd_nom)
            DO NOTHING;


/* Set has_subsp value where taxa has sub-specie(s) */
        UPDATE
            atlas.t_taxa
        SET
            has_subsp = FALSE
            FROM
                (
                    SELECT
                        cd_sp
                        FROM
                            atlas.t_taxa
                        WHERE
                            cd_sp != cd_nom) AS t
            WHERE
                t.cd_sp = t_taxa.cd_nom;

        CREATE INDEX IF NOT EXISTS i_forms_geom_from_json ON src_vn_json.forms_json USING gist (st_setsrid(st_makepoint(
                                                                                                                   cast(item ->> 'lon' AS NUMERIC),
                                                                                                                   cast(item ->> 'lat' AS NUMERIC)),
                                                                                                           4326));

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
                , '[ODF] Nom vernaculaire français'
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
                , '[ODF] Nom vernaculaire anglais'
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
                , '[ODF] Nom scientifique'
                , '{}'
                , FALSE
                , 'Nom scientifique à afficher dans ODF'
                , 'text'
                , 'text'
                , NULL
                , NULL
                , 4
                , 3)
        ON CONFLICT
            DO NOTHING;

        WITH
            datas AS (
                SELECT
                    CASE
                        WHEN taxref.id_rang LIKE 'SSES' THEN
                            cd_sup
                        ELSE
                            taxref.cd_nom
                        END AS cd_group
                  , taxref.cd_nom
                    FROM
                        gn_synthese.synthese
                            JOIN taxonomie.taxref ON synthese.cd_nom = taxref.cd_nom
                    WHERE
                          taxref.classe LIKE 'Aves'
                      AND taxref.cd_nom = taxref.cd_ref
                      AND taxref.id_rang IN ('ES', 'SSES')
                UNION
                SELECT
                    taxref.cd_nom AS cd_group
                  , taxref.cd_nom
                    FROM
                        gn_synthese.synthese
                            JOIN taxonomie.taxref ON synthese.cd_nom = taxref.cd_nom
                    WHERE
                          taxref.classe LIKE 'Aves'
                      AND taxref.cd_nom = taxref.cd_ref
                      AND taxref.id_rang IN ('ES', 'SSES'))
        SELECT DISTINCT
            cd_group
          , cd_nom
            FROM
                datas;

        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_taxa_groups CASCADE;
        CREATE MATERIALIZED VIEW atlas.mv_taxa_groups AS
        (
        WITH
            datas AS (
                SELECT
                    CASE
                        WHEN t_taxa.rank LIKE 'SSES' THEN
                            cd_sup
                        ELSE
                            t_taxa.cd_nom
                        END AS cd_group
                  , t_taxa.cd_nom
                    FROM
                        gn_synthese.synthese
                            JOIN atlas.t_taxa ON synthese.cd_nom = t_taxa.cd_nom
                            JOIN taxonomie.taxref ON t_taxa.cd_nom = taxref.cd_nom
                    WHERE
                          t_taxa.cd_nom = taxref.cd_ref
                      AND t_taxa.rank IN (
                                          'ES', 'SSES')
                UNION
                SELECT
                    taxref.cd_nom AS cd_group
                  , t_taxa.cd_nom
                    FROM
                        gn_synthese.synthese
                            JOIN atlas.t_taxa
                                 ON synthese.cd_nom = t_taxa.cd_nom
                            JOIN taxonomie.taxref ON t_taxa.cd_nom = taxref.cd_nom
                    WHERE
                          t_taxa.cd_nom = taxref.cd_ref
                      AND t_taxa.rank IN (
                                          'ES', 'SSES'))
        SELECT DISTINCT
            cd_group
          , cd_nom
            FROM
                datas);

        COMMENT ON MATERIALIZED VIEW atlas.mv_taxa_groups IS 'Taxa groups used to aggregate subspecies datas';

        COMMENT ON COLUMN atlas.mv_taxa_groups.cd_group IS 'Group cd_nom';

        COMMENT ON COLUMN atlas.mv_taxa_groups.cd_nom IS 'Taxa cd_nom';

        CREATE UNIQUE INDEX id_unique_cor_taxa_group_cd_group_cd_nom ON atlas.mv_taxa_groups (cd_group, cd_nom);

        CREATE TYPE PHENOLOGY_PERIOD AS ENUM ('wintering','breeding','migration','all_period');

        CREATE TABLE atlas.dict_specie_profile
        (
            id          INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
            type_period PHENOLOGY_PERIOD NOT NULL,
            dow_start   INT              NOT NULL,
            doy_end     INT              NOT NULL,
            strict      BOOLEAN          NOT NULL
        );

        CREATE TABLE atlas.cor_specie_territory_profile
        (
            id      INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
            cd_nom  INT REFERENCES taxonomie.taxref (cd_nom),
            profile INT REFERENCES atlas.dict_specie_profile (id),
            id_area INT REFERENCES ref_geo.l_areas (id_area)
        );


        UPDATE taxonomie.cor_c_vn_taxref
        SET
            taxref_id = cd_ref
            FROM
                taxonomie.taxref
            WHERE
                  cd_nom = taxref_id
              AND taxref.cd_nom != taxref.cd_ref;

        INSERT INTO taxonomie.bib_noms (cd_nom, cd_ref, nom_francais, comments)
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
                  --              AND cast(item ->> 'id_taxo_group' as int) = 1
              AND taxref.classe LIKE 'Aves'
        ON CONFLICT (cd_nom) DO NOTHING;


        WITH
            species AS (SELECT
                            taxref.cd_nom
                          , taxref.lb_nom           AS latin_name
                          , item ->> 'french_name'  AS french_name
                          , item ->> 'english_name' AS english_name
                            FROM
                                src_vn_json.species_json
                                    JOIN taxonomie.cor_c_vn_taxref ON vn_id = species_json.id
                                    JOIN taxonomie.taxref ON cor_c_vn_taxref.taxref_id = taxref.cd_nom
                            WHERE
                                  site = 'ff'
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
              , species.latin_name                                       AS valeur_attribut
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
              , species.french_name                                            AS valeur_attribut
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
              , species.english_name                                           AS valeur_attribut
              , species.cd_nom
                FROM
                    species)
        INSERT
            INTO
                taxonomie.cor_taxon_attribut(id_attribut, valeur_attribut, cd_ref)
        SELECT *
            FROM
                attributs
            ORDER BY cd_nom, id_attribut
        ON CONFLICT (id_attribut, cd_ref) DO NOTHING;

        WITH
            species AS (SELECT
                            taxref.cd_nom
                          , taxref.lb_nom           AS latin_name
                          , item ->> 'french_name'  AS french_name
                          , item ->> 'english_name' AS english_name
                            FROM
                                src_vn_json.species_json
                                    JOIN taxonomie.cor_c_vn_taxref ON vn_id = species_json.id
                                    JOIN taxonomie.taxref ON cor_c_vn_taxref.taxref_id = taxref.cd_nom
                            WHERE
--                                   site = (SELECT DISTINCT site FROM src_vn_json.species_json LIMIT 1)
                                site = 'ff'
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
              , species.latin_name                                       AS valeur_attribut
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
              , species.french_name                                            AS valeur_attribut
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
              , species.english_name                                           AS valeur_attribut
              , species.cd_nom
                FROM
                    species)
        UPDATE
            taxonomie.cor_taxon_attribut
        SET
            valeur_attribut = attributs.valeur_attribut
            FROM
                attributs
            WHERE
                    cor_taxon_attribut.
                        cd_ref = attributs.cd_nom
              AND   cor_taxon_attribut.id_attribut = attributs.id_attribut;

        /* Commit changes */
        COMMIT;

    END
$$
;

