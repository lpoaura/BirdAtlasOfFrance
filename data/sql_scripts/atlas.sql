CREATE SCHEMA IF NOT EXISTS atlas
;

DROP MATERIALIZED VIEW IF EXISTS atlas.mv_area_knowledge_level
;

CREATE MATERIALIZED VIEW atlas.mv_area_knowledge_level AS
WITH
    area_type AS (SELECT id_type FROM ref_geo.bib_areas_types WHERE type_code = 'M10')
    ,  new_data AS (SELECT DISTINCT
                              l_areas.id_area
                            , cd_nom
                              FROM
                                  gn_synthese.synthese
                                      JOIN src_lpodatas.t_c_synthese_extended tcse
                                           ON synthese.id_synthese = tcse.id_synthese
                                      JOIN gn_synthese.cor_area_synthese
                                           ON synthese.id_synthese = cor_area_synthese.id_synthese
                                      JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
                              WHERE
                                    tcse.taxo_group LIKE 'Oiseaux'
                                AND synthese.date_min > '2018-12-31'::DATE
                                AND id_type IN (SELECT id_type FROM area_type))
                                  ,  old_data AS (SELECT DISTINCT
                              l_areas.id_area
                            , cd_nom
                              FROM
                                  gn_synthese.synthese
                                      JOIN src_lpodatas.t_c_synthese_extended tcse
                                           ON synthese.id_synthese = tcse.id_synthese
                                      JOIN gn_synthese.cor_area_synthese
                                           ON synthese.id_synthese = cor_area_synthese.id_synthese
                                      JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
                              WHERE
                                    tcse.taxo_group LIKE 'Oiseaux'
                                AND synthese.date_min < '2019-01-01'::DATE
                                AND id_type IN (SELECT id_type FROM area_type))
  , old_data_wintering AS (SELECT DISTINCT
                               l_areas.id_area
                             , cd_nom
                               FROM
                                   gn_synthese.synthese
                                       JOIN src_lpodatas.t_c_synthese_extended tcse
                                            ON synthese.id_synthese = tcse.id_synthese
                                       JOIN gn_synthese.cor_area_synthese
                                            ON synthese.id_synthese = cor_area_synthese.id_synthese
                                       JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
                               WHERE
                                     tcse.taxo_group LIKE 'Oiseaux'
                                 AND tcse.bird_breed_code IS NULL
                                 AND extract(MONTH FROM synthese.date_min) IN (12, 1)
                                 AND synthese.date_min < '2019-01-31'
                                 AND id_type IN (SELECT id_type FROM area_type)
)
  , new_data_wintering AS (SELECT DISTINCT
                               l_areas.id_area
                             , cd_nom
                               FROM
                                   gn_synthese.synthese
                                       JOIN src_lpodatas.t_c_synthese_extended tcse
                                            ON synthese.id_synthese = tcse.id_synthese
                                       JOIN gn_synthese.cor_area_synthese
                                            ON synthese.id_synthese = cor_area_synthese.id_synthese
                                       JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
                               WHERE
                                     tcse.taxo_group LIKE 'Oiseaux'
                                 AND tcse.bird_breed_code IS NULL
                                 AND extract(MONTH FROM synthese.date_min) IN (12, 1)
                                 AND synthese.date_min > '2019-11-30'
                                 AND id_type IN (SELECT id_type FROM area_type)
)
  , old_data_breeding AS (SELECT DISTINCT
                              l_areas.id_area
                            , cd_nom
                              FROM
                                  gn_synthese.synthese
                                      JOIN src_lpodatas.t_c_synthese_extended tcse
                                           ON synthese.id_synthese = tcse.id_synthese
                                      JOIN gn_synthese.cor_area_synthese
                                           ON synthese.id_synthese = cor_area_synthese.id_synthese
                                      JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
                              WHERE
                                    tcse.taxo_group LIKE 'Oiseaux'
                                AND tcse.bird_breed_code BETWEEN 2 AND 50
                                AND synthese.date_min < '2019-01-01'
                                AND id_type IN (SELECT id_type FROM area_type)
)
  , new_data_breeding AS (SELECT DISTINCT
                              l_areas.id_area
                            , cd_nom
                              FROM
                                  gn_synthese.synthese
                                      JOIN src_lpodatas.t_c_synthese_extended tcse
                                           ON synthese.id_synthese = tcse.id_synthese
                                      JOIN gn_synthese.cor_area_synthese
                                           ON synthese.id_synthese = cor_area_synthese.id_synthese
                                      JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
                              WHERE
                                    tcse.taxo_group LIKE 'Oiseaux'
                                AND tcse.bird_breed_code BETWEEN 2 AND 50
                                AND synthese.date_min > '2018-12-31'::DATE
                                AND id_type IN (SELECT id_type FROM area_type))
SELECT
    la.id_area
  , la.area_name
  , la.area_code
  , la.id_type
  , count(DISTINCT old_data_breeding.cd_nom)                AS allperiod_count_taxa_old
  , count(DISTINCT new_data_breeding.cd_nom)                AS allperiod_count_taxa_new
  , CASE
        WHEN count(DISTINCT old_data_breeding.cd_nom) = 0
            THEN 1
        ELSE
            (count(DISTINCT new_data_breeding.cd_nom)::REAL /
             count(DISTINCT old_data_breeding.cd_nom)) END  AS allperiod_percent_knowledge
  , count(DISTINCT old_data_breeding.cd_nom)                AS breeding_count_taxa_old
  , count(DISTINCT new_data_breeding.cd_nom)                AS breeding_count_taxa_new
  , CASE
        WHEN count(DISTINCT old_data_breeding.cd_nom) = 0
            THEN 1
        ELSE
            (count(DISTINCT new_data_breeding.cd_nom)::REAL /
             count(DISTINCT old_data_breeding.cd_nom)) END  AS breeding_percent_knowledge
  , count(DISTINCT old_data_wintering.cd_nom)                AS wintering_count_taxa_old
  , count(DISTINCT new_data_wintering.cd_nom)               AS wintering_count_taxa_new
  , CASE
        WHEN count(DISTINCT old_data_wintering.cd_nom) = 0
            THEN 1
        ELSE
            (count(DISTINCT new_data_wintering.cd_nom)::REAL /
             count(DISTINCT old_data_wintering.cd_nom)) END AS wintering_percent_knowledge
  , st_asgeojson(st_transform(geom, 4326))                  AS geojson_geom
    FROM
        ref_geo.l_areas la
            LEFT JOIN old_data ON old_data.id_area = la.id_area
            LEFT JOIN new_data ON new_data.id_area = la.id_area
            LEFT JOIN old_data_breeding ON old_data_breeding.id_area = la.id_area
            LEFT JOIN new_data_breeding ON new_data_breeding.id_area = la.id_area
            LEFT JOIN new_data_wintering ON new_data_wintering.id_area = la.id_area
            LEFT JOIN old_data_wintering ON old_data_wintering.id_area = la.id_area
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

