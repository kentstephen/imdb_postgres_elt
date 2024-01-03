SET client_encoding TO 'UTF8';

BEGIN TRANSACTION;


CREATE TABLE IF NOT EXISTS title_basics (
    tconst VARCHAR(10) NOT NULL,
    titleType TEXT,
    primaryTitle TEXT,
    originalTitle TEXT,
    isAdult BOOLEAN,
    startYear INT,
    endYear INT,
    runtimeMinutes INT,
    genres TEXT
);

CREATE TABLE IF NOT EXISTS name_basics (

    nconst VARCHAR(10) NOT NULL,
    primaryName TEXT,
    birthYear INT,
    deathYear INT,
    primaryProfession TEXT,
    knownForTitles TEXT

);

CREATE TABLE IF NOT EXISTS title_episode (
    tconst VARCHAR(10),
    parentTconst VARCHAR(10),
    seasonNumber INT,
    episodeNumber INT
  --  FOREIGN KEY (tconst) REFERENCES title_basics(tconst),
   -- FOREIGN KEY (parentTconst) REFERENCES title_basics(tconst)
);

CREATE TABLE IF NOT EXISTS title_crew (
    tconst VARCHAR(10),
    directors TEXT,
    writers TEXT
  --  FOREIGN KEY (tconst) REFERENCES title_basics(tconst)
);

CREATE TABLE IF NOT EXISTS title_ratings (
    tconst VARCHAR(10),
    averageRating FLOAT,
    numVotes INT
 --   FOREIGN KEY (tconst) REFERENCES title_basics(tconst)
);

CREATE TABLE IF NOT EXISTS title_akas (
    titleId VARCHAR(10),
    ordering INT,
    title TEXT,
    region TEXT,
    language TEXT,
    types VARCHAR(50),
    attribute VARCHAR(255),
    isOriginalTitle BOOLEAN
 --   FOREIGN KEY (titleId) REFERENCES title_basics(tconst)
);

CREATE TABLE IF NOT EXISTS title_principals (
    tconst VARCHAR(10),
    ordering INT,
    nconst VARCHAR(10),
    category TEXT,
    job TEXT,
    characters TEXT
    --FOREIGN KEY (tconst) REFERENCES title_basics(tconst)
    --FOREIGN KEY (nconst) REFERENCES name_basics(nconst)
    --there is an error with someone's nconst in this table: it's too long
    -- nm15640824 from in A Dama do Cine Shanghai A Dama do Cine Shanghai tt0092818, it appears in title_principals,
    -- and title_crew but not it's not in name_basics so we cannot use nconst as a primary key here until
    -- we fix this. we'll get it into the table and sort it out.
    --SAME problem with tconst, (tt10636886) from title_principals is not in title_basics

);


COPY title_basics FROM '{{user_provided_directory}}/title.basics.tsv'
DELIMITER E'\t'
CSV HEADER
QUOTE E'\b'
NULL AS '\N';

COPY name_basics FROM '{{user_provided_directory}}/name.basics.tsv'
DELIMITER E'\t'
CSV HEADER
QUOTE E'\b'
NULL AS '\N';

COPY title_principals FROM '{{user_provided_directory}}/title.principals.tsv'
DELIMITER E'\t'
QUOTE E'\b'
CSV HEADER NULL AS '\N';

COPY title_akas FROM '{{user_provided_directory}}/title.akas.tsv'
DELIMITER E'\t'
CSV HEADER
QUOTE E'\b'
NULL AS '\N';

COPY title_ratings FROM '{{user_provided_directory}}/title.ratings.tsv'
DELIMITER E'\t'
CSV HEADER
QUOTE E'\b'
NULL AS '\N';

COPY title_crew FROM '{{user_provided_directory}}/title.crew.tsv'
DELIMITER E'\t'
CSV HEADER
QUOTE E'\b'
NULL AS '\N';

COPY title_episode FROM '{{user_provided_directory}}/title.episode.tsv'
DELIMITER E'\t'
CSV HEADER
QUOTE E'\b'
NULL AS '\N';

COMMIT;