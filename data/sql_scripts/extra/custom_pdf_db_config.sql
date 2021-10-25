CREATE TABLESPACE indexes_space LOCATION '/opt/postgresql/pg_index'
;


GRANT ALL PRIVILEGES ON TABLESPACE indexes_space TO gnadm
;

-- ALTER INDEX [ IF EXISTS ] name SET TABLESPACE tablespace_name

DO
$moveindexes$
    DECLARE
        app_index RECORD;
    BEGIN
        FOR app_index IN (
            SELECT DISTINCT
                schemaname
              , tablename
              , indexname
              , indexdef
                FROM
                    pg_indexes
                WHERE
                    (schemaname NOT IN ('pg_catalog', 'topology', 'public')
                        AND tablespace IS NULL)
                ORDER BY
                    tablename, indexname)
            LOOP
                RAISE NOTICE 'PREPARE TO MOVE INDEX: %.%', app_index.schemaname, app_index.indexname;
                RAISE NOTICE '%', ('ALTER INDEX IF EXISTS ' || app_index.schemaname || '.' || app_index.indexname ||
                                   ' SET TABLESPACE indexes_space');
                EXECUTE 'ALTER INDEX IF EXISTS ' || app_index.schemaname || '.' || app_index.indexname ||
                        ' SET TABLESPACE indexes_space';
            END LOOP;
    END
;
$moveindexes$
;

SELECT DISTINCT
    schemaname
    FROM
        pg_indexes
    WHERE
        (schemaname NOT IN ('pg_catalog', 'topology')
            AND tablespace IS NULL)

    ORDER BY
        schemaname