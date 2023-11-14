/*
TITLE
-----
Description
 */


CREATE OR REPLACE VIEW atlas.mat_view_dependencies AS
WITH RECURSIVE s(start_schemaname, start_relname, start_relkind,
                 schemaname, relname, relkind, reloid, depth)
                   AS (
-- List of tables and views that mat views depend on
        SELECT n.nspname  AS start_schemaname,
               c.relname  AS start_relname,
               c.relkind  AS start_relkind,
               n2.nspname AS schemaname,
               c2.relname,
               c2.relkind,
               c2.oid     AS reloid,
               0          AS depth
        FROM pg_class c
                 JOIN pg_namespace n
                      ON c.relnamespace = n.oid AND c.relkind IN ('r', 'm', 'v', 't', 'f', 'p')
                 JOIN pg_depend d ON c.oid = d.refobjid
                 JOIN pg_rewrite r ON d.objid = r.oid
                 JOIN pg_class c2 ON r.ev_class = c2.oid -- AND c2.relkind='m'
                 JOIN pg_namespace n2 ON n2.oid = c2.relnamespace

        UNION

-- Recursively find all mat views depending on previous level
        SELECT s.start_schemaname,
               s.start_relname,
               s.start_relkind,
               n.nspname   AS schemaname,
               c2.relname,
               c2.relkind,
               c2.oid,
               s.depth + 1 AS depth
        FROM s
                 JOIN pg_depend d ON s.reloid = d.refobjid
                 JOIN pg_rewrite r ON d.objid = r.oid
                 JOIN pg_class c2 ON r.ev_class = c2.oid AND (c2.relkind IN ('m', 'v'))
                 JOIN pg_namespace n ON n.oid = c2.relnamespace

        WHERE s.reloid <> c2.oid -- exclude the current MV which always depends on itself
    )
SELECT *
FROM s;

--------------------------------------------------
--- A view that returns the list of mat views in the
--- order they should be refreshed.
--------------------------------------------------
CREATE OR REPLACE VIEW atlas.mat_view_refresh_order AS
WITH b AS (
-- Select the highest depth of each mat view name
    SELECT DISTINCT ON (schemaname,relname) schemaname, relname, depth
    FROM mat_view_dependencies
    WHERE relkind = 'm'
    ORDER BY schemaname, relname, depth DESC)
-- Reorder appropriately
SELECT schemaname, relname, depth AS refresh_order
FROM b
ORDER BY depth, schemaname, relname
;


SELECT *
FROM atlas.mat_view_refresh_order
WHERE schemaname LIKE 'atlas';


DO
$$
    DECLARE
        start_ts TIMESTAMP;
        delta    INTERVAL;
        r record;
    BEGIN
        /* Vue matérialisée finale */

        RAISE INFO 'INFO: Refreshing Atlas materialized views';
        SELECT CLOCK_TIMESTAMP() INTO start_ts;
        RAISE INFO '-- % -- START SCRIPT', start_ts;
        FOR r IN SELECT schemaname, relname FROM atlas.mat_view_refresh_order WHERE schemaname LIKE 'atlas'
            LOOP
                RAISE INFO '-- % -- START REFRESH %s.%s', CLOCK_TIMESTAMP(), r.schemaname, r.relname;
                EXECUTE 'REFRESH MATERIALIZED VIEW ' || r.schemaname || '.' || r.relname;
                SELECT (CLOCK_TIMESTAMP() - start_ts) INTO delta;
                RAISE INFO '-- % -- INTERVAL FROM START SCRIPT', delta;
            END LOOP;
        COMMIT;
    END
$$
;

GRANT SELECT ON ALL TABLES IN SCHEMA atlas TO odfapp, gnadm
;