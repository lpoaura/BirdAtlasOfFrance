#!/bin/bash
set -e

while getopts d:s:f: option; do
    case "${option}" in
    d) TMPDIR=${OPTARG} ;;
    s) SRID=${OPTARG} ;;
    f) FILENAME=${OPTARG} ;;
    esac
done

FILENAME=${FILENAME:-"grids.txt"}
TMPDIR=${TMPDIR:-"/tmp/inpn_grids"}
DSRID=${SRID:-4326}

LIST=$(cat $FILENAME)

loaddata() {
    echo ""
    echo "-------------------"
    echo "${1}"
    echo "-------------------"
    echo ""
    IFS=":"
    read -a data <<<${1}
    file=${data[0]}
    ssrid=${data[1]}
    workdir=${TMPDIR}/${file}
    mkdir -p ${workdir}
    cd ${workdir}
    filename=${file%%.*}
    table_name="tmp_grid_${filename,,}"
    echo "Download ${file} from INPN with EPSG ${ssrid}"
    wget -nc -c https://inpn.mnhn.fr/docs/Shape/${file}.zip
    echo "Unzip"
    unzip -o ${file}.zip
    shapefilename=$(ls *.shp)
    echo "prepare to load ${shapefilename} as table ${table_name} with SRID ${ssrid}"
    shp2pgsql -s ${ssrid}:${DSRID} -dDI -g geom ${shapefilename} ${table_name} | psql service=geonature
    echo "Data ${shapefilename} loaded"
    echo ""
    cd ..
    rm -rf ${workdir}
    unset IFS
}

for line in $LIST; do
    echo "line ${line}"
    loaddata ${line}
done
