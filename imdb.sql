-- fill in your user, port and host for psql 
-- like psql -h localhost -p 5432 -U skent -d postgres
-- when in the psql shell run \i imdb.sql
SET client_encoding TO 'UTF8';

CREATE DATABASE imdb;

\c imdb

\i create_tables_insert_data_imdb.sql
\i new_schema_and_constraints.sql