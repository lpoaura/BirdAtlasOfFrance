#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]:-$0}")
cd $DIR

. ../../backend/.env

export PGPASSWORD=${POSTGRES_PASSWORD}

init_db() {
    psql -X -h "${POSTGRES_HOST:-localhost}" -p ${POSTGRES_PORT:-5432} -U"${POSTGRES_USER}" -d "${POSTGRES_DB}" -f $1
}

echo "~~~~~~~~ init.sql ~~~~~~~~"
init_db init.sql
echo ""
echo "~~~~~~~~ search.sql ~~~~~~~~"
#init_db search.sql
echo ""
