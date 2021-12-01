/*
AREA KNOWLEDGE LIST TAXA
------------------------
Evaluate for each area and each season  knowledge level comparing old taxa count with new taxa count

ACTUAL TIME : 24minutes to create, too long...
*/
DO
$$
    BEGIN
        RAISE NOTICE 'INFO: (RE)CREATE MV atlas mv_area_knowledge_list_taxa';

        /* function to retrieve nomenclature value and hierarchy */
        CREATE OR REPLACE FUNCTION ref_nomenclatures.fct_c_nomenclature_value_from_hierarchy(_hierarchy VARCHAR, _type_mnemonique TEXT, _column TEXT)
            RETURNS TEXT AS
        $func$
        DECLARE
            the_value TEXT;
        BEGIN
            EXECUTE format('SELECT  tn.%I  FROM ref_nomenclatures.t_nomenclatures tn ' ||
                           'join ref_nomenclatures.bib_nomenclatures_types bnt on tn.id_type = bnt.id_type ' ||
                           'where bnt.mnemonique like $1 and tn.hierarchy=$2', _column)
                USING _type_mnemonique, _hierarchy INTO the_value;
            RETURN the_value;
        END
        $func$
            LANGUAGE plpgsql;
        CREATE INDEX IF NOT EXISTS i_synthese_datemin_newatlas ON gn_synthese.synthese (date_min DESC NULLS LAST)
            WHERE
                synthese.date_min > '2019-01-31'::DATE;
        CREATE INDEX IF NOT EXISTS i_synthese_datemin_oldatlas ON gn_synthese.synthese (date_min DESC NULLS LAST)
            WHERE
                synthese.date_min <= '2019-01-31'::DATE;
        DROP MATERIALIZED VIEW IF EXISTS atlas.mv_area_knowledge_list_taxa;
        -- some minimum date
        /* Materialized view to list all taxa in area */
        CREATE MATERIALIZED VIEW atlas.mv_area_knowledge_list_taxa AS
        (
        WITH
            atlas_code AS (
                /* Liste des codes nidif VisioNature */
                SELECT
                    cd_nomenclature::INT
                  , hierarchy::INT
                    FROM
                        ref_nomenclatures.t_nomenclatures n
                            JOIN ref_nomenclatures.bib_nomenclatures_types t ON n.id_type = t.id_type
                    WHERE
                        t.mnemonique LIKE 'VN_ATLAS_CODE'
            )
          , names AS (
            SELECT
                t_taxa.cd_nom
              , attr.odf_common_name_fr AS common_name_fr
              , attr.odf_common_name_en AS common_name_en
              , attr.odf_sci_name       AS sci_name
                FROM
                    atlas.t_taxa
                        LEFT JOIN taxonomie.v_bibtaxon_attributs_animalia attr ON attr.cd_ref = t_taxa.cd_nom
        )
          , result AS
                (SELECT
                     data.id_area
                   , mv_taxa_groups.cd_group                                                     AS cd_nom
                   , count(id_data) FILTER (WHERE old_data_all_period)                           AS all_period_count_data_old
                   , count(id_data) FILTER (WHERE new_data_all_period)                           AS all_period_count_data_new
                   , extract(YEAR FROM max(data.date_min))                                       AS all_period_last_obs
                   , count(id_data) FILTER (WHERE new_data_breeding)                             AS breeding_count_data_new
                   , ref_nomenclatures.fct_c_nomenclature_value_from_hierarchy(
                             (max(ac.hierarchy) FILTER (WHERE new_data_breeding))::TEXT, 'VN_ATLAS_CODE',
                             'label_default')                                                    AS breeding_status_new
                   , count(id_data) FILTER (WHERE old_data_breeding)                             AS breeding_count_data_old
                   , extract(YEAR FROM
                             (max(data.date_min) FILTER (WHERE bird_breed_code IS NOT NULL)))    AS breeding_last_obs
                   , ref_nomenclatures.fct_c_nomenclature_value_from_hierarchy(
                             (max(ac.hierarchy) FILTER (WHERE old_data_breeding))::TEXT, 'VN_ATLAS_CODE',
                             'label_default')                                                    AS breeding_status_old
                   , count(id_data) FILTER (WHERE old_data_wintering)                            AS wintering_count_data_old
                   , count(id_data) FILTER (WHERE new_data_wintering)                            AS wintering_count_data_new
                   , extract(YEAR FROM (max(data.date_min)
                                        FILTER (WHERE old_data_breeding OR new_data_wintering))) AS wintering_last_obs
                   , coalesce(array_agg(DISTINCT extract(MONTH FROM data.date_min)::INT
                              ORDER BY extract(MONTH FROM data.date_min)::INT ASC)
                              FILTER (WHERE new_data_all_period ), '{}'::INT[])                  AS phenology
                     FROM
                         atlas.mv_data_for_atlas data
                             JOIN atlas.mv_taxa_groups ON data.cd_nom = mv_taxa_groups.cd_nom
                             JOIN atlas.t_taxa ON t_taxa.cd_nom = mv_taxa_groups.cd_group
                             LEFT JOIN atlas_code ac ON ac.cd_nomenclature = data.bird_breed_code
                     WHERE
                         (t_taxa.available AND t_taxa.enabled)
                     GROUP BY
                         data.id_area, mv_taxa_groups.cd_group)
        SELECT
            result.*
          , common_name_fr
          , common_name_en
          , sci_name
            FROM
                result
                    JOIN names ON names.cd_nom = result.cd_nom)
        WITH NO DATA;
        CREATE UNIQUE INDEX i_area_knowledge_list_taxa_id_area_cd_nom ON atlas.mv_area_knowledge_list_taxa (id_area, cd_nom);
        COMMIT;
    END
$$
;
