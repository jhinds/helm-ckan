#!/bin/sh
set -e

CONFIG="${CKAN_CONFIG}/ckan.ini"

abort () {
  echo "$@" >&2
  exit 1
}

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
uwsgi --ini /etc/ckan/uwsgi.ini 
