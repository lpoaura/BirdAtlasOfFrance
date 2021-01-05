CREATE SCHEMA IF NOT EXISTS atlas
;

DROP MATERIALIZED VIEW IF EXISTS atlas.mv_area_knowledge_level
;

CREATE MATERIALIZED VIEW atlas.mv_area_knowledge_level AS
WITH
    area_type AS (SELECT id_type FROM ref_geo.bib_areas_types WHERE type_code = 'M10')
  , old_data AS (SELECT DISTINCT
                     l_areas.id_area
                   , cd_nom
                     FROM
                         gn_synthese.synthese
                             JOIN src_lpodatas.t_c_synthese_extended tcse
                                  ON synthese.id_synthese = tcse.id_synthese
                             JOIN gn_synthese.cor_area_synthese ON synthese.id_synthese = cor_area_synthese.id_synthese
                             JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
                     WHERE
                           tcse.taxo_group LIKE 'Oiseaux'
                       AND tcse.bird_breed_code BETWEEN 3 AND 19
                       AND synthese.date_min BETWEEN '2008-01-01'::DATE AND '2012-12-31'::DATE
                       AND id_type IN (SELECT id_type FROM area_type)
)
  , new_data AS (SELECT DISTINCT
                     l_areas.id_area
                   , cd_nom
                     FROM
                         gn_synthese.synthese
                             JOIN src_lpodatas.t_c_synthese_extended tcse
                                  ON synthese.id_synthese = tcse.id_synthese
                             JOIN gn_synthese.cor_area_synthese ON synthese.id_synthese = cor_area_synthese.id_synthese
                             JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
                     WHERE
                           tcse.taxo_group LIKE 'Oiseaux'
                       AND tcse.bird_breed_code BETWEEN 3 AND 19
                       AND synthese.date_min > '2019-12-31'::DATE
                       AND id_type IN (SELECT id_type FROM area_type))
SELECT
    la.id_area
  , la.area_name
  , la.area_code
  , la.id_type
  , count(DISTINCT old_data.cd_nom)                                                       AS count_taxa_old
  , count(DISTINCT new_data.cd_nom)                                                       AS count_taxa_new
  , CASE
        WHEN count(DISTINCT old_data.cd_nom) = 0
            THEN 1
        ELSE
            (count(DISTINCT new_data.cd_nom)::REAL / count(DISTINCT old_data.cd_nom)) END AS percent_knowledge
  , st_transform(geom, 4326)                                                              AS geom
  , st_asgeojson(st_transform(geom, 4326))                                                AS geojson_geom
    FROM
        ref_geo.l_areas la
            LEFT JOIN old_data ON old_data.id_area = la.id_area
            LEFT JOIN new_data ON new_data.id_area = la.id_area
    WHERE
        id_type IN (SELECT id_type FROM area_type)
    GROUP BY
        la.id_area
      , la.area_name
      , la.area_code
      , la.id_type

;

COMMENT ON MATERIALIZED VIEW atlas.mv_area_knowledge_level IS 'Synthèse de l''état des prospection par mailles comparativement à l''atlas précédent'
;

CREATE INDEX i_area_knowledge_level_geom ON atlas.mv_area_knowledge_level USING gist (geom)
;

CREATE INDEX i_area_knowledge_level_area_code ON atlas.mv_area_knowledge_level (area_code)
;

CREATE INDEX i_area_knowledge_level_area_name ON atlas.mv_area_knowledge_level (area_name)
;

CREATE INDEX i_area_knowledge_level_area_id_type ON atlas.mv_area_knowledge_level (id_type)
;

