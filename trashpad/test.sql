
SELECT ST_AsMVT(mvtgeom.*) 
FROM ( 
 SELECT 
   ST_AsMVTGeom(geom) AS geom, 
   allperiod_percent_knowledge, 
   breeding_percent_knowledge
 FROM atlas.mv_area_knowledge_level
) as mvtgeom;
