#!/bin/bash

TEMP=$(getopt -o h --long source-host:,source-login:,source-password:,source-port:,source-database:,source-table:,dest-host:,dest-login:,dest-password:,dest-port:,dest-database:,dump-options:,restore-options:,help \
              -n 'dump.sh' -- "$@")
eval set -- "$TEMP"

while true; do
    case "$1" in
        --dump-options )
            DUMP_OPTIONS="$2"; shift 2;;
        --restore-options )
            RESTORE_OPTIONS="$2"; shift 2;;
        --source-host )
            SOURCE_HOST="$2"; shift 2;;
        --source-login )
            SOURCE_LOGIN="$2"; shift 2;;
        --source-password )
            SOURCE_PASSWORD="$2"; shift 2;;
        --source-port )
            SOURCE_PORT="$2"; shift 2;;
        --source-database )
            SOURCE_DATABASE="$2"; shift 2;;
        --source-table )
            SOURCE_TABLE="$2"; shift 2;;            
        --dest-host )
            DESTINATION_HOST="$2"; shift 2;;
        --dest-login )
            DESTINATION_LOGIN="$2"; shift 2;;
        --dest-password )
            DESTINATION_PASSWORD="$2"; shift 2;;
        --dest-port )
            DESTINATION_PORT="$2"; shift 2;;
        --dest-database )
            DESTINATION_DATABASE="$2"; shift 2;;
        -h | --help )
            echo "$HELP_STRING"; exit 0 ;;
        -- )
            shift; break ;;
        * )
            break ;;
    esac
done

if [[ -z $SOURCE_HOST || -z $SOURCE_LOGIN || -z $SOURCE_PASSWORD || -z $SOURCE_PORT || -z $SOURCE_DATABASE \
   || -z $DESTINATION_HOST || -z $DESTINATION_LOGIN || -z $DESTINATION_PASSWORD || -z $DESTINATION_PORT || -z $DESTINATION_DATABASE ]]; then
  echo 'Not every required variable is defined.'
  exit 1
fi

if [ -z "$1" ]
then
    echo 'Please, specify RDBMS to dump. Currently, MySQL and PostgreSQL are supported.'
    exit 1
elif [ "$1" == "mysql" ]
then
    mysqldump $DUMP_OPTIONS -p"$SOURCE_PASSWORD" -h "$SOURCE_HOST" -u "$SOURCE_LOGIN" -P "$SOURCE_PORT" "$SOURCE_DATABASE" $SOURCE_TABLE | \
    mysql $RESTORE_OPTIONS -p"$DESTINATION_PASSWORD" -h "$DESTINATION_HOST" -u "$DESTINATION_LOGIN"  -P "$DESTINATION_PORT" "$DESTINATION_DATABASE"
elif [ "$1" == "postgresql" ]
then
    if ! [ -z "$SOURCE_TABLE" ]; then 
        for table in "SOURCE_TABLE"; do
            TABLE_ARRAY+=("-t")
            TABLE_ARRAY+=("$table")
        done;
    fi
    (PGPASSWORD="$SOURCE_PASSWORD" \
    pg_dump $DUMP_OPTIONS -h "$SOURCE_HOST" -U "$SOURCE_LOGIN" -p "$SOURCE_PORT" "$SOURCE_DATABASE" "${TABLE_ARRAY[@]/#/-}") | \
    (PGPASSWORD="$DESTINATION_PASSWORD" \
    psql $RESTORE_OPTIONS -h "$DESTINATION_HOST" -U "$DESTINATION_LOGIN"  -p "$DESTINATION_PORT" "$DESTINATION_DATABASE")
else
    echo 'Unsupported RDBMS. Currently, MySQL and PostgreSQL are supported.'
    exit 1
fi
