FROM postgres:9.6.6

RUN apt-get update && apt-get install -y postgresql-9.6-postgis-2.4
RUN apt-get update && apt-get install -y python
RUN apt-get update && apt-get install -y wget

RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py

RUN pip install sqlalchemy psycopg2

ENV POSTGIS_DIR=/usr/share/postgresql/9.6/contrib/postgis-2.4

# any .sql or .sh file in /docker-entrypoint-initdb.d/ will run at startup in
# order hence the numbers in front
RUN cp $POSTGIS_DIR/postgis.sql /docker-entrypoint-initdb.d/0_postgis.sql
RUN cp $POSTGIS_DIR/spatial_ref_sys.sql /docker-entrypoint-initdb.d/1_spatial_ref_sys.sql
COPY resources/core/docker/ckan-postgres/run_python_script.sh /docker-entrypoint-initdb.d/3_run_python_script.sh
COPY bin/ckan_db_setup.py /opt/ckan_db_setup.py
