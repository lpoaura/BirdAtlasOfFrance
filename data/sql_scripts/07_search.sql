/*
SEARCH
------
optimized searches materialized views to look for taxa and areas
 */
DO
$$
    BEGIN
        RAISE NOTICE 'INFO: (RE)CREATE MV atlas mv_search_areas and mv_search_taxa';

        /* TODO, sélectionner les areas à utiliser dans l_areas avec le champ booléen enabled).*/
        /* Vue matérialisée recherche de zonage */
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_search_areas;
        CREATE MATERIALIZED VIEW atlas.mv_search_areas AS
        SELECT
            l_areas.id_area                                                                            AS id
          , bib_areas_types.type_name                                                                  AS type_name
          , bib_areas_types.type_code                                                                  AS type_code
          , lower(unaccent(l_areas.area_name || ' ' || area_code))                                     AS search_string
          , l_areas.area_code                                                                          AS code
          , l_areas.area_name                                                                          AS name
          , l_areas.area_name || ' (' || l_areas.area_code || ')'                                      AS html_repr
          , json_build_array(json_build_array(st_y(st_endpoint(st_boundingdiagonal(st_transform(l_areas.geom, 4326)))),
                                              st_x(st_endpoint(st_boundingdiagonal(st_transform(l_areas.geom, 4326))))),
                             json_build_array(
                                     st_y(st_startpoint(st_boundingdiagonal(st_transform(l_areas.geom, 4326)))), st_x(
                                     st_startpoint(
                                             st_boundingdiagonal(st_transform(l_areas.geom, 4326)))))) AS bounds
            FROM
                ref_geo.l_areas
                    JOIN ref_geo.bib_areas_types ON l_areas.id_type = bib_areas_types.id_type --             JOIN gn_synthese.cor_area_synthese ON l_areas.id_area = cor_area_synthese.id_area
            WHERE
                  bib_areas_types.type_code IN ('ATLAS_GRID', 'COM')
              AND l_areas.enable;
        CREATE UNIQUE INDEX i_uniq_mv_search_areas_id ON atlas.mv_search_areas (id);
        CREATE INDEX i_mv_search_areas_type_code ON atlas.mv_search_areas (type_code);
        CREATE INDEX i_mv_search_areas_code ON atlas.mv_search_areas (code);
        CREATE INDEX i_mv_search_areas_search_trgm ON atlas.mv_search_areas USING gist (search_string gist_trgm_ops);

        /* Vue matérialisée recherche de espèce */
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_search_taxa;
        CREATE MATERIALIZED VIEW atlas.mv_search_taxa AS
        (
        WITH
            attributes AS (SELECT
                               cd_ref
                             , max(CASE
                                       WHEN (bib_attributs.nom_attribut = 'odf_sci_name')
                                           THEN cor_taxon_attribut.valeur_attribut
                                       ELSE NULL END) AS sci_name
                             , max(CASE
                                       WHEN (bib_attributs.nom_attribut = 'odf_common_name_fr')
                                           THEN cor_taxon_attribut.valeur_attribut
                                       ELSE NULL END) AS common_name_fr
                             , max(CASE
                                       WHEN (bib_attributs.nom_attribut = 'odf_common_name_en')
                                           THEN cor_taxon_attribut.valeur_attribut
                                       ELSE NULL END) AS common_name_en
                               FROM
                                   taxonomie.cor_taxon_attribut
                                       JOIN taxonomie.bib_attributs
                                            ON cor_taxon_attribut.id_attribut = bib_attributs.id_attribut
                               GROUP BY cd_ref
                               ORDER BY cd_ref)
        SELECT DISTINCT
            lower(unaccent(attributes.sci_name || ' ' || attributes.common_name_en || ' ' ||
                           attributes.common_name_fr || ' ' || attributes.cd_ref)) AS search_string
          , attributes.cd_ref                                                      AS code
          , attributes.common_name_fr || ' (' || attributes.sci_name || ')'        AS name
          , attributes.common_name_fr                                              AS common_name_fr
          , attributes.common_name_en                                              AS common_name_en
          , attributes.sci_name                                                    AS sci_name
          , attributes.common_name_fr || ' (' || attributes.cd_ref || ' - <i>' ||
            attributes.sci_name || '</i>)'                                         AS html_repr
            FROM
                atlas.t_taxa taxa
                    --                     JOIN taxonomie.taxref tx ON taxa.cd_nom = tx.cd_nom
--                     JOIN taxonomie.cor_c_vn_taxref cvt ON tx.cd_nom = cvt.taxref_id
--                     JOIN src_vn_json.species_json ON cvt.vn_id = species_json.id
                    JOIN attributes ON taxa.cd_nom = attributes.cd_ref
            WHERE
                taxa.enabled);
        CREATE /*UNIQUE*/ INDEX i_uniq_mv_search_taxa_code ON atlas.mv_search_taxa (code);
        CREATE INDEX i_mv_search_taxa_search_string_trgm ON atlas.mv_search_taxa USING gist (search_string gist_trgm_ops);
        COMMIT;
    END
$$
;
