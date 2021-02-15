BEGIN
;

DO
$$
    DECLARE
        area_type INT;
        line      RECORD;
    BEGIN
        INSERT INTO
            ref_geo.bib_areas_types(type_name, type_code, type_desc, ref_name, ref_version, num_version)
            VALUES
            ('Maille atlas', 'ATLAS_GRID', 'Mailles utilisées pour l''atlas des oiseaux de France', NULL, 2021, 'v0')
        ON CONFLICT(type_code) DO UPDATE SET type_code=excluded.type_code
            RETURNING id_type INTO area_type;
        RAISE NOTICE 'Area type is %', area_type;
        FOR line IN
            SELECT
                schemaname
              , tablename
                FROM
                    pg_catalog.pg_tables
                WHERE
                      schemaname LIKE 'public'
                  AND tablename LIKE 'tmp_grid_%'
            LOOP
                RAISE NOTICE '% / %',
                    line.schemaname,
                    line.tablename;
                EXECUTE format('INSERT INTO ref_geo.l_areas (id_type, area_code, area_name, geom) SELECT $1, cd_sig, cd_sig, geom FROM %I.%I', line.schemaname , line.tablename ) USING area_type;
            END LOOP;
    END;
$$
;

COMMIT
;

--
-- ROLLBACK ;
