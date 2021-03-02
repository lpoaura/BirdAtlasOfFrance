/*********************REF_GEO*****************
 * SQL script to insert IGN ADMIN EXPRESS    *
 * data into ref_geo GeoNature tables        *
 *********************************************/

/* Update ref_geo.bib_areas_types */

INSERT INTO
    ref_geo.bib_areas_types (type_name, type_code, type_desc, ref_name, ref_version, num_version)
    VALUES
    ('Régions', 'REG', 'Type région', 'IGN ADMIN-EXPRESS', 2021, '2021-01-15')
;

UPDATE ref_geo.bib_areas_types
SET
    (ref_name, ref_version, num_version)= ('IGN ADMIN-EXPRESS', 2021, '2021-01-15')
    WHERE
        type_code IN ('COM', 'DEP')
;

/* Insert municipalities */

CREATE UNIQUE INDEX IF NOT EXISTS i_unique_l_areas_id_type_area_code ON ref_geo.l_areas (id_type, area_code)
;

INSERT INTO
    ref_geo.l_areas ( id_type
                    , area_name
                    , area_code
                    , geom
                    , centroid
                    , geojson_4326
                    , source
                    , comment
                    , enable
                    , additional_data
                    , meta_create_date
                    , meta_update_date)
SELECT
    t.id_type
  , a.nom_com
  , a.insee_com
  , a.geom
  , st_centroid(a.geom)
  , st_asgeojson(a.geom)
  , 'IGN ADMIN-EXPRESS'
  , NULL
  , TRUE AS enable
  , NULL
  , now()
  , now()
    FROM
        ref_geo.tmp_ade_communes a
      , ref_geo.bib_areas_types t
    WHERE
        type_code LIKE 'COM'
;

INSERT INTO
    ref_geo.li_municipalities ( id_municipality
                              , id_area
                              , status
                              , insee_com
                              , nom_com
                              , insee_arr
                              , insee_dep
                              , insee_reg
                              , population
                              , meta_create_date
                              , meta_update_date)

SELECT
    insee_com
  , id_area
  , statut
  , insee_com
  , nom_com
  , insee_arr
  , insee_dep
  , insee_reg
  , population
  , now()
  , now()
    FROM
        ref_geo.l_areas
            JOIN ref_geo.tmp_ade_communes ON insee_com = area_code
;

INSERT INTO
    ref_geo.l_areas ( id_type
                    , area_name
                    , area_code
                    , geom
                    , centroid
                    , geojson_4326
                    , source
                    , comment
                    , enable
                    , additional_data
                    , meta_create_date
                    , meta_update_date)
SELECT
    t.id_type
  , a.nom_dep
  , a.insee_dep
  , a.geom
  , st_centroid(a.geom)
  , st_asgeojson(a.geom)
  , 'IGN ADMIN-EXPRESS'
  , NULL
  , TRUE AS enable
  , NULL
  , now()
  , now()
    FROM
        ref_geo.tmp_ade_departements a
      , ref_geo.bib_areas_types t
    WHERE
        type_code LIKE 'DEP'
;


INSERT INTO
    ref_geo.l_areas ( id_type
                    , area_name
                    , area_code
                    , geom
                    , centroid
                    , geojson_4326
                    , source
                    , comment
                    , enable
                    , additional_data
                    , meta_create_date
                    , meta_update_date)
SELECT
    t.id_type
  , a.nom_reg
  , a.insee_reg
  , a.geom
  , st_centroid(a.geom)
  , st_asgeojson(a.geom)
  , 'IGN ADMIN-EXPRESS'
  , NULL
  , TRUE AS enable
  , NULL
  , now()
  , now()
    FROM
        ref_geo.tmp_ade_regions a
      , ref_geo.bib_areas_types t
    WHERE
        type_code LIKE 'REG'
;

