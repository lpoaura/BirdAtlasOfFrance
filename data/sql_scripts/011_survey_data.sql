/*
SURVEY DATAS
-----

Materialized views for survey charts and temporal map data.

Map pipeline:
  src_survey.vm_carto_reg_information_2  -> all survey years per department
  atlas.mv_survey_map_data_2             -> aggregated rows per (dept, year)

Each map data entry is a 4-element array:
  [unite, valeur, survey_year, source]
where source comes from info_detail.info_commentaire.
 */

DO
$$
    BEGIN
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_survey_map_data_2;
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_survey_map_data;
        DROP MATERIALIZED VIEW IF EXISTS src_survey.vm_carto_reg_information_2;

        CREATE MATERIALIZED VIEW src_survey.vm_carto_reg_information_2
        TABLESPACE pg_default
        AS
        WITH representation AS (
            SELECT trv.id_graph,
                   trv.cd_nom,
                   trv.phenologie,
                   trv.id_area_atlas_territory,
                   trv.id_jdd,
                   trv.unite,
                   trv.representation,
                   trv.information_graph,
                   trv.description,
                   trv.type,
                   la_1.geom
            FROM src_survey.t_representation trv
                     LEFT JOIN ref_geo.l_areas la_1
                               ON trv.id_area_atlas_territory = la_1.id_area
        ),
             all_info_detail AS (
                 SELECT ig.id_info_generale,
                        ig.cd_nom,
                        ig.date_debut,
                        ig.date_fin,
                        ig.id_area,
                        ig.source_jdd,
                        id.unite,
                        la_1.geom,
                        max(
                                CASE
                                    WHEN id.type_valeur::text = 'nombre_unique'::text THEN id.valeur
                                    ELSE NULL::double precision
                                    END) AS val,
                        max(
                                CASE
                                    WHEN id.type_valeur::text = 'min'::text THEN id.valeur
                                    ELSE NULL::double precision
                                    END) AS val_min,
                        max(
                                CASE
                                    WHEN id.type_valeur::text = 'max'::text THEN id.valeur
                                    ELSE NULL::double precision
                                    END) AS val_max,
                        array_agg(DISTINCT id.info_commentaire)
                        FILTER (WHERE id.info_commentaire IS NOT NULL
                            AND btrim(id.info_commentaire) <> '') AS sources
                 FROM src_survey.info_generale ig
                          JOIN src_survey.cor_tab_detail ctd
                               ON ig.id_info_generale = ctd.id_info_generale
                          JOIN src_survey.info_detail id
                               ON ctd.id_info_detail = id.id_info_detail
                          JOIN ref_geo.l_areas la_1 ON ig.id_area = la_1.id_area
                 GROUP BY ig.id_info_generale,
                          ig.cd_nom,
                          ig.date_debut,
                          ig.date_fin,
                          ig.id_area,
                          ig.source_jdd,
                          id.unite,
                          la_1.geom
             ),
             carto_rows AS (
                 SELECT aid.cd_nom,
                        aid.unite,
                        r.phenologie,
                        CASE
                            WHEN EXTRACT(YEAR FROM aid.date_debut) = EXTRACT(YEAR FROM aid.date_fin)
                                THEN EXTRACT(YEAR FROM aid.date_fin)::character varying::text
                            ELSE concat(EXTRACT(YEAR FROM aid.date_debut), '-', EXTRACT(YEAR FROM aid.date_fin))
                            END AS survey_year,
                        r.id_area_atlas_territory,
                        la.id_area,
                        aid.val AS value,
                        aid.val_min,
                        aid.val_max,
                        aid.sources
                 FROM all_info_detail aid
                          LEFT JOIN representation r
                                    ON r.cd_nom = aid.cd_nom
                                        AND r.id_jdd = aid.source_jdd
                                        AND r.unite::text = aid.unite::text
                          LEFT JOIN ref_geo.l_areas la ON la.id_area = aid.id_area
                 WHERE r.type = 'carte'::src_survey.type_illustration
                   AND st_intersects(st_centroid(aid.geom), r.geom)
                   AND la.id_type = 26
                   AND (aid.val > 0 OR aid.val_max > 0)
             )
        SELECT cd_nom,
               unite,
               phenologie,
               survey_year,
               id_area_atlas_territory,
               id_area,
               sum(value) AS value,
               min(val_min) AS val_min,
               max(val_max) AS val_max,
               (
                   SELECT array_agg(DISTINCT source_label ORDER BY source_label)
                   FROM (
                            SELECT unnest(inner_row.sources) AS source_label
                            FROM carto_rows inner_row
                            WHERE inner_row.cd_nom = carto_rows.cd_nom
                              AND inner_row.unite = carto_rows.unite
                              AND inner_row.phenologie = carto_rows.phenologie
                              AND inner_row.survey_year = carto_rows.survey_year
                              AND inner_row.id_area_atlas_territory = carto_rows.id_area_atlas_territory
                              AND inner_row.id_area = carto_rows.id_area
                        ) source_rows
                   WHERE source_label IS NOT NULL
                     AND btrim(source_label) <> ''
               ) AS sources
        FROM carto_rows
        GROUP BY cd_nom,
                 unite,
                 phenologie,
                 survey_year,
                 id_area_atlas_territory,
                 id_area
        WITH DATA;

        CREATE INDEX ON src_survey.vm_carto_reg_information_2 (id_area_atlas_territory);
        CREATE INDEX ON src_survey.vm_carto_reg_information_2 (cd_nom);
        CREATE INDEX ON src_survey.vm_carto_reg_information_2 (phenologie);
        CREATE INDEX ON src_survey.vm_carto_reg_information_2 (survey_year);
        CREATE INDEX ON src_survey.vm_carto_reg_information_2 (id_area);

        CREATE MATERIALIZED VIEW atlas.mv_survey_map_data_2
        TABLESPACE pg_default
        AS
        SELECT row_number() OVER () AS id,
               grouped.id_area_atlas_territory,
               grouped.id_area,
               grouped.cd_nom,
               grouped.phenologie AS phenology_period,
               grouped.survey_year,
               (
                   SELECT array_agg(DISTINCT source_label ORDER BY source_label)
                   FROM (
                            SELECT unnest(unit_row.sources) AS source_label
                            FROM src_survey.vm_carto_reg_information_2 unit_row
                            WHERE unit_row.id_area_atlas_territory = grouped.id_area_atlas_territory
                              AND unit_row.id_area = grouped.id_area
                              AND unit_row.cd_nom = grouped.cd_nom
                              AND unit_row.phenologie = grouped.phenologie
                              AND unit_row.survey_year = grouped.survey_year
                        ) source_rows
                   WHERE source_label IS NOT NULL
                     AND btrim(source_label) <> ''
               ) AS sources,
               array_agg(
                       ARRAY [
                           unit_row.unite::character varying,
                           COALESCE(
                                   unit_row.value::character varying,
                                   ((unit_row.val_min::character varying::text || '-'::text) ||
                                    unit_row.val_max::character varying::text)::character varying
                           ),
                           unit_row.survey_year::character varying,
                           COALESCE(array_to_string(unit_row.sources, ' ; '), ''::character varying)
                           ]::character varying[]
               ) AS data
        FROM src_survey.vm_carto_reg_information_2 unit_row
                 JOIN (
            SELECT id_area_atlas_territory,
                   id_area,
                   cd_nom,
                   phenologie,
                   survey_year
            FROM src_survey.vm_carto_reg_information_2
            GROUP BY id_area_atlas_territory,
                     id_area,
                     cd_nom,
                     phenologie,
                     survey_year
        ) grouped
                      ON grouped.id_area_atlas_territory = unit_row.id_area_atlas_territory
                          AND grouped.id_area = unit_row.id_area
                          AND grouped.cd_nom = unit_row.cd_nom
                          AND grouped.phenologie = unit_row.phenologie
                          AND grouped.survey_year = unit_row.survey_year
        GROUP BY grouped.id_area_atlas_territory,
                 grouped.id_area,
                 grouped.cd_nom,
                 grouped.phenologie,
                 grouped.survey_year
        ORDER BY grouped.id_area_atlas_territory,
                 grouped.id_area,
                 grouped.cd_nom,
                 grouped.phenologie,
                 grouped.survey_year
        WITH DATA;

        CREATE INDEX ON atlas.mv_survey_map_data_2 (id_area_atlas_territory);
        CREATE INDEX ON atlas.mv_survey_map_data_2 (cd_nom);
        CREATE INDEX ON atlas.mv_survey_map_data_2 (phenology_period);
        CREATE INDEX ON atlas.mv_survey_map_data_2 (survey_year);
        CREATE INDEX ON atlas.mv_survey_map_data_2 (id_area);
        CREATE INDEX ON atlas.mv_survey_map_data_2 (cd_nom, id_area_atlas_territory, phenology_period, survey_year);


        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_survey_chart_data;
        CREATE MATERIALIZED VIEW atlas.mv_survey_chart_data AS
        (
            SELECT ROW_NUMBER() OVER ()          AS id,
                   id_graph,
                   id_area_atlas_territory,
                   EXTRACT(YEAR FROM date_debut) AS year,
                   cd_nom,
                   phenologie                    AS phenology_period,
                   unite                         AS unit,
                   CASE
                       WHEN unite LIKE 'Tendance'
                           THEN 'trend'
                       ELSE 'pop_size'
                       END                       AS chart_type,
                   JSONB_BUILD_OBJECT('val', val, 'val_min', val_min, 'val_max',
                                      val_max)   AS data
            FROM src_survey.vm_graph_information
            )
        WITH NO DATA;

        CREATE INDEX ON atlas.mv_survey_chart_data (id_area_atlas_territory);
        CREATE INDEX ON atlas.mv_survey_chart_data (cd_nom);
        CREATE INDEX ON atlas.mv_survey_chart_data (phenology_period);
        CREATE INDEX ON atlas.mv_survey_chart_data (chart_type);


        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_survey_chart_descs;
        CREATE MATERIALIZED VIEW atlas.mv_survey_chart_descs AS
        SELECT id_graph   AS id,
               id_area_atlas_territory,
               cd_nom,
               phenologie AS phenology_period,
               CASE
                   WHEN unite LIKE 'Tendance'
                       THEN 'trend'
                   ELSE 'pop_size'
                   END    AS chart_type,
               champ_additionnel -> CASE
                                        WHEN unite LIKE 'Tendance'
                                            THEN 'trend'
                                        ELSE 'pop_size'
                   END    AS data
        FROM src_survey.t_representation;
        CREATE INDEX ON atlas.mv_survey_chart_descs (id_area_atlas_territory);
        CREATE INDEX ON atlas.mv_survey_chart_descs (cd_nom);
        CREATE INDEX ON atlas.mv_survey_chart_descs (phenology_period);
        CREATE INDEX ON atlas.mv_survey_chart_descs (chart_type);

        GRANT SELECT ON src_survey.vm_carto_reg_information_2 TO gnadm, odfapp;
        GRANT SELECT ON atlas.mv_survey_map_data_2 TO gnadm, odfapp;

        COMMIT;
    END
$$;
