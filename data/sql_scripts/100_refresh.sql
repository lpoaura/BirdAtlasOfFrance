/*
Refresh MV
-----
Refresh materialized functions
 */

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



