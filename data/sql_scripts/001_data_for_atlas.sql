/*
Main structured data used to generate atlas data
-------------------------------------------------
Observation and forms data
*/

DO
$$
    BEGIN
        /* INFO: message */
        RAISE INFO 'INFO: Main structured data used to generate atlas data';
        RAISE INFO '-- % -- START SCRIPT', clock_timestamp();


        /* INFO: Observations, attached to areas */
        RAISE INFO '-- % -- DROP CASCADE MV atlas.mv_data_for_atlas', clock_timestamp();
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_data_for_atlas CASCADE;
        RAISE INFO '-- % -- CREATE MV atlas.mv_data_for_atlas', clock_timestamp();
        RAISE INFO '-- % -- COMMENT AND INDEXES ON atlas.mv_data_for_atlas', clock_timestamp();
        CREATE MATERIALIZED VIEW atlas.mv_data_for_atlas AS
        (
        WITH
            cor_area_synthese AS (
                SELECT
                    /* Zonages utilisés : Mailles */
                    cas.*
                    FROM
                        gn_synthese.cor_area_synthese cas
                            JOIN ref_geo.l_areas ON cas.id_area = l_areas.id_area
                    WHERE
                          enable IS TRUE
                      AND id_type = ref_geo.get_id_area_type('ATLAS_GRID')
            )
            --           , data AS (
            /* Filtrage des données et association au zonage */
        SELECT DISTINCT
            cor_area_synthese.id_area
          , id_form                                 AS id_form_universal
          , synthese.id_synthese                    AS id_data
          , synthese.cd_nom
          , synthese.altitude_min                   AS altitude
          , synthese.date_min::DATE
          , (synthese.date_min > '2019-01-31'::DATE OR (tcse.bird_breed_code BETWEEN 2 AND 50
            AND synthese.date_min >= '2019-01-01')) AS new_data_all_period
          , (synthese.date_min <= '2019-01-31'::DATE OR (tcse.bird_breed_code BETWEEN 2 AND 50
            AND synthese.date_min < '2019-01-01'))  AS old_data_all_period
          , (extract(MONTH FROM synthese.date_min) IN (12, 1)
            AND synthese.date_min <= '2019-01-31')  AS old_data_wintering
          , (extract(MONTH FROM synthese.date_min) IN (12, 1)
            AND synthese.date_min > '2019-11-30')   AS new_data_wintering
          , (tcse.bird_breed_code BETWEEN 2 AND 50
            AND synthese.date_min < '2019-01-01')   AS old_data_breeding
          , (tcse.bird_breed_code BETWEEN 2 AND 50
            AND synthese.date_min >= '2019-01-01')  AS new_data_breeding
          , tcse.bird_breed_code
            FROM
                gn_synthese.synthese
                    JOIN cor_area_synthese ON cor_area_synthese.id_synthese = synthese.id_synthese
                    JOIN src_lpodatas.t_c_synthese_extended tcse ON synthese.id_synthese = tcse.id_synthese
                    JOIN atlas.mv_taxa_groups groups ON synthese.cd_nom = groups.cd_nom
                    JOIN atlas.t_taxa ON t_taxa.cd_nom = groups.cd_group
            WHERE
                  t_taxa.enabled
              AND synthese.id_nomenclature_valid_status IN (ref_nomenclatures.get_id_nomenclature('STATUT_VALID', '1'),
                                                            ref_nomenclatures.get_id_nomenclature('STATUT_VALID', '2'))
              AND synthese.id_nomenclature_observation_status !=
                  ref_nomenclatures.get_id_nomenclature('STATUT_OBS', 'No')
              AND date_min >= '2007-01-01')
        WITH NO DATA;
        COMMENT ON MATERIALIZED VIEW atlas.mv_data_for_atlas IS 'All datas used for atlas';
        CREATE UNIQUE INDEX i_data_for_atlas_id_area_id_data ON atlas.mv_data_for_atlas (id_area, id_data);
        CREATE INDEX i_data_for_atlas_cdnom ON atlas.mv_data_for_atlas (cd_nom);
        CREATE INDEX i_data_for_atlas_idarea ON atlas.mv_data_for_atlas (id_area);
        CREATE INDEX i_data_for_atlas_bird_breeding_code ON atlas.mv_data_for_atlas (bird_breed_code);
        /* INFO: Forms, attached to areas */
        RAISE INFO '-- % -- DROP CASCADE MV atlas.mv_forms_for_atlas', clock_timestamp();
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_forms_for_atlas CASCADE;
        RAISE INFO '-- % -- CREATE MV atlas.mv_forms_for_atlas', clock_timestamp();
        CREATE MATERIALIZED VIEW atlas.mv_forms_for_atlas AS
        (
        WITH
            areas AS (
                SELECT
                    /* Zonages utilisés : Mailles */
                    l_areas.id_area
                  , st_transform(l_areas.geom, 4326) AS geom
                    FROM
                        ref_geo.l_areas
                    WHERE
                          enable IS TRUE
                      AND id_type = ref_geo.get_id_area_type('ATLAS_GRID')
            )
        SELECT
            areas.id_area
          , site                                                                      AS site
          , cast(item ->> '@id' AS INTEGER)                                           AS id_form_local
          , item ->> 'id_form_universal'                                              AS id_form_universal
          , cast(item ->> 'date_start' AS DATE) + cast(item ->> 'time_start' AS TIME) AS timestamp_start
          , cast(item ->> 'date_stop' AS DATE) + cast(item ->> 'time_stop' AS TIME)   AS timestamp_stop
          , CASE
                WHEN extract(EPOCH FROM age((cast(item ->> 'date_stop' AS DATE) + cast(item ->> 'time_stop' AS TIME)),
                                            (cast(item ->> 'date_start' AS DATE) + cast(item ->> 'time_start' AS TIME)))) >
                     3600 THEN 3600
                ELSE extract(EPOCH FROM age((cast(item ->> 'date_stop' AS DATE) + cast(item ->> 'time_stop' AS TIME)),
                                            (cast(item ->> 'date_start' AS DATE) + cast(item ->> 'time_start' AS TIME))))
                END                                                                   AS timelength_secs
          , extract(MONTH FROM cast(item ->> 'date_start' AS DATE)) IN (1, 12)        AS is_wintering
          , extract(MONTH FROM cast(item ->> 'date_start' AS DATE)) BETWEEN 3 AND 7   AS is_breeding
          , CASE
                WHEN item ? 'comment' THEN (item ->> 'comment' ILIKE '%EPOC%')
                ELSE FALSE END                                                        AS is_epoc
          , cast(item ->> 'full_form' AS BOOLEAN)                                     AS full_form
          , st_setsrid(st_makepoint(cast(item ->> 'lon' AS NUMERIC), cast(item ->> 'lat' AS NUMERIC)),
                       4326)                                                          AS geom
          , item ->> 'comment'                                                        AS comment
          , item #>> '{protocol,protocol_name}'                                       AS protocol
            FROM
                src_vn_json.forms_json
              , areas
            WHERE
                  st_intersects(
                          st_setsrid(st_makepoint(cast(item ->> 'lon' AS NUMERIC), cast(item ->> 'lat' AS NUMERIC)),
                                     4326), areas.geom)
              AND cast(item ->> 'date_start' AS DATE) > '2018-12-31'
                )

        WITH NO DATA;
        RAISE INFO '-- % -- COMMENT AND INDEXES ON atlas.mv_forms_for_atlas', clock_timestamp();
        COMMENT ON MATERIALIZED VIEW atlas.mv_forms_for_atlas IS 'All forms realized during atlas period';
--         CREATE UNIQUE INDEX i_unique_forms_for_atlas_idforms on atlas.mv_forms_for_atlas(id_form_universal);
        CREATE INDEX i_forms_for_atlas_geom ON atlas.mv_forms_for_atlas USING gist (geom);
        CREATE INDEX i_forms_for_atlas_id_form_universal ON atlas.mv_forms_for_atlas (id_form_universal);
        CREATE INDEX i_forms_for_atlas_id_area ON atlas.mv_forms_for_atlas (id_area);

        COMMIT;
    END
$$
;

