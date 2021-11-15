WITH
    q1 AS (SELECT
               la2.id_area
             , la2.area_code
             , la2.area_name
             , akl.allperiod_count_taxa_new                          AS count_taxa
             , ntile(5) OVER (ORDER BY akl.allperiod_count_taxa_new) AS ntile
               FROM
                   atlas.mv_area_knowledge_level akl
                       JOIN ref_geo.l_areas la1 ON la1.id_area = akl.id_area
                 , ref_geo.l_areas la2
               WHERE
                     st_intersects(la1.geom, la2.geom)
                 AND ref_geo.get_id_area_type('ATLAS_TERRITORY_SIMPLIFY') = la2.id_type)
SELECT
    id_area
  , area_code
  , area_name
  , ntile
  , count(*)
  , min(count_taxa)
  , max(count_taxa)
    FROM
        q1
    GROUP BY
        id_area
      , area_code
      , area_name
      , ntile
    ORDER BY
        id_area, ntile ASC
;
