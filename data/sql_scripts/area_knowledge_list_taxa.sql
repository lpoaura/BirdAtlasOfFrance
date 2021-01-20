DO $$
BEGIN
  /* Vue matérialisée finale */
  RAISE NOTICE 'INFO: (RE)CREATE MV atlas mv_area_knowledge_list_taxa';
  CREATE OR REPLACE FUNCTION ref_nomenclatures.fct_c_nomenclature_value_from_hierarchy (_hierarchy varchar, _type_mnemonique text, _column text )
    RETURNS text AS $func$
DECLARE
  the_value text;
BEGIN
  EXECUTE format('SELECT  tn.%I  INTO %I FROM ref_nomenclatures.t_nomenclatures tn ' || 'join ref_nomenclatures.bib_nomenclatures_types bnt on tn.id_type = bnt.id_type ' || 'where bnt.mnemonique like $1 and tn.hierarchy=$2', _column, the_value)
  USING _type_mnemonique,
  _hierarchy;
  RETURN the_value;
END $func$
LANGUAGE plpgsql;
  SELECT
    ref_nomenclatures.fct_c_nomenclature_value_from_hierarchy ('51', 'VN_ATLAS_CODE', 'label_default');
  DROP MATERIALIZED VIEW IF EXISTS atlas.mv_area_knowledge_list_taxa;
  CREATE MATERIALIZED VIEW atlas.mv_area_knowledge_list_taxa AS
  WITH atlas_code AS (
    SELECT
      cd_nomenclature::int,
      hierarchy::int
    FROM
      ref_nomenclatures.t_nomenclatures n
      JOIN ref_nomenclatures.bib_nomenclatures_types t ON n.id_type = t.id_type
    WHERE
      t.mnemonique LIKE 'VN_ATLAS_CODE'
),
areas AS (
  SELECT
    l_areas.id_area
  FROM
    ref_geo.l_areas
  WHERE
    id_type = (
      SELECT
        id_type
      FROM
        ref_geo.bib_areas_types
      WHERE
        type_code = 'M10'
      LIMIT 1)
),
areas_taxa AS (
  SELECT
    areas.id_area,
    synthese.cd_nom
  FROM
    areas
    JOIN gn_synthese.cor_area_synthese ON areas.id_area = cor_area_synthese.id_area
    JOIN gn_synthese.synthese ON cor_area_synthese.id_synthese = synthese.id_synthese
    JOIN src_lpodatas.t_c_synthese_extended tcse ON synthese.id_synthese = tcse.id_synthese
  WHERE
    tcse.taxo_group LIKE 'Oiseaux'
  LIMIT 10
),
new_data_allperiod AS (
  SELECT DISTINCT
    areas_taxa.id_area,
    areas_taxa.cd_nom,
    count(synthese.id_synthese) AS count_data,
  max(extract(YEAR FROM date_min)) AS last_obs
FROM
  gn_synthese.synthese
  JOIN src_lpodatas.t_c_synthese_extended tcse ON synthese.id_synthese = tcse.id_synthese
  JOIN gn_synthese.cor_area_synthese ON synthese.id_synthese = cor_area_synthese.id_synthese
  JOIN areas_taxa ON cor_area_synthese.id_area = areas_taxa.id_area
    AND synthese.cd_nom = areas_taxa.cd_nom
  WHERE
    synthese.date_min > '2019-01-31'::date
  GROUP BY
    areas_taxa.id_area,
    areas_taxa.cd_nom
),
old_data_allperiod AS (
  SELECT DISTINCT
    areas_taxa.id_area,
    areas_taxa.cd_nom,
    count(synthese.id_synthese) AS count_data,
    max(extract(YEAR FROM date_min)) AS last_obs
FROM
  gn_synthese.synthese
  JOIN src_lpodatas.t_c_synthese_extended tcse ON synthese.id_synthese = tcse.id_synthese
  JOIN gn_synthese.cor_area_synthese ON synthese.id_synthese = cor_area_synthese.id_synthese
  JOIN areas_taxa ON cor_area_synthese.id_area = areas_taxa.id_area
    AND synthese.cd_nom = areas_taxa.cd_nom
  WHERE
    synthese.date_min < '2019-01-31'::date
  GROUP BY
    areas_taxa.id_area,
    areas_taxa.cd_nom
),
old_data_wintering AS (
  SELECT DISTINCT
    areas_taxa.id_area,
    areas_taxa.cd_nom,
    count(synthese.id_synthese) AS count_data,
  max(extract(YEAR FROM date_min)) AS last_obs
FROM
  gn_synthese.synthese
  JOIN src_lpodatas.t_c_synthese_extended tcse ON synthese.id_synthese = tcse.id_synthese
  JOIN gn_synthese.cor_area_synthese ON synthese.id_synthese = cor_area_synthese.id_synthese
  JOIN areas_taxa ON cor_area_synthese.id_area = areas_taxa.id_area
    AND synthese.cd_nom = areas_taxa.cd_nom
  WHERE
    tcse.bird_breed_code IS NULL
    AND extract(MONTH FROM synthese.date_min) IN (12, 1)
    AND synthese.date_min < '2019-01-31'
  GROUP BY
    areas_taxa.id_area,
    areas_taxa.cd_nom
),
new_data_wintering AS (
  SELECT DISTINCT
    areas_taxa.id_area,
    areas_taxa.cd_nom,
    count(synthese.id_synthese) AS count_data,
    max(extract(YEAR FROM date_min)) AS last_obs
  FROM
    gn_synthese.synthese
    JOIN src_lpodatas.t_c_synthese_extended tcse ON synthese.id_synthese = tcse.id_synthese
    JOIN gn_synthese.cor_area_synthese ON synthese.id_synthese = cor_area_synthese.id_synthese
    JOIN areas_taxa ON cor_area_synthese.id_area = areas_taxa.id_area
      AND synthese.cd_nom = areas_taxa.cd_nom
  WHERE
    tcse.bird_breed_code IS NULL
    AND extract(MONTH FROM synthese.date_min) IN (12, 1)
    AND synthese.date_min > '2019-11-30'
  GROUP BY
    areas_taxa.id_area,
    areas_taxa.cd_nom
),
old_data_breeding AS (
  SELECT DISTINCT
    areas_taxa.id_area,
    areas_taxa.cd_nom,
    count(synthese.id_synthese) AS count_data,
    max(extract(YEAR FROM date_min)) AS last_obs,
    ref_nomenclatures.fct_c_nomenclature_value_from_hierarchy ((max(ac.hierarchy))::text, 'VN_ATLAS_CODE', 'label_default') AS breeding_status
  FROM
    gn_synthese.synthese
    JOIN src_lpodatas.t_c_synthese_extended tcse ON synthese.id_synthese = tcse.id_synthese
    JOIN gn_synthese.cor_area_synthese ON synthese.id_synthese = cor_area_synthese.id_synthese
    JOIN atlas_code ac ON ac.cd_nomenclature = tcse.bird_breed_code
    JOIN areas_taxa ON cor_area_synthese.id_area = areas_taxa.id_area
      AND synthese.cd_nom = areas_taxa.cd_nom
  WHERE
    tcse.taxo_group LIKE 'Oiseaux'
    AND tcse.bird_breed_code BETWEEN 2 AND 50
    AND synthese.date_min < '2019-01-01'
  GROUP BY
    areas_taxa.id_area,
    areas_taxa.cd_nom
),
new_data_breeding AS (
  SELECT DISTINCT
    areas_taxa.id_area,
    areas_taxa.cd_nom,
    count(synthese.id_synthese) AS count_data,
    max(extract(YEAR FROM date_min)) AS last_obs,
    ref_nomenclatures.fct_c_nomenclature_value_from_hierarchy ((max(ac.hierarchy))::text, 'VN_ATLAS_CODE', 'label_default') AS breeding_status
  FROM
    gn_synthese.synthese
    JOIN src_lpodatas.t_c_synthese_extended tcse ON synthese.id_synthese = tcse.id_synthese
    JOIN gn_synthese.cor_area_synthese ON synthese.id_synthese = cor_area_synthese.id_synthese
    JOIN atlas_code ac ON ac.cd_nomenclature = tcse.bird_breed_code
    JOIN areas_taxa ON cor_area_synthese.id_area = areas_taxa.id_area
      AND synthese.cd_nom = areas_taxa.cd_nom
  WHERE
    tcse.taxo_group LIKE 'Oiseaux'
    AND tcse.bird_breed_code BETWEEN 2 AND 50
    AND synthese.date_min > '2018-12-31'::date
  GROUP BY
    areas_taxa.id_area,
    areas_taxa.cd_nom
)
SELECT
  areas_taxa.id_area,
  areas_taxa.cd_nom,
  taxref.lb_nom AS sci_name,
  split_part(nom_vern, ',', 1) AS common_name,
  old_data_allperiod.count_data AS all_period_count_data_old,
  new_data_allperiod.count_data AS all_period_count_data_new,
  coalesce(new_data_allperiod.last_obs, coalesce(old_data_allperiod.last_obs, NULL)) AS all_periode_last_obs,
  new_data_breeding.count_data AS breeding_count_data_new,
  new_data_breeding.breeding_status AS breeding_status_new,
  old_data_breeding.count_data AS breeding_count_data_old,
  coalesce(new_data_breeding.last_obs, coalesce(old_data_breeding.last_obs, NULL)) AS breeding_last_obs,
  old_data_breeding.breeding_status AS breeding_status_old,
  old_data_wintering.count_data AS wintering_count_data_old,
  new_data_wintering.count_data AS wintering_count_data_new,
  coalesce(new_data_wintering.last_obs, coalesce(old_data_wintering.last_obs, NULL)) AS wintering_last_obs
FROM
  areas_taxa
  JOIN taxonomie.taxref ON areas_taxa.cd_nom = taxref.cd_nom
  LEFT JOIN old_data_allperiod ON old_data_allperiod.id_area = areas_taxa.id_area
    AND areas_taxa.cd_nom = old_data_allperiod.cd_nom
  LEFT JOIN new_data_allperiod ON new_data_allperiod.id_area = areas_taxa.id_area
    AND areas_taxa.cd_nom = new_data_allperiod.cd_nom
  LEFT JOIN old_data_breeding ON old_data_breeding.id_area = areas_taxa.id_area
    AND areas_taxa.cd_nom = old_data_breeding.cd_nom
  LEFT JOIN new_data_breeding ON new_data_breeding.id_area = areas_taxa.id_area
    AND areas_taxa.cd_nom = new_data_breeding.cd_nom
  LEFT JOIN new_data_wintering ON new_data_wintering.id_area = areas_taxa.id_area
    AND areas_taxa.cd_nom = new_data_wintering.cd_nom
  LEFT JOIN old_data_wintering ON old_data_wintering.id_area = areas_taxa.id_area
    AND areas_taxa.cd_nom = old_data_wintering.cd_nom;
  COMMENT ON MATERIALIZED VIEW atlas.mv_area_knowledge_list_taxa IS 'Synthèse de l''état des prospection par mailles comparativement à l''atlas précédent';
  CREATE UNIQUE INDEX i_area_knowledge_list_taxa_id_area_cd_nom ON atlas.mv_area_knowledge_list_taxa (id_area, cd_nom);
COMMIT;
END
$$;

