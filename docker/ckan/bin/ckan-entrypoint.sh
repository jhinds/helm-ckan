#!/bin/sh
set -e

# URL for solr (required unless linked to a container called 'solr')
: ${CKAN_SOLR_URL:=}
# URL for redis (required unless linked to a container called 'redis')
: ${CKAN_REDIS_URL:=}

CONFIG="${CKAN_CONFIG}/ckan.ini"

abort () {
  echo "$@" >&2
  exit 1
}

if [ -z "$CKAN_SOLR_URL" ]; then
    abort "ERROR: no CKAN_SOLR_URL has been set"
fi

if [ -z "$CKAN_REDIS_URL" ]; then
    abort "ERROR: no CKAN_REDIS_URL has been set"
fi

echo "Initializng CKAN DB"
ckan -c $CONFIG db init

{
  echo "Initializing CKAN Extractor"
  ckan -c $CONFIG --plugin=ckanext-extractor init
} || {
  echo "CKAN Extractor already initialized"
}

echo "Setting Up Datastore"
ckan -c $CONFIG datastore set-permissions

echo "Starting CKAN"
ckan -c $CONFIG serve
