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

        INSERT INTO
            taxonomie.bib_themes (id_theme, nom_theme, desc_theme, ordre, id_droit)
            VALUES
                (4, 'ODF Noms', 'Informations relatives à Oiseaux de France (commun)', 1, 3)
              , (5, 'ODF Monographie', 'Informations relatives à Oiseaux de France (monographie espèce)', 2, 3)
              , (6, 'ODF Traits', 'Informations relatives à Oiseaux de France (bdd traits)', 3, 3)
        ON CONFLICT DO NOTHING;

        DROP MATERIALIZED VIEW atlas.mv_search_taxa;
        DROP MATERIALIZED VIEW atlas.mv_area_knowledge_list_taxa;

        SELECT * FROM taxonomie.bib_attributs;
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
              , (207, 'feeding', 'Alimentation', '{}', FALSE, 'Alimentation', 'text', 'textarea', NULL, NULL, 5, 3)
              , (207, 'breeding', 'Reproduction', '{}', FALSE, 'Reproduction', 'text', 'textarea', NULL, NULL, 5, 4)
              , (208, 'breeding', 'Reproduction', '{}', FALSE, 'Reproduction', 'text', 'textarea', NULL, NULL, 5, 4)
              , ( 208
                , 'trait_incubation_time'
                , 'Durée d''incubation'
                , '{}'
                , FALSE
                , 'Durée d''incubation'
                , 'text'
                , 'text'
                , NULL
                , NULL
                , 6
                , 1)
              , (209, 'trait_length', 'Longueur', '{}', FALSE, 'Longueur', 'text', 'text', NULL, NULL, 6, 2)
              , (210, 'trait_specie_group', 'Groupe', '{}', FALSE, 'Groupe', 'text', 'text', NULL, NULL, 6, 3)
              , ( 211
                , 'trait_migratory_behaviour'
                , 'Comportement migrateur'
                , '{}'
                , FALSE
                , 'Comportement migrateur'
                , 'text'
                , 'text'
                , NULL
                , NULL
                , 6
                , 4)
              , ( 212
                , 'trait_clutches_number'
                , 'Nombre de pontes'
                , '{}'
                , FALSE
                , 'Nombre de pontes'
                , 'text'
                , 'text'
                , NULL
                , NULL
                , 6
                , 5)
              , (212, 'trait_scope', 'Envergure', '{}', FALSE, 'Envergure', 'text', 'text', NULL, NULL, 6, 6)
              , (213, 'trait_food', 'Nourriture', '{}', FALSE, 'Nourriture', 'text', 'text', NULL, NULL, 6, 7)
              , (214, 'trait_max_age', 'Age maximal', '{}', FALSE, 'Age maximal', 'text', 'text', NULL, NULL, 6, 8)
              , ( 215
                , 'trait_eggs_number'
                , 'Nombre d''oeufs'
                , '{}'
                , FALSE
                , 'Nombre d''oeufs'
                , 'text'
                , 'text'
                , NULL
                , NULL
                , 6
                , 9)
              , (216, 'trait_weight', 'Poids', '{}', FALSE, 'Poids', 'text', 'text', NULL, NULL, 6, 10)
              , (217, 'trait_habitat', 'Habitat', '{}', FALSE, 'Habitat', 'text', 'text', NULL, NULL, 6, 11)
              , ( 218
                , 'trait_nest_length_stay'
                , 'Durée de séjour au nid jusqu''à l''envol'
                , '{}'
                , FALSE
                , 'Durée de séjour au nid jusqu''à l''envol'
                , 'text'
                , 'text'
                , NULL
                , NULL
                , 6
                , 12)
              , ( 219
                , 'trait_nesting_site'
                , 'Site de nidification'
                , '{}'
                , FALSE
                , 'Site de nidification'
                , 'text'
                , 'text'
                , NULL
                , NULL
                , 6
                , 13)
        ON CONFLICT DO NOTHING;

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

        DROP TYPE PHENOLOGY_PERIOD CASCADE;
        CREATE TYPE PHENOLOGY_PERIOD AS ENUM ('wintering','breeding','migration','migration_prenuptial','migration_postnuptial','all_period');
        DROP TABLE IF EXISTS atlas.dict_period_profiles CASCADE;
        CREATE TABLE atlas.dict_period_profiles
        (
            id                 INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
            code               VARCHAR(50)      NOT NULL,
            label              VARCHAR          NOT NULL,
            type_period        PHENOLOGY_PERIOD NOT NULL,
            start_month        INT              NOT NULL,
            start_day_of_month INT              NOT NULL,
            end_month          INT              NOT NULL,
            end_day_of_month   INT              NOT NULL,
            strict             BOOLEAN          NOT NULL
        );
        CREATE UNIQUE INDEX ON atlas.dict_period_profiles (type_period, start_month, start_day_of_month,
                                                           end_month,
                                                           end_day_of_month);
        CREATE UNIQUE INDEX ON atlas.dict_period_profiles (id);


        TRUNCATE atlas.dict_period_profiles RESTART IDENTITY CASCADE;
        INSERT INTO
            atlas.dict_period_profiles( type_period
                                      , code
                                      , label
                                      , start_month
                                      , start_day_of_month
                                      , end_month
                                      , end_day_of_month
                                      , strict)
            VALUES
                ( 'wintering'
                , 'FRMET_WINTERING_DEFAULT'
                , 'Metropolitan France wintering all species'
                , 12
                , 1
                , 1
                , 31
                , TRUE)
              , ('wintering', 'EQUA_WINTERING_NORTHERN', 'Equatorial wintering northern species', 12, 1, 2, 15, TRUE)
              , ('wintering', 'EQUA_WINTERING_SOUTHERN', 'Equatorial wintering southern species', 6, 15, 8, 15, TRUE)
              , ( 'breeding'
                , 'FRMET_BREEDING_DEFAULT'
                , 'Metropolitan France breeding all species (common profile)'
                , 1
                , 1
                , 1
                , 31
                , TRUE)
              , ( 'migration_prenuptial'
                , 'FRMET_MIG_PRE_DEFAULT'
                , 'Metropolitan France migration all species'
                , 1
                , 1
                , 6
                , 15
                , TRUE)
              , ( 'migration_postnuptial'
                , 'FRMET_MIG_PRE_DEFAULT'
                , 'Metropolitan France migration all species'
                , 6
                , 16
                , 12
                , 31
                , TRUE)
        ON CONFLICT(type_period, start_month, start_day_of_month, end_month,
            end_day_of_month) DO NOTHING;

        DROP TABLE IF EXISTS atlas.dict_breeding_code_profiles CASCADE;
        CREATE TABLE atlas.dict_breeding_code_profiles
        (
            id                   INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
            code                 VARCHAR(50) NOT NULL,
            label                VARCHAR     NOT NULL,
            breeding_codes_start INT[]       NOT NULL,
            breeding_code_end    INT[]       NOT NULL
        );

        INSERT INTO
            atlas.dict_breeding_code_profiles (code, label, breeding_codes_start, breeding_code_end)
            VALUES
                ('DEFAULT', 'default breeding codes', ARRAY [3], ARRAY [13,20]);


        DROP TABLE IF EXISTS atlas.cor_specie_territory_profile;
        CREATE TABLE atlas.cor_specie_territory_profile
        (
            id             INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
            cd_nom         INT REFERENCES taxonomie.taxref (cd_nom),
            period_profile INT REFERENCES atlas.dict_period_profiles (id),
            breeding_codes INT REFERENCES atlas.dict_breeding_code_profiles (id),
            id_area        INT REFERENCES ref_geo.l_areas (id_area)
        );

        UPDATE taxonomie.cor_c_vn_taxref
        SET
            taxref_id = cd_ref
            FROM
                taxonomie.taxref
            WHERE
                  cd_nom = taxref_id
              AND taxref.cd_nom != taxref.cd_ref;

        CREATE UNIQUE INDEX ON atlas.cor_specie_territory_profile (cd_nom, period_profile, breeding_codes, id_area);

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

        CREATE TABLE atlas.t_decades AS
        WITH
            t1 AS (SELECT
                       extract(MONTH FROM dd::DATE) AS m
                     , extract(DAY FROM dd::DATE)      dom
                     , CASE
                           WHEN extract(DAY FROM dd::DATE) <= 10
                               THEN 1
                           WHEN extract(DAY FROM dd::DATE) <= 20
                               THEN 2
                           ELSE 3 END               AS dpos
                       FROM
                           generate_series
                               ('2020-01-01'::DATE
                               , '2020-12-31'::DATE
                               , '1 day'::INTERVAL) dd)
        SELECT
            m
          , dom
          , rank() OVER ( PARTITION BY dpos) AS decade
            FROM
                t1
            ORDER BY
                m ASC
              , dom ASC;


        CREATE TABLE IF NOT EXISTS atlas.t_epoc
        (
            id_epoc   INTEGER PRIMARY KEY,
            id_ff     VARCHAR,
            status    VARCHAR,
            rang_rsv  INT,
            id_area   INT REFERENCES ref_geo.l_areas (id_area),
            area_code VARCHAR,
            geom      GEOMETRY(point, 4326),
            geojson   JSONB GENERATED ALWAYS AS (st_asgeojson(geom)::JSONB ) STORED
        );
        -- ALTER TABLE atlas.t_epoc OWNER TO gnadm;
        COMMENT ON COLUMN atlas.t_epoc.id_epoc IS 'EPOC unique ID';
        COMMENT ON COLUMN atlas.t_epoc.id_ff IS 'EPOC Official name from Faune-France';
        COMMENT ON COLUMN atlas.t_epoc.status IS 'EPOC status : Officiel vs Réserve';
        COMMENT ON COLUMN atlas.t_epoc.rang_rsv IS 'EPOC rang ("Réserve" only)';
        COMMENT ON COLUMN atlas.t_epoc.id_area IS 'Grid area id, foreign key to ref_geo.l_areas';
        COMMENT ON COLUMN atlas.t_epoc.area_code IS 'Grid area code';
        COMMENT ON COLUMN atlas.t_epoc.geom IS 'Geolocation (Point, 4326)';
        COMMENT ON COLUMN atlas.t_epoc.geojson IS 'Geolocation as geojson (autogenerated from geom)';
        CREATE UNIQUE INDEX IF NOT EXISTS idx_epoc_id_epoc ON atlas.t_epoc (id_epoc);
        CREATE INDEX IF NOT EXISTS gidx_epoc ON atlas.t_epoc USING gist (geom);
        CREATE INDEX IF NOT EXISTS idx_epoc_id_area ON atlas.t_epoc (id_area);
        CREATE INDEX IF NOT EXISTS idx_epoc_status ON atlas.t_epoc (status);

        --         INSERT INTO
--             atlas.t_epoc (id_epoc, id_ff, status, rang_rsv, id_area, area_code, geom)
--         SELECT
--             epoc.id_epoc
--           , epoc.id_ff
--           , epoc.stt_ssu
--           , epoc.rng_rsr
--           , l_areas.id_area
--           , replace(l_areas.area_code, '10kmL93', '')
--           , st_transform(epoc.geom, 4326)
--             FROM
--                 tmp.epoc
--                     JOIN ref_geo.l_areas ON st_intersects(st_transform(epoc.geom, 4326), l_areas.geom)
--                     AND l_areas.id_type = ref_geo.get_id_area_type('ATLAS_GRID')
--         ON CONFLICT (id_epoc) DO NOTHING;
--         CLUSTER atlas.t_epoc
--             USING gidx_epoc;

        /* Commit changes */
        COMMIT;

    END
$$
;