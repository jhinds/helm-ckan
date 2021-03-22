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
paster --plugin=ckan db init -c $CONFIG

{
  echo "Initializing CKAN Extractor"
  paster --plugin=ckanext-extractor init -c "$CONFIG"
} || {
  echo "CKAN Extractor already initialized"
}

echo "Setting Up Datastore"
paster --plugin=ckan datastore set-permissions -c $CONFIG

echo "Starting CKAN"
paster serve $CONFIG
