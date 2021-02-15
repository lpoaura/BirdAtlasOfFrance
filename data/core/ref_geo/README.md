# `ref_geo` datas

This database is configured to be used in WGS84, so geographic data  projected in WGS84 must be imported in `ref_geo` schema.

## Administrative boundaries

source data are downloaded from [IGN France](https://geoservices.ign.fr/documentation/diffusion/telechargement-donnees-libres.html#les-bases-de-donn%C3%A9es-au-format-vectoriel) website:

```bash
# Install p7zip app (IGN compressed file format)
sudo apt update && sudo apt install -y p7zip

# Go to temp directory 
cd /tmp

# Download data (2021-01-15 version)
wget ftp://Admin_Express_ext:Dahnoh0eigheeFok@ftp3.ign.fr/ADMIN-EXPRESS_2-4__SHP__FRA_WM_2021-01-15.7z

# decompress files
p7zip -d ADMIN-EXPRESS_2-4__SHP__FRA_WM_2021-01-15.7z

# Go to decompressed data dir
cd /tmp/ADMIN-EXPRESS_2-4__SHP__FRA_2021-01-15/ADMIN-EXPRESS/1_DONNEES_LIVRAISON_2021-01-15/ADE_2-4_SHP_WGS84G_FRA

# Chargement en base des couches région, département, communes
shp2pgsql -D -s 4326 -i -I -t 2D -c REGION.shp ref_geo.tmp_ade_regions | psql -h localhost -U monuser mabase # régions
shp2pgsql -D -s 4326 -i -I -t 2D -c DEPARTEMENT.shp ref_geo.tmp_ade_departements | psql -h localhost -U monuser mabase # départements
shp2pgsql -D -s 4326 -i -I -t 2D -c COMMUNE.shp ref_geo.tmp_ade_communes | psql -h localhost -U monuser mabase # communes
```

Lancez ensuite le script d'intégration de ces données dans la table `ref_geo.l_areas` et `ref_geo.li_municipalities` avec le script `insert_ade_express.sql`.

## Grids

This atlas use 10x10km (for Metropole and Frebch Guyana) and 5x5km (for little islands) official grids, from  [INPN](https://inpn.mnhn.fr/telechargement/cartes-et-information-geographique/ref/referentiels) website.

`insert_grid.sh` script will download and load data into ref_geo.l_areas under `ATLAS_GRID` type.

```bash
cd data/core/ref_geo
./insert_grid.sh
```


