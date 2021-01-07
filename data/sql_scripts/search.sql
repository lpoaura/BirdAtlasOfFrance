DO $$
BEGIN
    /* Vue matérialisée finale */
    DROP MATERIALIZED VIEW IF EXISTS atlas.mv_autocomplete_search;
    CREATE MATERIALIZED VIEW atlas.mv_autocomplete_search AS (
        WITH first_step AS (
            SELECT DISTINCT
                bib_areas_types.type_name AS type_name,
                bib_areas_types.type_code AS type_code,
                lower(unaccent (l_areas.area_name || ' ' || area_code)) AS search_string,
                l_areas.area_code AS code,
                l_areas.area_name AS name,
                l_areas.area_name || ' (' || l_areas.area_code || ')' AS html_repr
            FROM
                ref_geo.bib_areas_types
            LEFT OUTER JOIN ref_geo.l_areas ON l_areas.id_type = ref_geo.bib_areas_types.id_type
        NATURAL JOIN gn_synthese.cor_area_synthese
    WHERE
        cor_area_synthese.id_area IS NOT NULL
        AND type_code IN ('M10', 'COM')
    UNION
    SELECT DISTINCT
        'Espèce' AS type_name,
        'ESP' AS type_code,
        lower(unaccent (tx.lb_nom || ' ' || tx.nom_vern || ' ' || tx.cd_ref)) AS search_string,
        tx.cd_ref::varchar AS code,
        split_part(tx.nom_vern, ',', 1) || ' (' || tx.lb_nom || ')' AS name,
        split_part(tx.nom_vern, ',', 1) || ' (' || tx.cd_ref || ' - <i>' || tx.lb_nom || '</i>)' AS html_repr
    FROM
        taxonomie.taxref tx
        JOIN ( SELECT DISTINCT
                cd_ref
            FROM
                taxonomie.taxref
                JOIN gn_synthese.synthese ON taxref.cd_nom = synthese.cd_nom
            WHERE
                group2_inpn LIKE 'Oiseaux'
                AND taxref.id_rang LIKE 'ES') t ON tx.cd_nom = t.cd_ref
)
        SELECT
            row_number() OVER () AS id,
            first_step.*
        FROM
            first_step);
    CREATE INDEX i_uniq_search_id ON atlas.mv_autocomplete_search (id);
    CREATE INDEX i_search_type_code ON atlas.mv_autocomplete_search (type_code);
    CREATE INDEX i_search_code ON atlas.mv_autocomplete_search (code);
    CREATE INDEX i_search_search_trgm ON atlas.mv_autocomplete_search USING gist (search_string gist_trgm_ops);
    COMMIT;
END
$$;

