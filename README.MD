# Get IMDB Data, Put Into PostgreSQL, Recreate the Schema, Source (https://developer.imdb.com/non-commercial-datasets/)

## Get the IMDB Data

To do this, insert the path to where you cloned the directory into [import_imdb_tsvs.py](https://github.com/kentstephen/imdb_postgres_elt/blob/main/import_imdb_tsvs.py)

That will download and extract the 7 TSV files, and then create a new directory within the one you provided called tsvs_from_imdb. 
It will also save the file path to the TSVs so when you run [insert_file_path.py](https://github.com/kentstephen/imdb_postgres_elt/blob/main/insert_file_paths.py), the correct file path will be inserted into the first .sql file [create_tables_and_insert_data_imdb.sql](https://github.com/kentstephen/imdb_postgres_elt/blob/main/create_tables_insert_data_imdb.sql)

### If they python files don't work 

All you need to run the .sql files is to download and extract the 7 .gz files from the source, and then copy the correct path to where syntax in [create_tables_and_insert_data_imdb.sql](https://github.com/kentstephen/imdb_postgres_elt/blob/main/create_tables_insert_data_imdb.sql)

## Once you have the data

You need to ```CREATE DATABASE imdb;``` then to run the .sql files you set your connection in your IDE to imdb.public and run [create_tables_and_insert_data_imdb.sql](https://github.com/kentstephen/imdb_postgres_elt/blob/main/create_tables_insert_data_imdb.sql), this will create the schema and then copy the TSVs into the respective tables. 

At this point there are no relations between the entities as some problems will arise. 

1. There are values in children tables that are not in the two tables that should have Primary Keys (title_basics and name_basics). 
2. the tables utilize arrays, which will make querying the data very difficult. If all you want is the data in tables, you can stop here, but the next file will offer my solution.

## Add tables and constraints

1. I wanted to make this more query friendly, one of the things I do in [new_schema_and_constraints.slq](https://github.com/kentstephen/imdb_postgres_elt/blob/main/new_schema_and_constraints.sql) is insert all of the unique tconst and nconst values that are in the five children tables but not in title_basics or name_basics into the the parent tables along with the string 'ANOMALY' in the next column. 

2. The next thing I do is CREATE 3 new tables: title_writers, title_directors, and name_known_for. title_crew is made up of arrays of writers and directors, which is hard to use so I created 2 new tables with 2 columns, a title ID (tconst) and matching name ID (nconst). name_basics has an array column of nconst and a bunch of tconst, with name_known_for I took those arrays and made a single relationship, one nconst for one tconst. 

So after you run this, title_crew, and the column knownfortitles in name_basics are deprecated.

# If you want to Run all .sql files at once

### You can do that with psql

CD in a terminal to where you cloned the files, type in:

```psql -h yourhost -p 5432 -U your -d postgres```

[imdb.sql](https://github.com/kentstephen/imdb_postgres_elt/blob/main/imdb.sql) I suggest using the default postgres db, because this file will create the database imdb, if you already did that you can comment out that line and run the rest.

To run it write ```\i imdb.sql```

## These files can take a while to run.

Let me know what you think, if there's anything I should try. I am going put together some sample queries you will be able to test out.
