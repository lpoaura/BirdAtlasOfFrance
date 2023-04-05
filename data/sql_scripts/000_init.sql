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
        FROM gn_commons.t_modules
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
        SELECT DISTINCT taxref.cd_nom
                      , CASE
                            WHEN id_rang LIKE 'SSES' THEN
                                cd_sup
                            ELSE
                                cd_ref
            END                                                                           AS cd_sp
                      --  , FALSE                                                             AS has_subsp
                      , taxref.id_rang
                      , NOT taxref.cd_nom IN (2852, 2856, 2657, 836345, 3811, 2848, 3076) AS enabled
                      , taxref.id_rang LIKE 'ES'
            OR (taxref.id_rang LIKE 'SSES'
                AND taxref.cd_nom IN (3745, 886211, 886212, 961306, 804727))              AS available
        FROM gn_synthese.synthese
                 JOIN taxonomie.taxref ON synthese.cd_nom = taxref.cd_nom
        WHERE taxref.classe LIKE 'Aves'
          AND taxref.cd_nom = taxref.cd_ref
        ON CONFLICT (cd_nom)
            DO NOTHING;

/* Set has_subsp value where taxa has sub-specie(s) */
        UPDATE
            atlas.t_taxa
        SET has_subsp = FALSE
        FROM (SELECT cd_sp
              FROM atlas.t_taxa
              WHERE cd_sp != cd_nom) AS t
        WHERE t.cd_sp = t_taxa.cd_nom;

        CREATE INDEX IF NOT EXISTS i_forms_geom_from_json ON src_vn_json.forms_json USING gist (st_setsrid(st_makepoint(
                                                                                                                   cast(item ->> 'lon' AS NUMERIC),
                                                                                                                   cast(item ->> 'lat' AS NUMERIC)),
                                                                                                           4326));


        WITH datas AS (SELECT CASE
                                  WHEN taxref.id_rang LIKE 'SSES' THEN
                                      cd_sup
                                  ELSE
                                      taxref.cd_nom
            END AS cd_group
                            , taxref.cd_nom
                       FROM gn_synthese.synthese
                                JOIN taxonomie.taxref ON synthese.cd_nom = taxref.cd_nom
                       WHERE taxref.classe LIKE 'Aves'
                         AND taxref.cd_nom = taxref.cd_ref
                         AND taxref.id_rang IN ('ES', 'SSES')
                       UNION
                       SELECT taxref.cd_nom AS cd_group
                            , taxref.cd_nom
                       FROM gn_synthese.synthese
                                JOIN taxonomie.taxref ON synthese.cd_nom = taxref.cd_nom
                       WHERE taxref.classe LIKE 'Aves'
                         AND taxref.cd_nom = taxref.cd_ref
                         AND taxref.id_rang IN ('ES', 'SSES'))
        SELECT DISTINCT cd_group
                      , cd_nom
        FROM datas;


        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_taxa_groups CASCADE;
        CREATE MATERIALIZED VIEW atlas.mv_taxa_groups AS
        (
        WITH datas AS (SELECT CASE
                                  WHEN t_taxa.rank LIKE 'SSES' THEN
                                      cd_sup
                                  ELSE
                                      t_taxa.cd_nom
            END AS cd_group
                            , t_taxa.cd_nom
                       FROM gn_synthese.synthese
                                JOIN atlas.t_taxa ON synthese.cd_nom = t_taxa.cd_nom
                                JOIN taxonomie.taxref ON t_taxa.cd_nom = taxref.cd_nom
                       WHERE t_taxa.cd_nom = taxref.cd_ref
                         AND t_taxa.rank IN (
                                             'ES', 'SSES')
                       UNION
                       SELECT taxref.cd_nom AS cd_group
                            , t_taxa.cd_nom
                       FROM gn_synthese.synthese
                                JOIN atlas.t_taxa
                                     ON synthese.cd_nom = t_taxa.cd_nom
                                JOIN taxonomie.taxref ON t_taxa.cd_nom = taxref.cd_nom
                       WHERE t_taxa.cd_nom = taxref.cd_ref
                         AND t_taxa.rank IN (
                                             'ES', 'SSES'))
        SELECT DISTINCT cd_group
                      , cd_nom
        FROM datas);

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
        INSERT INTO atlas.dict_period_profiles( type_period
                                              , code
                                              , label
                                              , start_month
                                              , start_day_of_month
                                              , end_month
                                              , end_day_of_month
                                              , strict)
        VALUES ( 'wintering'
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

        INSERT INTO atlas.dict_breeding_code_profiles (code, label, breeding_codes_start, breeding_code_end)
        VALUES ('DEFAULT', 'default breeding codes', ARRAY [3], ARRAY [13,20]);


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
        SET taxref_id = cd_ref
        FROM taxonomie.taxref
        WHERE cd_nom = taxref_id
          AND taxref.cd_nom != taxref.cd_ref;

        CREATE UNIQUE INDEX ON atlas.cor_specie_territory_profile (cd_nom, period_profile, breeding_codes, id_area);

        INSERT INTO taxonomie.bib_noms (cd_nom, cd_ref, nom_francais, comments)
        SELECT taxref.cd_nom
             , taxref.cd_ref
             , item ->> 'french_name' AS french_name
             , 'généré pour ODF'
        FROM src_vn_json.species_json
                 JOIN taxonomie.cor_c_vn_taxref ON vn_id = species_json.id
                 JOIN taxonomie.taxref ON cor_c_vn_taxref.taxref_id = taxref.cd_nom
                 JOIN atlas.t_taxa ON taxref.cd_nom = t_taxa.cd_nom
        WHERE site = (SELECT DISTINCT site FROM src_vn_json.species_json LIMIT 1)
          --              AND cast(item ->> 'id_taxo_group' as int) = 1
          AND taxref.classe LIKE 'Aves'
        ON CONFLICT (cd_nom) DO NOTHING;


        WITH species AS (SELECT taxref.cd_nom
                              , taxref.lb_nom                                                          AS latin_name
                              , coalesce(t.french_name,
                                         coalesce(split_part(taxref.nom_vern, ',', 1), taxref.lb_nom)) AS french_name
                              , coalesce(t.english_name,
                                         split_part(taxref.nom_vern_eng, ',', 1))                      AS english_name
                         FROM taxonomie.taxref
                                  JOIN (SELECT DISTINCT cd_nom FROM gn_synthese.synthese) AS cd_nom_synthese ON
                             taxref.cd_nom = cd_nom_synthese.cd_nom
                                  LEFT JOIN (taxonomie.cor_c_vn_taxref
                             JOIN (SELECT id,
                                          (array_agg(item ->> 'french_name')
                                           FILTER (WHERE item ->> 'french_name' IS NOT NULL))[1]  AS french_name,
                                          (array_agg(item ->> 'english_name')
                                           FILTER (WHERE item ->> 'english_name' IS NOT NULL))[1] AS english_name
                                   FROM src_vn_json.species_json
                                   GROUP BY id) AS species_json ON species_json.id = vn_id) AS t
                                            ON taxref.cd_nom = t.taxref_id
                         WHERE taxref.classe LIKE 'Aves')
           , attributs AS (SELECT (SELECT id_attribut
                                   FROM taxonomie.bib_attributs
                                   WHERE bib_attributs.nom_attribut LIKE 'odf_sci_name') AS id_attribut
                                , species.latin_name                                     AS valeur_attribut
                                , species.cd_nom
                           FROM species
                           UNION
                           SELECT (SELECT id_attribut
                                   FROM taxonomie.bib_attributs
                                   WHERE bib_attributs.nom_attribut LIKE 'odf_common_name_fr') AS id_attribut
                                , species.french_name                                          AS valeur_attribut
                                , species.cd_nom
                           FROM species
                           UNION
                           SELECT (SELECT id_attribut
                                   FROM taxonomie.bib_attributs
                                   WHERE bib_attributs.nom_attribut LIKE 'odf_common_name_en') AS id_attribut
                                , species.english_name                                         AS valeur_attribut
                                , species.cd_nom
                           FROM species)
        INSERT
        INTO taxonomie.cor_taxon_attribut(id_attribut, valeur_attribut, cd_ref)
        SELECT *
        FROM attributs
        WHERE valeur_attribut IS NOT NULL
        ORDER BY cd_nom, id_attribut
        ON CONFLICT (id_attribut, cd_ref) DO NOTHING;


        WITH species AS (SELECT taxref.cd_nom
                              , taxref.lb_nom                                                          AS latin_name
                              , coalesce(t.french_name,
                                         coalesce(split_part(taxref.nom_vern, ',', 1), taxref.lb_nom)) AS french_name
                              , coalesce(t.english_name,
                                         split_part(taxref.nom_vern_eng, ',', 1))                      AS english_name
                         FROM taxonomie.taxref
                                  JOIN (SELECT DISTINCT cd_nom FROM gn_synthese.synthese) AS cd_nom_synthese ON
                             taxref.cd_nom = cd_nom_synthese.cd_nom
                                  LEFT JOIN (taxonomie.cor_c_vn_taxref
                             JOIN (SELECT id,
                                          (array_agg(item ->> 'french_name')
                                           FILTER (WHERE item ->> 'french_name' IS NOT NULL))[1]  AS french_name,
                                          (array_agg(item ->> 'english_name')
                                           FILTER (WHERE item ->> 'english_name' IS NOT NULL))[1] AS english_name
                                   FROM src_vn_json.species_json
                                   GROUP BY id) AS species_json ON species_json.id = vn_id) AS t
                                            ON taxref.cd_nom = t.taxref_id
                         WHERE taxref.classe LIKE 'Aves')
           , attributs AS (SELECT (SELECT id_attribut
                                   FROM taxonomie.bib_attributs
                                   WHERE bib_attributs.nom_attribut LIKE 'odf_sci_name') AS id_attribut
                                , species.latin_name                                     AS valeur_attribut
                                , species.cd_nom
                           FROM species
                           UNION
                           SELECT (SELECT id_attribut
                                   FROM taxonomie.bib_attributs
                                   WHERE bib_attributs.nom_attribut LIKE 'odf_common_name_fr') AS id_attribut
                                , species.french_name                                          AS valeur_attribut
                                , species.cd_nom
                           FROM species
                           UNION
                           SELECT (SELECT id_attribut
                                   FROM taxonomie.bib_attributs
                                   WHERE bib_attributs.nom_attribut LIKE 'odf_common_name_en') AS id_attribut
                                , species.english_name                                         AS valeur_attribut
                                , species.cd_nom
                           FROM species)
        UPDATE
            taxonomie.cor_taxon_attribut
        SET valeur_attribut = attributs.valeur_attribut
        FROM attributs
        WHERE cor_taxon_attribut.
                  cd_ref = attributs.cd_nom
          AND cor_taxon_attribut.id_attribut = attributs.id_attribut;


        CREATE TABLE atlas.t_decades AS
        WITH t1 AS (SELECT extract(MONTH FROM dd::DATE) AS m
                         , extract(DAY FROM dd::DATE)      dom
                         , CASE
                               WHEN extract(DAY FROM dd::DATE) <= 10
                                   THEN 1
                               WHEN extract(DAY FROM dd::DATE) <= 20
                                   THEN 2
                               ELSE 3 END               AS dpos
                    FROM generate_series
                             ('2020-01-01'::DATE
                             , '2020-12-31'::DATE
                             , '1 day'::INTERVAL) dd)
        SELECT m
             , dom
             , rank() OVER ( PARTITION BY dpos) AS decade
        FROM t1
        ORDER BY m ASC
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

        CREATE TABLE atlas.t_territory_altitude
        (
            id          INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
            altitude    INTEGER NOT NULL,
            pixel_count INTEGER NOT NULL,
            id_area     INTEGER REFERENCES ref_geo.l_areas (id_area)
        );

        CREATE INDEX ON atlas.t_territory_altitude (id_area);

        COMMENT ON TABLE atlas.t_territory_altitude IS 'Table source pour le calcul des altitudes d''un territoire';
        COMMENT ON COLUMN atlas.t_territory_altitude.pixel_count IS 'Nombre de pixels (pour calcul de proportion relative)'
        COMMENT ON COLUMN atlas.t_territory_altitude.altitude IS 'Altitude (en m)';
        COMMENT ON COLUMN atlas.t_territory_altitude.id_area IS 'Territoire d''atlas associé (type ATLAS_TERRITORY and enable=True)';

        /* SURVEY DATA structure */


        CREATE SCHEMA IF NOT EXISTS src_survey;

        CREATE TYPE TYPE_ILLUSTRATION AS ENUM ('graphique', 'carte');

        CREATE TYPE TYPE_REPRESENTATION AS ENUM ('breed_min_max', 'breed_count');


        /* Informations relatives aux acteurs des suivis  */
        CREATE TABLE IF NOT EXISTS src_survey.tab_utilisateur
        (
            id_utilisateur SERIAL
                PRIMARY KEY,
            nom            VARCHAR(100),
            prenom         VARCHAR(100),
            email          VARCHAR(255),
            tel            VARCHAR(20),
            date_naissance DATE,
            pays           VARCHAR(255),
            ville          VARCHAR(255),
            code_postal    VARCHAR(5)
        );

        /* Résultats détaillés des suivis (données "brutes") */
        CREATE TABLE IF NOT EXISTS src_survey.info_detail
        (
            id_info_detail   SERIAL
                PRIMARY KEY,
            valeur           DOUBLE PRECISION NOT NULL,
            type_valeur      VARCHAR(100)     NOT NULL,
            unite            VARCHAR(255)     NOT NULL,
            info_commentaire VARCHAR(255)
        );

        /* Critères de fiabilité des informations stockées */
        CREATE TABLE IF NOT EXISTS src_survey.info_fiabilite
        (
            id_fiabilite SERIAL
                PRIMARY KEY,
            verification VARCHAR(100),
            indicateur   VARCHAR(100)
        );

        /* Descriptif général d'une information
           lien avec src_survey.info_detail via src_survey.cor_tab_detail
           lien avec src_survey.tab_utilisateur via src_survey.cor_tab_utilisateur
           */
        CREATE TABLE IF NOT EXISTS src_survey.info_generale
        (
            id_info_generale SERIAL
                PRIMARY KEY,
            date_debut       DATE,
            date_fin         DATE,
            cd_nom           INTEGER NOT NULL
                CONSTRAINT fk_cd_nom
                    REFERENCES taxonomie.taxref,
            id_area          INTEGER NOT NULL
                CONSTRAINT fk_id_area
                    REFERENCES ref_geo.l_areas,
            id_fiabilite     INTEGER NOT NULL
                CONSTRAINT fk_id_fiabilite
                    REFERENCES src_survey.info_fiabilite,
            protocole        VARCHAR(255),
            methode          VARCHAR(255),
            source_jdd       INTEGER
                CONSTRAINT fk_id_jdd
                    REFERENCES gn_meta.t_datasets,
            autre_info       TEXT
        );

        /* relation n-n src_survey.info_generale <> src_survey.tab_utilisateur  */
        CREATE TABLE IF NOT EXISTS cor_tab_utilisateur
        (
            id_tab_personne  SERIAL
                PRIMARY KEY,
            id_info_generale INTEGER NOT NULL
                CONSTRAINT fk_id_info_generale
                    REFERENCES src_survey.info_generale,
            id_utilisateur   INTEGER NOT NULL
                CONSTRAINT fk_id_personne
                    REFERENCES src_survey.tab_utilisateur,
            role_personne    VARCHAR(255)
        );

        /* relation n-n src_survey.info_generale <> src_survey.info_detail  */
        CREATE TABLE IF NOT EXISTS src_survey.cor_tab_detail
        (
            id_tab_detail          SERIAL
                PRIMARY KEY,
            id_info_generale       INTEGER
                CONSTRAINT fk_id_info_generale
                    REFERENCES src_survey.info_generale,
            id_info_detail         INTEGER
                CONSTRAINT fk_id_obs
                    REFERENCES src_survey.info_detail,
            commentaire_speficique VARCHAR(255)
        );

        /* description des représentations coté frontend (carte vs graphique (tendance, boite à moustache, etc. ))*/
        CREATE TABLE IF NOT EXISTS t_representation
        (
            id_graph          INTEGER NOT NULL
                CONSTRAINT info_graph_pkey
                    PRIMARY KEY,
            id_jdd            INTEGER NOT NULL,
            unite             VARCHAR(255),
            representation    src_survey.TYPE_REPRESENTATION,
            information_graph VARCHAR(255),
            description       VARCHAR(255),
            type              src_survey.TYPE_ILLUSTRATION
        );

        /* table temporaire : A SUPPRIMER */
        CREATE TABLE IF NOT EXISTS src_survey.local_site
        (
            id         BIGINT NOT NULL
                PRIMARY KEY,
            geom       GEOMETRY(Point, 4326),
            zone_biog_ VARCHAR(30),
            r_gion_oc_ VARCHAR(254),
            territoire VARCHAR(50),
            secteur    VARCHAR(50),
            ss_secteur VARCHAR(50),
            localit_   VARCHAR(50),
            id_site    VARCHAR(50),
            x_coord    DOUBLE PRECISION,
            y_cood     DOUBLE PRECISION
        );

        /* informations carto à restituer  */
        CREATE MATERIALIZED VIEW IF NOT EXISTS src_survey.vm_carto_information AS
            /* INFO: UNIQUEMENT MILMIG ? DONNÉES CARTO */
        WITH reg_atlas AS (
/* SELECTION DES DEPARTEMENTS */
            SELECT la.id_area
                 , la.area_name
                 , la.geom
            FROM ref_geo.l_areas la
            WHERE la.id_type = ref_geo.get_id_area_type('DEP'))
           , all_info_detail AS (
            /* TODO : ??? */
            SELECT ctd.id_info_generale
                 , inf_detail.valeur
                 , inf_detail.type_valeur
                 , inf_detail.unite
            FROM src_survey.cor_tab_detail ctd
                     JOIN src_survey.info_detail inf_detail ON ctd.id_info_detail = inf_detail.id_info_detail)
           , date_max AS (
            /* TODO: Récupère la dernière occurence par eu de donnée / espèce / zonage */
            SELECT max(ig.date_fin) AS last_date
                 , ig.cd_nom
                 , ig.id_area
                 , ig.source_jdd
            FROM src_survey.info_generale ig
            GROUP BY ig.cd_nom, ig.id_area, ig.source_jdd)
           , prep_tab_general AS (
            /* */
            SELECT ig.id_info_generale
                 , ig.cd_nom
                 , aid.valeur
                 , aid.type_valeur
                 , aid.unite
            FROM src_survey.info_generale ig
                     RIGHT JOIN all_info_detail aid
                                ON aid.id_info_generale = ig.id_info_generale)
           , tab_value_nb AS (
            /* */
            SELECT prep_tab_general.id_info_generale
                 , prep_tab_general.unite
                 , prep_tab_general.cd_nom
                 , CASE
                       WHEN prep_tab_general.type_valeur::TEXT = 'nombre_unique'::TEXT
                           THEN prep_tab_general.valeur
                       ELSE NULL::DOUBLE PRECISION
                END AS val
            FROM prep_tab_general
            WHERE CASE
                      WHEN prep_tab_general.type_valeur::TEXT = 'nombre_unique'::TEXT
                          THEN prep_tab_general.valeur
                      ELSE NULL::DOUBLE PRECISION
                      END IS NOT NULL)
           , tab_value_min AS (SELECT prep_tab_general.id_info_generale
                                    , prep_tab_general.unite
                                    , prep_tab_general.cd_nom
                                    , CASE
                                          WHEN prep_tab_general.type_valeur::TEXT = 'min'::TEXT
                                              THEN prep_tab_general.valeur
                                          ELSE NULL::DOUBLE PRECISION
                END AS val_min
                               FROM prep_tab_general
                               WHERE CASE
                                         WHEN prep_tab_general.type_valeur::TEXT = 'min'::TEXT
                                             THEN prep_tab_general.valeur
                                         ELSE NULL::DOUBLE PRECISION
                                         END IS NOT NULL)
           , tab_value_max AS (SELECT prep_tab_general.id_info_generale
                                    , prep_tab_general.unite
                                    , prep_tab_general.cd_nom
                                    , CASE
                                          WHEN prep_tab_general.type_valeur::TEXT = 'max'::TEXT
                                              THEN prep_tab_general.valeur
                                          ELSE NULL::DOUBLE PRECISION
                END AS val_max
                               FROM prep_tab_general
                               WHERE CASE
                                         WHEN prep_tab_general.type_valeur::TEXT = 'max'::TEXT
                                             THEN prep_tab_general.valeur
                                         ELSE NULL::DOUBLE PRECISION
                                         END IS NOT NULL)
           , tab_unique_nb AS (SELECT DISTINCT ig.id_info_generale
                                             , ig.date_debut
                                             , ig.date_fin
                                             , ig.cd_nom
                                             , ig.id_area
                                             , ig.source_jdd
                                             , aid.unite
                                             , CASE
                                                   WHEN la.centroid IS NULL THEN st_centroid(la.geom)
                                                   ELSE la.centroid
                END AS centroid
                               FROM src_survey.info_generale ig
                                        RIGHT JOIN all_info_detail aid
                                                   ON aid.id_info_generale = ig.id_info_generale
                                        JOIN ref_geo.l_areas la ON la.id_area = ig.id_area
                                        JOIN src_survey.info_fiabilite if2 ON ig.id_fiabilite = if2.id_fiabilite)
           , tab_final AS (SELECT tun.id_info_generale
                                , tun.date_debut
                                , tun.date_fin
                                , tun.cd_nom
                                , tun.id_area
                                , tun.source_jdd
                                , tun.unite
                                , tun.centroid
                                , tvn.val
                                , tvmax.val_max
                                , tvmin.val_min
                           FROM tab_unique_nb tun
                                    LEFT JOIN tab_value_nb tvn
                                              ON tvn.id_info_generale = tun.id_info_generale AND
                                                 tvn.unite::TEXT = tun.unite::TEXT
                                    LEFT JOIN tab_value_min tvmin
                                              ON tvmin.id_info_generale = tun.id_info_generale AND
                                                 tvmin.unite::TEXT = tun.unite::TEXT
                                    LEFT JOIN tab_value_max tvmax
                                              ON tvmax.id_info_generale = tun.id_info_generale AND
                                                 tvmax.unite::TEXT = tun.unite::TEXT
                           ORDER BY tun.id_info_generale)
        SELECT row_number() OVER ()                           AS id
             , tf.source_jdd
             , ig2.id_jdd
             , tf.cd_nom
             , tf.unite                                       AS unite_table
             , ig2.unite                                      AS unite_graph
             , ig2.representation                             AS type_graph
             , ra.id_area
             , ra.area_name
             , ra.geom
             , dm.last_date
             , sum(coalesce(tf.val, 0::DOUBLE PRECISION))     AS value
             , sum(coalesce(tf.val_max, 0::DOUBLE PRECISION)) AS value_min
             , sum(coalesce(tf.val_min, 0::DOUBLE PRECISION)) AS value_max
             , count(*)                                       AS nb_data
        FROM src_survey.t_representation ig2
                 LEFT JOIN tab_final tf
                           ON tf.source_jdd::TEXT = ig2.id_jdd::TEXT
                 LEFT JOIN reg_atlas ra ON st_within(tf.centroid, ra.geom)
                 LEFT JOIN date_max dm
                           ON tf.date_fin = dm.last_date AND tf.id_area = dm.id_area AND tf.cd_nom = dm.cd_nom AND
                              tf.source_jdd::TEXT = dm.source_jdd::TEXT
                 LEFT JOIN ref_geo.l_areas la2 ON la2.id_area = tf.id_area
                 LEFT JOIN ref_geo.bib_areas_types bat2 ON la2.id_type = bat2.id_type
        WHERE ig2.unite::TEXT = tf.unite::TEXT
          AND ig2.type = 'carte'::src_survey.TYPE_ILLUSTRATION
          AND dm.last_date IS NOT NULL
          AND (bat2.type_code::TEXT = ANY
               (ARRAY ['COM'::CHARACTER VARYING::TEXT, 'DEP'::CHARACTER VARYING::TEXT, 'PSOM'::CHARACTER VARYING::TEXT]))
        GROUP BY tf.source_jdd, ig2.id_jdd, tf.cd_nom, ig2.unite, ig2.representation, ra.id_area, ra.area_name
               , ra.geom
               , tf.unite
               , dm.last_date;


        CREATE MATERIALIZED VIEW IF NOT EXISTS src_survey.vm_graph_information AS
            /* INFO: UNIQUEMENT MILMIG ? DONNÉES GRAPHS */
        WITH reg_atlas AS (SELECT la.id_area
                                , la.area_name
                                , la.geom
                           FROM ref_geo.l_areas la
                           WHERE la.id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
                             AND la.enable)
           , all_info_detail AS (SELECT ctd.id_info_generale
                                      , inf_detail.valeur
                                      , inf_detail.type_valeur
                                      , inf_detail.unite
                                 FROM src_survey.cor_tab_detail ctd
                                          JOIN src_survey.info_detail inf_detail
                                               ON ctd.id_info_detail = inf_detail.id_info_detail)
           , prep_tab_general AS (SELECT ig.id_info_generale
                                       , ig.cd_nom
                                       , aid.valeur
                                       , aid.type_valeur
                                       , aid.unite
                                  FROM src_survey.info_generale ig
                                           RIGHT JOIN all_info_detail aid
                                                      ON aid.id_info_generale = ig.id_info_generale)
           , tab_values AS
            (SELECT prep_tab_general.id_info_generale
                  , prep_tab_general.unite
                  , prep_tab_general.cd_nom
                  , (array_agg(prep_tab_general.valeur)
                     FILTER (WHERE prep_tab_general.type_valeur::TEXT = 'max'::TEXT ))[1]           AS val_max
                  , (array_agg(prep_tab_general.valeur)
                     FILTER (WHERE prep_tab_general.type_valeur::TEXT = 'min'::TEXT ))[1]           AS val_min
                  , (array_agg(prep_tab_general.valeur)
                     FILTER (WHERE prep_tab_general.type_valeur::TEXT = 'nombre_unique'::TEXT ))[1] AS val
             FROM prep_tab_general
             GROUP BY prep_tab_general.id_info_generale, prep_tab_general.unite, prep_tab_general.cd_nom)
           , tab_unique_nb AS (SELECT DISTINCT ig.id_info_generale
                                             , ig.date_debut
                                             , ig.date_fin
                                             , ig.cd_nom
                                             , ig.source_jdd
                                             , ig.autre_info
                                             , aid.unite
                                             , la.area_name
                                             , coalesce(la.centroid, st_centroid(la.geom)) AS centroid
                               FROM src_survey.info_generale ig
                                        RIGHT JOIN all_info_detail aid
                                                   ON aid.id_info_generale = ig.id_info_generale
                                        JOIN ref_geo.l_areas la ON la.id_area = ig.id_area
                                        JOIN src_survey.info_fiabilite if2 ON ig.id_fiabilite = if2.id_fiabilite)
           , tab_final AS (SELECT tun.id_info_generale
                                , tun.date_debut
                                , tun.date_fin
                                , tun.cd_nom
                                , tun.source_jdd
                                , tun.unite
                                , tun.centroid
                                , tval.val
                                , tval.val_max
                                , tval.val_min
                           FROM tab_unique_nb tun
                                    LEFT JOIN tab_values tval
                                              ON tval.id_info_generale = tun.id_info_generale AND
                                                 tval.unite::TEXT = tun.unite::TEXT

                           ORDER BY tun.id_info_generale)
           , tab_doublon_histo AS (SELECT DISTINCT tf_1.cd_nom
                                                 , count(DISTINCT tr.id_jdd)                        AS nb_jdd
                                                 , string_agg(DISTINCT tr.id_jdd::TEXT, ', '::TEXT) AS list_jdd
                                   FROM src_survey.t_representation tr
                                            LEFT JOIN tab_final tf_1 ON tf_1.source_jdd::TEXT = tr.id_jdd::TEXT
                                   WHERE tr.type = 'graphique'::src_survey.TYPE_ILLUSTRATION
                                     AND tr.unite::TEXT = tf_1.unite::TEXT
                                   GROUP BY tf_1.cd_nom)
        SELECT tf.source_jdd
             , ig2.id_jdd
             , tf.id_info_generale
             , tf.cd_nom
             , tf.unite           AS unite_table
             , ig2.unite          AS unite_graph
             , ig2.representation AS type_graph
             , ra.id_area
             , ra.area_name       AS atlas_territory
             , tf.date_debut
             , tf.date_fin
             , tdh.nb_jdd
             , tdh.list_jdd
             , sum(tf.val)        AS value
             , sum(tf.val_min)    AS value_min
             , sum(tf.val_max)    AS value_max
             , count(*)           AS nb_data
        FROM src_survey.t_representation ig2
                 JOIN tab_final tf ON tf.source_jdd::TEXT = ig2.id_jdd::TEXT
                 JOIN reg_atlas ra ON st_within(tf.centroid, ra.geom)
                 JOIN tab_doublon_histo tdh ON tdh.cd_nom = tf.cd_nom
        WHERE ig2.unite::TEXT = tf.unite::TEXT
          AND ig2.type = 'graphique'::src_survey.TYPE_ILLUSTRATION
          AND (tdh.nb_jdd = 1 OR ig2.id_jdd::TEXT <> '1155'::TEXT)
        GROUP BY tf.source_jdd, ig2.id_jdd, tf.cd_nom, ig2.unite, ig2.representation, ra.id_area, ra.area_name
               , tf.unite
               , tf.date_debut, tf.date_fin, tdh.nb_jdd, tf.id_info_generale, tdh.list_jdd;

        /* */
        CREATE OR REPLACE VIEW src_survey.v_resume_info_api
                    (id_dataset, dataset_name, information_graph, representation, description, cd_nom, unite_table,
                     type_graph,
                     atlas_territory, date_debut_graph, date_fin_graph)
        AS
        SELECT td.id_dataset
             , td.dataset_name
             , tr.information_graph
             , tr.representation
             , tr.description
             , vgi.cd_nom
             , vgi.unite_table
             , vgi.type_graph
             , vgi.atlas_territory
             , min(vgi.date_debut) AS date_debut_graph
             , max(vgi.date_fin)   AS date_fin_graph
        FROM src_survey.vm_graph_information vgi
                 LEFT JOIN gn_meta.t_datasets td ON td.id_dataset::TEXT = vgi.id_jdd::TEXT
                 LEFT JOIN src_survey.t_representation tr ON tr.id_jdd::TEXT = vgi.id_jdd::TEXT
        GROUP BY td.id_dataset, td.dataset_name, tr.information_graph, tr.representation, tr.description, vgi.cd_nom
               , vgi.unite_table, vgi.type_graph, vgi.atlas_territory;


        COMMIT;

    END
$$
;
