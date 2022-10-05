/*
Previous atlas datas table
--------------------------
...
*/

DO
$$
    BEGIN
        CREATE TABLE src_historic_atlas.aofm_2009_2012
        (
            code_maille           VARCHAR,
            id_espece_visionature INTEGER,
            nom_commun            VARCHAR,
            nom_sci               VARCHAR,
            categorie_abondance   VARCHAR,
            classe_abondance      INT,
            indice_nidif          INTEGER,
            statut_nidif          VARCHAR,
            statut_hiver          VARCHAR,
            source                VARCHAR,
            id_dataset            INTEGER,
            id_source             INTEGER
        );

        COMMIT;
    END
$$
;