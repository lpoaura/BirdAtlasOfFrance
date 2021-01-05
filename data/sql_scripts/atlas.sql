CREATE SCHEMA IF NOT EXISTS atlas
;

DROP MATERIALIZED VIEW IF EXISTS atlas.mv_area_knowledge_level
;

CREATE MATERIALIZED VIEW atlas.mv_area_knowledge_level AS
SELECT
    la.id_area
  , la.area_name
  , la.area_code
  , la.id_type
  , count(DISTINCT s.cd_nom) FILTER (WHERE extract(YEAR FROM s.date_min) BETWEEN 2008 AND 2012) AS count_taxa_old
  , count(DISTINCT s.cd_nom)
    FILTER (WHERE extract(YEAR FROM s.date_min) >= 2020)                                        AS count_taxa_new
  , CASE
        WHEN count(DISTINCT s.cd_nom) FILTER (WHERE extract(YEAR FROM s.date_min) BETWEEN 2008 AND 2012) = 0 THEN 1
        ELSE
            (((count(DISTINCT s.cd_nom) FILTER (WHERE extract(YEAR FROM s.date_min) >= 2020)) /
              (count(DISTINCT s.cd_nom) FILTER (WHERE extract(YEAR FROM s.date_min) BETWEEN 2008 AND 2012))) *
             0.01) END                                                                          AS percent_knowledge
  , st_transform(geom, 4326)                                                                    AS geom
  , st_asgeojson(st_transform(geom, 4326))                                                      AS geojson_geom
    FROM
        ref_geo.l_areas la
            JOIN gn_synthese.cor_area_synthese cas ON cas.id_area = la.id_area
            JOIN gn_synthese.synthese s ON cas.id_synthese = s.id_synthese
            JOIN src_lpodatas.t_c_synthese_extended tcse ON s.id_synthese = tcse.id_synthese
    WHERE
            id_type IN (SELECT id_type FROM ref_geo.bib_areas_types WHERE type_code LIKE 'M10')
      AND   tcse.bird_breed_code BETWEEN 3 AND 19
      AND   cd_nom IN (SELECT DISTINCT
                           cd_nom
                           FROM
                               gn_synthese.synthese
                                   JOIN src_lpodatas.t_c_synthese_extended
                                        ON synthese.id_synthese = t_c_synthese_extended.id_synthese
                           WHERE
                                 tcse.taxo_group LIKE 'Oiseaux'
                             AND synthese.date_min BETWEEN '2008-01-01'::DATE AND '2012-12-31'::DATE)
    GROUP BY
        la.id_area
      , la.area_name
      , la.area_code
      , la.id_type
;
