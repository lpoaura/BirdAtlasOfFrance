/*
INIT ATLAS DB
-------------
Require to be executed on installed GeoNature DB
*/

DO
$$
    DECLARE
        geonature_status boolean;
    BEGIN
        RAISE NOTICE 'INFO: INIT atlas requirements on existing PostgreSQL DB';

        PERFORM 1 from gn_commons.t_modules limit 1;

        /* Create dedicated db schema */
        CREATE SCHEMA IF NOT EXISTS atlas;

        /* Create table to list excluded taxa */
        CREATE TABLE IF NOT EXISTS atlas.t_excluded_taxa
        (
            cd_nom INT REFERENCES taxonomie.taxref (cd_nom)
        );

                /* Create table to list excluded taxa */
        CREATE TABLE IF NOT EXISTS atlas.t_taxa
        (
            id_taxa serial PRIMARY KEY ,
            cd_nom INT REFERENCES taxonomie.taxref (cd_nom),
            common_name varchar,
            sci_name varchar,
            include integer[]
        );

        /* Commit changes */
        COMMIT;
    END
$$
;

