/*
TAXA DATAS
-----
Distribution
 */
DO
$$
    BEGIN
        /* Vue matérialisée finale */

        COMMIT;
    END
$$
;

SELECT
    altitude_min
  ,
    FROM
        atlas.mv_data_for_atlas ad
            JOIN gn_synthese.synthese sy ON ad.id_data = sy.id_synthese
;

WITH
    ranges (range) AS (
        SELECT
            int4range(i, i + 250, '[)')
            FROM
                generate_series(0, (SELECT max(altitude_min) FROM gn_synthese.synthese), 250) AS i
    )
SELECT
    range
  , cor_area_synthese.id_area
  , l_areas.area_name
  , sy.cd_nom
  , sy.nom_cite
  , count(sy.altitude_min) AS range_count
    FROM
        ranges l
            LEFT JOIN gn_synthese.synthese sy
                      ON sy.altitude_min <@ l.range
            JOIN atlas.mv_data_for_atlas da ON da.id_data = sy.id_synthese
            JOIN gn_synthese.cor_area_synthese ON sy.id_synthese = cor_area_synthese.id_synthese
            JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
            JOIN ref_geo.bib_areas_types ON l_areas.id_type = bib_areas_types.id_type
    WHERE
          type_code LIKE 'ATLAS_TERRITORY'
      AND new_data_all_period
    GROUP BY
        sy.cd_nom
      , sy.nom_cite
      , cor_area_synthese.id_area
      , l_areas.area_name
      , range
    ORDER BY
        sy.cd_nom
      , sy.nom_cite
      , cor_area_synthese.id_area
      , l_areas.area_name
      , range
;

SELECT
    int4range(i, i + 250, '[)')
    FROM
        generate_series(0, (SELECT max(altitude_min) FROM gn_synthese.synthese WHERE id_source = 24), 250) AS i

;


WITH
    maxalti AS (
        SELECT
            l_areas.id_area
          , max(synthese.altitude_min) AS alti
            FROM
                gn_synthese.synthese
                    JOIN gn_synthese.cor_area_synthese ON synthese.id_synthese = cor_area_synthese.id_synthese
                    JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
            WHERE
                    l_areas.id_type = ref_nomenclatures.get_id_nomenclature_type('ATLAS_TERRITORY')
              AND   l_areas.enable
            GROUP BY l_areas.id_area
    )
  , ranges (range) AS (
    SELECT
        int4range(i, i + (SELECT round(alti, -2) / 20 FROM maxalti)::INT, '[)')
        FROM
            generate_series(0, (SELECT alti FROM maxalti),
                            (SELECT round(alti, -3) / 20 FROM maxalti)::INT) AS i
)
SELECT
    range
  , count(sy.altitude_min) AS range_count
    FROM
        ranges l
            LEFT JOIN gn_synthese.synthese sy
                      ON sy.altitude_min <@ l.range
    WHERE
          id_source = 23
      AND date_min > '2018-12-31'
    GROUP BY
        range
    ORDER BY
        range
;

SELECT
    round(max(altitude_min), -3) / 10
    FROM
        gn_synthese.synthese
;

SELECT
    count(*)
    FROM
        gn_synthese.cor_area_synthese
;

SELECT *
    FROM
        ref_geo.bib_areas_types
;

SELECT *
    FROM
        gn_synthese.cor_area_synthese
            JOIN ref_geo.l_areas ON l_areas.id_area = cor_area_synthese.id_area

--             JOIN gn_synthese.synthese ON cor_area_synthese.id_synthese = synthese.id_synthese
    WHERE
        id_synthese = 10422050
;
