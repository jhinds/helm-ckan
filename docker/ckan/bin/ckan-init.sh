#!/usr/bin/env bash
set -e

abort () {
  echo "$@" >&2
  exit 1
}

echo "Initializng CKAN DB"
ckan db init

{
  echo "Initializing CKAN Extractor"
  ckan -c $CONFIG --plugin=ckanext-extractor init
} || {
  echo "CKAN Extractor already initialized"
}
