#!/bin/sh
set -e


CONFIG="${CKAN_CONFIG}/ckan.ini"

abort () {
  echo "$@" >&2
  exit 1
}

echo "Starting RQ Worker"
ckan -c $CONFIG jobs  worker
