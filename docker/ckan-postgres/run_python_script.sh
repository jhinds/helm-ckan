#!/bin/bash

python /opt/ckan_db_setup.py -w 'password' -r 'password' -d postgresql://postgres@localhost:5432 -c default

# Rerun for ckan database
psql -f /docker-entrypoint-initdb.d/0_postgis.sql -d ckan_default
psql -f /docker-entrypoint-initdb.d/1_spatial_ref_sys.sql -d ckan_default
