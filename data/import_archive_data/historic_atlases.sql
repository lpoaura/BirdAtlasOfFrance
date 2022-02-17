/*
AREA KNOWLEDGE LIST TAXA
------------------------
Evaluate for each area and each season  knowledge level comparing old taxa count with new taxa count

ACTUAL TIME : 24minutes to create, too long...
*/
DO
$$
    BEGIN
        RAISE NOTICE 'INFO: Populate historic atlases data';

        CREATE INDEX ON src_historic_atlas.grpign150 (cd_sig);

        CREATE INDEX ON src_historic_atlas.i037_releves (cd_sig);

        CREATE INDEX ON src_historic_atlas.i037_releves (cd_releve);

        CREATE INDEX ON src_historic_atlas.i037_especes (cd_releve);

        CREATE INDEX ON src_historic_atlas.i037_especes (cd_nom);

        INSERT INTO
            atlas.t_historic_atlases_info(id_territory, atlas_period, date_start, date_end, season_period, description)
        SELECT DISTINCT
            territory.id_area
          , extract(YEAR FROM irc.date_inf::DATE) || '-' || extract(YEAR FROM irc.date_sup::DATE) AS atlas_period
          , irc.date_inf::DATE
          , irc.date_sup::DATE
          , 'breeding'::PHENOLOGY_PERIOD
          , 'Atlas des oiseaux de France métropolitaine ' || extract(YEAR FROM irc.date_inf::DATE) || '-' ||
            extract(YEAR FROM irc.date_sup::DATE)                                                 AS description
            FROM
                src_historic_atlas.i037_releves irc
              , ref_geo.l_areas AS territory
            WHERE
                  territory.id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
              AND territory.area_code LIKE 'FRMET';

        INSERT INTO
            atlas.t_historic_atlases_info(id_territory, atlas_period, date_start, date_end, season_period, description)
        SELECT
            id_area               AS id_territory
          , '2009-2012'           AS atlas_period
          , '2009-01-01'::DATE    AS date_start
          , '2012-12-31'::DATE    AS date_end
          , t.a::PHENOLOGY_PERIOD AS season_period
          , 'Atlas des oiseaux de France métropolitaine (' || t.a || ') 2009-2012'
            FROM
                ref_geo.l_areas AS territory
              , (SELECT unnest(ARRAY ['breeding','wintering']::TEXT[]) AS a) AS t
            WHERE
                  territory.id_type = ref_geo.get_id_area_type('ATLAS_TERRITORY')
              AND territory.area_code LIKE 'FRMET';

        /* Some fixes */
--         INSERT INTO
--             atlas.t_taxa(cd_nom, cd_sp, has_subsp, rank, enabled, available)
--             VALUES
--                 (4507, 4503, FALSE, 'SSES', FALSE, TRUE)
--               , (4285, 4280, FALSE, 'SSES', FALSE, TRUE)
--         ON CONFLICT (cd_nom) DO NOTHING;


--         TRUNCATE atlas.t_historic_atlases_data RESTART IDENTITY;

        INSERT INTO
            atlas.t_historic_atlases_data (id_historic_atlas_info, id_area, cd_nom, status)

        SELECT
            t_historic_atlases_info.id AS id_historic_atlas_info
          , grid.id_area
          , taxref.cd_ref
          , CASE
                WHEN ir.indice_syn_label::TEXT = 'Possible'::TEXT THEN 'Nicheur possible'::TEXT
                WHEN ir.indice_syn_label::TEXT = 'Probable'::TEXT THEN 'Nicheur probable'::TEXT
                WHEN ir.indice_syn_label::TEXT = 'Certaine'::TEXT THEN 'Nicheur certain'::TEXT
                ELSE NULL::TEXT
                END                    AS breeding_status
            FROM
                src_historic_atlas.i037_releves rel
                    JOIN atlas.t_historic_atlases_info
                         ON (atlas_period = extract(YEAR FROM rel.date_inf::DATE) || '-' ||
                                            extract(YEAR FROM rel.date_sup::DATE))
                    JOIN src_historic_atlas.i037_especes sp ON sp.cd_releve = rel.cd_releve
                    LEFT JOIN src_historic_atlas.indice_reproduction ir ON ir.var_indnid::INTEGER = sp.var_indnid
                    JOIN ref_geo.l_areas grid ON rel.cd_sig = grid.area_code
                    JOIN taxonomie.taxref ON taxref.cd_nom = sp.cd_nom
                    JOIN atlas.mv_taxa_groups ON sp.cd_nom = mv_taxa_groups.cd_nom
                    JOIN atlas.t_taxa ON t_taxa.cd_nom = mv_taxa_groups.cd_group
            WHERE
                  (t_taxa.enabled)
              AND (rel.date_inf::TEXT = ANY
                   (ARRAY [ '1/1/1970 00:00:00'::CHARACTER VARYING::TEXT , '1/1/1985 00:00:00'::CHARACTER VARYING::TEXT]))
              AND grid.id_type = ref_geo.get_id_area_type('GRPIGN150'::CHARACTER VARYING);


        INSERT INTO
            atlas.t_historic_atlases_data(id_historic_atlas_info, id_area, cd_nom, status)
        SELECT
            t_historic_atlases_info.id
          , id_area
          , cd_nom
          , coalesce(CASE
                         WHEN statut_nidif ILIKE 'nicheur possible'::TEXT THEN 'Nicheur possible'::TEXT
                         WHEN statut_nidif ILIKE 'nicheur probable'::TEXT THEN 'Nicheur probable'::TEXT
                         WHEN statut_nidif ILIKE 'nicheur certain%'::TEXT THEN 'Nicheur certain'::TEXT
                         ELSE NULL::TEXT
                         END, statut_hiver)
            FROM
                tmp.aofm_2009_2012
                    JOIN taxonomie.cor_c_vn_taxref ON vn_id = id_espece_visionature
                    JOIN taxonomie.taxref
                         ON taxref_id = cd_nom
                    JOIN ref_geo.l_areas ON
                    replace(area_code, '10kmL93', '') = code_maille
                    JOIN atlas.t_historic_atlases_info
                         ON ((CASE
                                  WHEN aofm_2009_2012.statut_nidif IS NOT NULL THEN 'breeding'
                                  ELSE 'wintering' END)::PHENOLOGY_PERIOD =
                             t_historic_atlases_info.season_period AND atlas_period LIKE '2009-2012');

        COMMIT;
    END
$$
;