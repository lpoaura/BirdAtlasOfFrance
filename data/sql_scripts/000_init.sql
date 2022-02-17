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
            id_area        INT REFERENCES ref_geo.l_areas (id_area),
            UNIQUE (cd_nom, period_profile, id_area)
        );
        CREATE INDEX ON atlas.cor_specie_territory_profile (cd_nom);
        CREATE INDEX ON atlas.cor_specie_territory_profile (period_profile);
        CREATE INDEX ON atlas.cor_specie_territory_profile (breeding_codes);
        CREATE INDEX ON atlas.cor_specie_territory_profile (id_area);


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
--         DROP TABLE atlas.t_historic_atlases_info CASCADE;
        CREATE TABLE atlas.t_historic_atlases_info
        (
            id            INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
            id_territory  INTEGER REFERENCES ref_geo.l_areas (id_area) NOT NULL,
            atlas_period  VARCHAR,
            date_start    DATE,
            date_end      DATE,
            season_period PHENOLOGY_PERIOD                             NOT NULL,
            description   VARCHAR,
            is_active     BOOLEAN                                      NOT NULL DEFAULT TRUE
        );
        COMMENT ON TABLE atlas.t_historic_atlases_info IS 'List of historic atlases and relative informations';
--         DROP TABLE atlas.t_historic_atlases_data CASCADE;
        CREATE TABLE atlas.t_historic_atlases_data
        (
            id                     INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
            id_historic_atlas_info INTEGER NOT NULL REFERENCES atlas.t_historic_atlases_info (id),
            id_area                INTEGER NOT NULL REFERENCES ref_geo.l_areas (id_area) NOT NULL,
            cd_nom                 INTEGER NOT NULL REFERENCES atlas.t_taxa (cd_nom),
            status                 VARCHAR
        );
        CREATE INDEX idx_id_historic_atlas_info ON atlas.t_historic_atlases_data (id_historic_atlas_info);
        CREATE INDEX idx_id_area ON atlas.t_historic_atlases_data (id_area);
        CREATE INDEX idx_cd_nom ON atlas.t_historic_atlases_data (cd_nom);
        CREATE INDEX idx_breeding_status ON atlas.t_historic_atlases_data (breeding_status);

        COMMENT ON TABLE atlas.t_historic_atlases_data IS 'Historic atlases data (one data is on specie on one area (grid) with one status from one source';

        COMMIT;

    END
$$
;
