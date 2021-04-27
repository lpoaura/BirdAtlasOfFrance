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
        SELECT DISTINCT
            lower(unaccent(tx.lb_nom || ' ' || tx.nom_vern || ' ' || tx.cd_ref))                          AS search_string
          , tx.cd_ref                                                                                     AS code
          , coalesce(item ->> 'french_name', split_part(tx.nom_vern, ',', 1)) || ' (' || tx.lb_nom || ')' AS name
          , coalesce(item ->> 'french_name', split_part(tx.nom_vern, ',', 1))                             AS common_name_fr
          , coalesce(item ->> 'english_name',
                     split_part(tx.nom_vern_eng, ',', 1))                                                 AS common_name_en
          , tx.lb_nom                                                                                     AS sci_name
          , coalesce(item ->> 'french_name', split_part(tx.nom_vern, ',', 1)) || ' (' || tx.cd_ref || ' - <i>' ||
            tx.lb_nom || '</i>)'                                                                          AS html_repr
            FROM
                atlas.t_taxa taxa
                    JOIN taxonomie.taxref tx ON taxa.cd_nom = tx.cd_nom
                    JOIN taxonomie.cor_c_vn_taxref cvt ON tx.cd_nom = cvt.taxref_id
                    JOIN src_vn_json.species_json ON cvt.vn_id = species_json.id
            WHERE
                taxa.enabled);
        CREATE /*UNIQUE*/ INDEX i_uniq_mv_search_taxa_code ON atlas.mv_search_taxa (code);
        CREATE INDEX i_mv_search_taxa_search_string_trgm ON atlas.mv_search_taxa USING gist (search_string gist_trgm_ops);
        COMMIT;
    END
$$
;
/*
WITH
    tax AS (
        SELECT
            taxref_id               AS cd_nom
          , vn_id                   AS id_visionature
          , item ->> 'french_name'  AS french_name
          , item ->> 'english_name' AS english_name
          , item ->> 'latin_name'   AS latin_name
            FROM
                src_vn_json.species_json
                    JOIN taxonomie.cor_c_vn_taxref ON vn_id = species_json.id
            WHERE
                    taxref_id IN (
                    SELECT code FROM atlas.mv_search_taxa GROUP BY code HAVING count(code) > 1)
            ORDER BY
                latin_name)
SELECT
    tax.*
  , count(*)
    FROM
        tax
      , src_vn_json.observations_json
    WHERE
        tax.id_visionature = cast(item #>> '{species,@id}' AS INT)
    GROUP BY
        tax.id_visionature, tax.cd_nom, tax.english_name, tax.french_name, tax.latin_name
;

SELECT *
    FROM
        src_vn_json.species_json
    WHERE
        item ->> 'french_name' LIKE 'Pigeon biset %';
*/
