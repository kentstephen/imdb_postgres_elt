# Get IMDB Data, Put Into PostgreSQL, Recreate the Schema
## Data Source: https://developer.imdb.com/non-commercial-datasets/



![ERD of Project](https://github.com/kentstephen/imdb_postgres_elt/blob/main/diagrams/imdb_schema.png)

## If you would like to run this code I highly reccomend you use [imdb_postgres_elt_python](https://github.com/kentstephen/imdb_postgres_elt_python), it is the same SQL packaged in Python for ease of use.

## I grew up on IMDB

I have a lot of affection for the site and this non-commercial dataset is a great way to practice SQL. Once I got the data in Postgres, I realized I had to make some changes to make it usable.

## Get the IMDB Data

Run [import_imdb_tsvs.py](https://github.com/kentstephen/imdb_postgres_elt/blob/main/import_imdb_tsvs.py), you will need to install the requests library.

That will download and extract the 7 TSV files (roughly 6GB of data), and then create a new directory called tsvs_from_imdb. 
It will also save the file path to the TSVs so when you run [insert_file_path.py](https://github.com/kentstephen/imdb_postgres_elt/blob/main/insert_file_paths.py), the correct file path will be inserted into the first .sql file [create_tables_and_insert_data_imdb.sql](https://github.com/kentstephen/imdb_postgres_elt/blob/main/create_tables_insert_data_imdb.sql).

### If you don't want to use the Python scripts

All you need to run the .sql files is to download and extract the 7 .gz files from the source, and then copy the correct path where you see {{user_provided_directory}} in the COPY FROM lines in [create_tables_and_insert_data_imdb.sql](https://github.com/kentstephen/imdb_postgres_elt/blob/main/create_tables_insert_data_imdb.sql).

## Once you have the data

You need to ```CREATE DATABASE imdb;``` to run the .sql files you set your connection in your IDE to imdb.public and run [create_tables_and_insert_data_imdb.sql](https://github.com/kentstephen/imdb_postgres_elt/blob/main/create_tables_insert_data_imdb.sql), this will create the schema and then copy the TSVs into the respective tables. 

--One note anpit where you are copying from. Postgres can be picky about filepaths for COPY FROM statements. I use Windows and this works from my C drive (my Postgres installation is also in my C drive). I plan rework this script with psql syntax using \copy which should be more tolerant--

At this point there are no relations between the entities, because: 

1. There are values in children tables that are not in the two tables that should have Primary Keys (title_basics and name_basics).

2. Some of tables utilize arrays, which will make querying the data very difficult. If all you want is the data in tables, you can stop here, but the next file will offer my solution.

## Add tables and constraints

1. I wanted to make this more query friendly, one of the things I do in [new_schema_and_constraints.sql](https://github.com/kentstephen/imdb_postgres_elt/blob/main/new_schema_and_constraints.sql) is insert all of the unique tconst and nconst values that are in the five children tables but not in title_basics or name_basics into those tables along with the string 'ANOMALY' in the next column, for future detective work. 

2. Now that the parent tables(name_basics and title_basics) have all the IDs from the children tables, this file creates primary keys for the those parent tables and foreign keys for all of the other tables: creating relationships.

3. The other thing I do is CREATE 3 new tables: title_writers, title_directors, and name_known_for. title_crew is made up of arrays of writers and directors, which is hard to use so I created 2 new tables with 2 columns, a title ID (tconst) and matching name ID (nconst). name_basics has an array column of nconst and a bunch of tconst, with name_known_for I took those arrays and made a single relationship, one nconst for one tconst. 

So after you run this: title_crew and the column knownfortitles in name_basics are deprecated. I think this schema is closer to the many to many principal.

# If you want to run all the SQL at once

## You can do that with psql

First, make sure you have the file paths updated in the COPY FROM lines in [create_tables_and_insert_data_imdb.sql](https://github.com/kentstephen/imdb_postgres_elt/blob/main/create_tables_insert_data_imdb.sql).

Open a terminal and cd to where you cloned the files, type in:

```psql -h yourhost -p postgresport -U youruser -d postgres```

Mine looks like:

```psql -h localhost -p 5432 -U skent -d postgres```

You will then be prompted to enter your user password.

[imdb.sql](https://github.com/kentstephen/imdb_postgres_elt/blob/main/imdb.sql) is the do it all file. I suggest using the default postgres db when you log into psql because this file will create the database imdb and then connect to it. If you already created the database then you can comment out that line in [imdb.sql](https://github.com/kentstephen/imdb_postgres_elt/blob/main/imdb.sql) but it should still run regardless.

To run it, write ```\i imdb.sql``` in psql

## These files can take a while to run.

Enjoy and let me know what you think! 

I am adding queries to [sample_queries.sql](https://github.com/kentstephen/imdb_postgres_elt/blob/main/sample_queries.sql) to give an idea of how to use the dataset. The trick is a lot of the time you have to get from one parent table to another (name_basics and title_basics) by means of another joining the two with a table that has both tconst and nconst. Refer to the ERD. So far I have found that selecting the tconst or nconst as well as primarytitle or primaryname, because if you want to do a follow up query it's easier to search with the IDs.

I haven't included indexing yet. While I was testing the SQL files I didn't notice a difference when I added indices, but maybe it would help performance.

## My Long Term Goal

Is to set up a pipeline with Python and SQL so this all can be set to update automatically. IMDB says this data is updated everyday. I don't know how many new rows they are adding, but possibly updating when people die.
