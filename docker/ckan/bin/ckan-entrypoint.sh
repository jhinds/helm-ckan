#!/usr/bin/env bash
set -e

abort () {
  echo "$@" >&2
  exit 1
}

# echo "Setting Up Datastore"
ckan datastore set-permissions

echo "Starting CKAN"
uwsgi --ini /etc/ckan/uwsgi.ini
