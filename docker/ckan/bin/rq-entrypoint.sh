#!/usr/bin/env bash
set -e

echo "Starting RQ Worker"
ckan jobs  worker
