#!/bin/bash

# to create database if not exists
# run as current user who must have permission to connect to template1 and create new database
# template1 database should exist by default
# bash cmd source: https://stackoverflow.com/questions/52589849/create-database-if-not-exists-in-postgres
psql -d template1 -tc "SELECT 1 FROM pg_database WHERE datname = 'taxi'" | grep -q 1 || psql -d template1 -c "CREATE DATABASE taxi"

# this is needed to avoid permission error in linux system
# where running COPY FROM file cause issue if postgres server do not have permission to the folder
# even if appropriate permission given
# run the bash script as such user that user has permission to these files
cp -u *.csv /tmp

# run the python script
python3 loader.py
