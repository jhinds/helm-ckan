FROM postgres:13.2

RUN apt-get update && apt-get install -y postgresql-13-postgis-3
RUN apt-get update && apt-get install -y python
RUN apt-get update && apt-get install -y wget

RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py

RUN pip install sqlalchemy psycopg2

ENV POSTGIS_DIR=/usr/share/postgresql/13/contrib/postgis-3

# any .sql or .sh file in /docker-entrypoint-initdb.d/ will run at startup in
# order hence the numbers in front
RUN cp $POSTGIS_DIR/postgis.sql /docker-entrypoint-initdb.d/0_postgis.sql
RUN cp $POSTGIS_DIR/spatial_ref_sys.sql /docker-entrypoint-initdb.d/1_spatial_ref_sys.sql
COPY run_python_script.sh /docker-entrypoint-initdb.d/3_run_python_script.sh
COPY setup_db.py /opt/setup_db.py
