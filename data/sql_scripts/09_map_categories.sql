/*
Map classes to categorize data
------------------------------
TODO: description
 */
DO $$
BEGIN
    /* Vue matérialisée finale */
    DROP MATERIALIZED VIEW IF EXISTS atlas.mv_taxon_count_classes_by_territory;
    CREATE MATERIALIZED VIEW atlas.mv_taxon_count_classes_by_territory AS
    WITH q1 AS (
        SELECT
            la2.id_area AS group_id_area,
            akl.id_area AS id_area,
            akl.allperiod_count_taxa_new AS count_taxa,
            ntile(5) OVER (PARTITION BY la2.id_area ORDER BY akl.allperiod_count_taxa_new) AS ntile
        FROM
            atlas.mv_area_knowledge_level akl
            JOIN ref_geo.l_areas la1 ON la1.id_area = akl.id_area,
            ref_geo.l_areas la2
        WHERE
            la2.id_type = ref_geo.get_id_area_type ('ATLAS_TERRITORY')
            AND st_intersects (la1.geom, la2.geom))
    SELECT
        row_number() OVER () AS id,
        q1.group_id_area AS id_area,
        ntile,
        min(count_taxa) AS min,
        max(count_taxa) AS max
    FROM
        q1
        JOIN ref_geo.l_areas la ON la.id_area = group_id_area
    GROUP BY
        group_id_area,
        la.area_name,
        ntile
    ORDER BY
        group_id_area,
        ntile;
    COMMENT ON MATERIALIZED VIEW atlas.mv_taxon_count_classes_by_territory IS 'Classes based on taxa count, for all period and for each atlas territory';
    COMMIT;
END
$$;

