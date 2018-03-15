#!/usr/bin/env python

import argparse
import os
import sys
import logging
from copy import deepcopy

import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.engine.url import make_url

LOGGING_FORMAT = '%(levelname)s:%(asctime)s:%(module)s:%(funcName)s:%(lineno)d	%(message)s'
logging.basicConfig(stream=sys.stdout, level=logging.INFO, format=LOGGING_FORMAT)
logger = logging.getLogger("ckan.db.initializer")


class CkanDbInitializer(object):
    """
    This class helps to setup initial databases, users, and extensions inside postgres
    that will be needed for a CKAN deployment.

    Attributes:
        database_url (str): The connection string of the main database instance
        read_password (string): The password that will be set for the read user
        write_password (string): The password that will be set for the write user
        main_db_engine (sqlalchemy.engine.base.Engine): The main database engine to connect to initially
        ckan_db_engine (sqlalchemy.engine.base.Engine): The ckan database engine to configure
        datastore_db_engine (sqlalchemy.engine.base.Engine): The datastore database engine to configure
        xloader_db_engine (sqlalchemy.engine.base.Engine): The xloader database engine to configure
    """

    def __init__(self, database_url=None, read_password='', write_password=''):
        self.database_url = database_url if database_url else os.getenv('DATABASE_URL')
        self.read_password = read_password
        self.write_password = write_password
        self.main_db_engine = create_engine(self.database_url)
        self.ckan_db_engine = None
        self.datastore_db_engine = None
        self.xloader_db_engine = None

    def create_databases(self):
        """
        This function creates the ckan proper databases
            1. ckan
            2. datastore
            3. xloader_jobs
        Returns:
            (tuple) databases created (ckan_db, datastore_db, xloader_db)
        """

        ckan_db = "ckan"
        datastore_db = "datastore"
        xloader_db = "xloader_jobs"

        conn = self.main_db_engine.connect()

        self._ignore_already_created_resource_error(self._create_database, conn, ckan_db)
        self._ignore_already_created_resource_error(self._create_database, conn, datastore_db)
        self._ignore_already_created_resource_error(self._create_database, conn, xloader_db)

        main_db_url = make_url(self.database_url)
        ckan_db_copy = deepcopy(main_db_url)
        datastore_db_copy = deepcopy(main_db_url)
        xloader_db_copy = deepcopy(main_db_url)

        ckan_db_copy.database = ckan_db
        self.ckan_db_engine = create_engine(ckan_db_copy)

        datastore_db_copy.database = datastore_db
        self.datastore_db_engine = create_engine(datastore_db_copy)

        xloader_db_copy.database = xloader_db
        self.xloader_db_engine = create_engine(xloader_db_copy)

        conn.close()
        return ckan_db, datastore_db, xloader_db

    def create_users(self):
        """
        This functions creates the necessary users needed by ckan within postgres.
            1. ckan_user
            2. datastore_user
        Returns:
            (tuple) users created (ckan_write_user, datastore_read_user)
        """

        datastore_read_user = "datastore_user"
        ckan_write_user = "ckan_user"

        conn = self.main_db_engine.connect()

        self._ignore_already_created_resource_error(self._create_user, conn, datastore_read_user, self.read_password)
        self._ignore_already_created_resource_error(self._create_user, conn, ckan_write_user, self.write_password)

        conn.close()

        return ckan_write_user, datastore_read_user

    def populate_full_text_trigger(self, ckan_write_user):
        """
        This function creates populate_full_text_trigger which is needed for
        CKAN versions less than 2.8.
        See https://github.com/davidread/ckanext-xloader#installation step 4.
        And https://github.com/davidread/ckanext-xloader/blob/master/full_text_function.sql

        Args:
            ckan_write_user (string): The main ckan write user to assign function to.
        """

        sql= """
             CREATE OR REPLACE FUNCTION populate_full_text_trigger() RETURNS trigger
             AS $body$
                 BEGIN
                     IF NEW._full_text IS NOT NULL THEN
                         RETURN NEW;
                     END IF;
                     NEW._full_text := (
                         SELECT to_tsvector(string_agg(value, ' '))
                         FROM json_each_text(row_to_json(NEW.*))
                         WHERE key NOT LIKE '\_%');
                     RETURN NEW;
                 END;
             $body$ LANGUAGE plpgsql;
             ALTER FUNCTION populate_full_text_trigger() OWNER TO {ckan_write_user};
             """.format(ckan_write_user=ckan_write_user)

        conn = self.ckan_db_engine.connect()
        conn.execute(sqlalchemy.text(sql))
        conn.close()
        logger.info("Created function populate_full_text_trigger in CKAN DB")

        conn = self.datastore_db_engine.connect()
        conn.execute(sqlalchemy.text(sql))
        conn.close()
        logger.info("Created function populate_full_text_trigger in DataStore DB")

        conn = self.xloader_db_engine.connect()
        conn.execute(sqlalchemy.text(sql))
        conn.close()
        logger.info("Created function populate_full_text_trigger in Xloader DB")

    @staticmethod
    def _ignore_already_created_resource_error(func, *args):
        """
        This function will ignore the error sqlalchemy.exc.ProgrammingError when
        raised in a function to prevent a thrown error and breaking the program
        when an already created resource exists in postgres such as a user or database.
        Args:
            func (function): The function to call
            args: The arguments
        Returns:
            result: The result, if any
        """
        result = None
        try:
            result = func(*args)
        except sqlalchemy.exc.ProgrammingError:
            logger.info("{func_name} did not run successfully, probably because the resource is already created".format(func_name=func.__name__))
            # do nothing if getting an error because a resource is already created is already created
            pass
        return result

    @staticmethod
    def _create_user(conn, user, password):
        """
        This function creates a new postgres user
        Args:
            conn: The sql alchemy connection object
            user: The user to create
            password: The password for the user being created
        """
        conn.execute("CREATE USER {user} WITH PASSWORD '{password}'"
                     .format(user=user, password=password))
        logger.info("Created user {}".format(user))

    @staticmethod
    def _create_database(conn, database):
        """
        This function creates a new postgres database
        Args:
            conn: The sql alchemy connection object
            user: The database to create
        """
        conn.execute("commit")
        conn.execute("create database {db}".format(db=database))
        logger.info("Created datatbase {db}".format(db=database))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Initialize ckan database', add_help=True)

    parser.add_argument('--database-url','-d',
                        type=str,
                        required=True,
                        help='The connection string to connect to the main database instance\nShould be in the format:\n'
                             'postgresql://{user}:{pass}@{host}:{5432}/{database}')

    parser.add_argument('--write-pass','-w',
                        type=str,
                        required=True,
                        help='The write for the read user to create')

    parser.add_argument('--read-pass','-r',
                        type=str,
                        required=True,
                        help='The password for the read user to create')

    parser.add_argument('--customer','-c',
                        type=str,
                        required=True,
                        help='The customer to create resources for')

    parser.add_argument('--rds',
                        action='store_true',
                        default=False,
                        help='Flag for if this datatbase is an AWS RDS instance')

    args = parser.parse_args()

    ckan_db = CkanDbInitializer(database_url=args.database_url,
                                write_password=args.write_pass,
                                read_password=args.read_pass,
                                is_rds=args.rds)

    ckan_write_user, _ = ckan_db.create_users()
    ckan_db.create_databases()
    ckan_db.populate_full_text_trigger(ckan_write_user)
