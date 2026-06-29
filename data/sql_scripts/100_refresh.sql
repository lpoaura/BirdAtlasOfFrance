/*
Refresh MV
-----
Refresh materialized functions

- refresh_materialized_view_data()    : version historique (job nocturne actuel)
- refresh_materialized_view_data_2() : version complète avec toutes les MV aval
  (voir data/atlas_bdd.md pour le détail des dépendances)
 */

-- =============================================================================
-- Version historique
-- =============================================================================

CREATE OR REPLACE FUNCTION atlas.refresh_materialized_view_data()
    RETURNS VOID AS
$$
DECLARE
    start_ts TIMESTAMP;
    delta    INTERVAL;
BEGIN
    RAISE INFO 'INFO: Refreshing Atlas materialized views';
    SELECT clock_timestamp() INTO start_ts;
    RAISE INFO '-- % -- START SCRIPT', start_ts;
    RAISE INFO '-- % -- START REFRESH atlas.mv_taxa_groups', clock_timestamp();
    SELECT (clock_timestamp() - start_ts) INTO delta;
    RAISE INFO '-- % -- INTERVAL FROM START SCRIPT', delta;
    RAISE INFO '-- % -- START REFRESH atlas.mv_data_for_atlas', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_data_for_atlas;
    RAISE INFO '-- % -- INTERVAL FROM START SCRIPT', delta;
    RAISE INFO '-- % -- START REFRESH atlas.mv_forms_for_atlas', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_forms_for_atlas;
    RAISE INFO '-- % -- START REFRESH atlas.mv_taxa_groups', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_taxa_groups;
    RAISE INFO '-- % -- START SCRIPT', start_ts;
    RAISE INFO '-- % -- START REFRESH atlas.mv_search_taxa', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_search_taxa;
    RAISE INFO '-- % -- START SCRIPT', start_ts;
    RAISE INFO '-- % -- START REFRESH atlas.mv_search_areas', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_search_areas;
    SELECT (clock_timestamp() - start_ts) INTO delta;
    RAISE INFO '-- % -- INTERVAL FROM START SCRIPT', delta;
    RAISE INFO '-- % -- START REFRESH atlas.mv_area_knowledge_level', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_area_knowledge_level;
    SELECT (clock_timestamp() - start_ts) INTO delta;
    RAISE INFO '-- % -- INTERVAL FROM START SCRIPT', delta;
    RAISE INFO '-- % -- START REFRESH atlas.mv_area_knowledge_list_taxa', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_area_knowledge_list_taxa;
    SELECT (clock_timestamp() - start_ts) INTO delta;
    RAISE INFO '-- % -- INTERVAL FROM START SCRIPT', delta;
    RAISE INFO '-- % -- START REFRESH atlas.mv_area_dashboard', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_area_dashboard;
    SELECT (clock_timestamp() - start_ts) INTO delta;
    REFRESH MATERIALIZED VIEW atlas.mv_general_stats;
    RAISE INFO '-- % -- INTERVAL FROM START SCRIPT', delta;
    RAISE INFO '-- % -- END SCRIPT', clock_timestamp();
    REFRESH MATERIALIZED VIEW atlas.mv_taxon_count_classes_by_territory;
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_realized_epoc;
END
$$ LANGUAGE plpgsql
;


-- =============================================================================
-- Version complète (ordre basé sur le graphe de dépendances)
-- =============================================================================
--
-- MV volontairement exclues (données stables ou cycle de mise à jour distinct) :
--   mv_grid_territories_matching, mv_alti_territory, mv_historic_atlases_data_new,
--   mv_taxa_profiles, mv_taxa_infos_cd_nom, mv_survey_*
--
-- Pour activer REFRESH CONCURRENTLY sur mv_forms_for_atlas, mv_general_stats
-- et mv_taxon_count_classes_by_territory :
--   CREATE UNIQUE INDEX IF NOT EXISTS i_unique_forms_for_atlas_idforms
--       ON atlas.mv_forms_for_atlas (id_form_universal);
--   CREATE UNIQUE INDEX IF NOT EXISTS i_general_stats_id
--       ON atlas.mv_general_stats (id);
--   CREATE UNIQUE INDEX IF NOT EXISTS i_taxon_count_classes_id
--       ON atlas.mv_taxon_count_classes_by_territory (id);

CREATE OR REPLACE FUNCTION atlas.refresh_materialized_view_data_2()
    RETURNS VOID AS
$$
DECLARE
    start_ts TIMESTAMP;
    delta    INTERVAL;
BEGIN
    RAISE INFO 'INFO: Refreshing Atlas materialized views (v2)';
    SELECT clock_timestamp() INTO start_ts;

    -- Niveau 0 : regroupement taxonomique (prérequis de mv_data_for_atlas)
    RAISE INFO '-- % -- REFRESH atlas.mv_taxa_groups', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_taxa_groups;

    -- Niveau 1 : données brutes atlas (mises à jour chaque nuit)
    RAISE INFO '-- % -- REFRESH atlas.mv_data_for_atlas', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_data_for_atlas;

    RAISE INFO '-- % -- REFRESH atlas.mv_forms_for_atlas', clock_timestamp();
    -- Pas de CONCURRENTLY : index UNIQUE commenté dans 001_data_for_atlas.sql
    REFRESH MATERIALIZED VIEW atlas.mv_forms_for_atlas;

    -- Niveau 2 : index de recherche
    RAISE INFO '-- % -- REFRESH atlas.mv_search_taxa', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_search_taxa;

    RAISE INFO '-- % -- REFRESH atlas.mv_search_areas', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_search_areas;

    -- Niveau 3 : connaissance, dashboard, EPOC
    RAISE INFO '-- % -- REFRESH atlas.mv_area_knowledge_level', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_area_knowledge_level;

    RAISE INFO '-- % -- REFRESH atlas.mv_area_knowledge_list_taxa', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_area_knowledge_list_taxa;

    RAISE INFO '-- % -- REFRESH atlas.mv_area_dashboard', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_area_dashboard;

    RAISE INFO '-- % -- REFRESH atlas.mv_realized_epoc', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_realized_epoc;

    -- Niveau 4 : fiches espèce (dépendent de mv_data_for_atlas)
    RAISE INFO '-- % -- REFRESH atlas.mv_territory_altitude_ranges', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_territory_altitude_ranges;

    RAISE INFO '-- % -- REFRESH atlas.mv_taxa_territory_distribution', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_taxa_territory_distribution;

    RAISE INFO '-- % -- REFRESH atlas.mv_taxa_allperiod_phenology', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_taxa_allperiod_phenology;

    RAISE INFO '-- % -- REFRESH atlas.mv_taxa_breeding_phenology', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_taxa_breeding_phenology;

    -- Niveau 5 : altimétrie espèce (dépend de mv_territory_altitude_ranges)
    RAISE INFO '-- % -- REFRESH atlas.mv_alti_distribution', clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_alti_distribution;

    -- Niveau 6 : agrégats finaux
    RAISE INFO '-- % -- REFRESH atlas.mv_taxon_count_classes_by_territory', clock_timestamp();
    -- Pas de CONCURRENTLY : pas d'index UNIQUE dans 009_map_categories.sql
    REFRESH MATERIALIZED VIEW atlas.mv_taxon_count_classes_by_territory;

    RAISE INFO '-- % -- REFRESH atlas.mv_general_stats', clock_timestamp();
    -- Pas de CONCURRENTLY : pas d'index UNIQUE dans 004_general_stats.sql
    REFRESH MATERIALIZED VIEW atlas.mv_general_stats;

    SELECT (clock_timestamp() - start_ts) INTO delta;
    RAISE INFO '-- % -- END SCRIPT v2 (duration: %)', clock_timestamp(), delta;
END
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION atlas.refresh_materialized_view_data() TO gnadm, odfapp;
GRANT EXECUTE ON FUNCTION atlas.refresh_materialized_view_data_2() TO gnadm, odfapp;

GRANT SELECT ON ALL TABLES IN SCHEMA atlas TO gnadm, odfapp;
