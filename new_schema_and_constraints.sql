BEGIN;
CREATE TABLE IF NOT EXISTS title_directors (
    tconst VARCHAR(10),
    director_nconst VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS title_writers (
    tconst VARCHAR(10),
    writer_nconst VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS name_known_for (
    nconst VARCHAR(10),
    tconst VARCHAR(10)
);


INSERT INTO title_directors (tconst, director_nconst)
SELECT tc.tconst, unnest(string_to_array(tc.directors, ',')) AS director_nconst
FROM title_crew tc
WHERE tc.directors IS NOT NULL AND tc.directors <> '';

INSERT INTO title_writers (tconst, writer_nconst)
SELECT tc.tconst, unnest(string_to_array(tc.writers, ',')) AS writer_nconst
FROM title_crew tc
WHERE tc.directors IS NOT NULL AND tc.directors <> '';

INSERT INTO name_known_for (nconst, tconst)
SELECT nb.nconst, unnest(string_to_array(nb.knownfortitles, ',')) AS tconst
FROM name_basics nb
WHERE nb.knownfortitles IS NOT NULL AND nb.knownfortitles <> '';


-- Handling tconst values
WITH MissingTconst AS (
    SELECT DISTINCT tconst
    FROM (
        SELECT parenttconst as tconst FROM title_episode WHERE parenttconst IS NOT NULL
        UNION
        SELECT titleid as tconst FROM title_akas WHERE titleid IS NOT NULL
        UNION
        SELECT tconst FROM title_crew WHERE tconst IS NOT NULL
        UNION
        SELECT tconst FROM title_episode WHERE tconst IS NOT NULL
        UNION
        SELECT tconst FROM title_principals WHERE tconst IS NOT NULL
        UNION
        SELECT tconst FROM title_ratings WHERE tconst IS NOT NULL
        UNION
        SELECT tconst FROM title_directors WHERE tconst IS NOT NULL
        UNION
        SELECT tconst FROM title_writers WHERE tconst IS NOT NULL
        UNION
        SELECT tconst FROM name_known_for WHERE tconst IS NOT NULL
    ) AS combined_tconsts
)
INSERT INTO title_basics (tconst, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, runtimeMinutes, genres)
SELECT m.tconst, 'ANOMALY', NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM MissingTconst m
LEFT JOIN title_basics tb ON m.tconst = tb.tconst
WHERE tb.tconst IS NULL;

-- Handling nconst values
WITH MissingNconst AS (
    SELECT DISTINCT nconst
    FROM (
        SELECT nconst FROM title_principals WHERE nconst IS NOT NULL
        UNION
        SELECT director_nconst as nconst FROM title_directors WHERE director_nconst IS NOT NULL
        UNION
        SELECT writer_nconst as nconst FROM title_writers WHERE writer_nconst IS NOT NULL
        UNION
        SELECT nconst FROM name_known_for WHERE nconst IS NOT NULL
    ) AS combined_nconsts
)
INSERT INTO name_basics (nconst, primaryName, birthYear, deathYear, primaryProfession, knownForTitles)
SELECT mn.nconst, 'ANOMALY', NULL, NULL, NULL, NULL
FROM MissingNconst mn
LEFT JOIN name_basics nb ON mn.nconst = nb.nconst
WHERE nb.nconst IS NULL;


ALTER TABLE name_basics ADD PRIMARY KEY (nconst);
ALTER TABLE title_basics ADD PRIMARY KEY (tconst);
ALTER TABLE title_episode ADD FOREIGN KEY (parenttconst) REFERENCES title_basics (tconst);
ALTER TABLE title_akas ADD FOREIGN KEY (titleId) REFERENCES title_basics (tconst);
ALTER TABLE title_ratings ADD FOREIGN KEY (tconst) REFERENCES title_basics (tconst);
ALTER TABLE title_crew ADD FOREIGN KEY (tconst) REFERENCES title_basics (tconst);
ALTER TABLE title_principals ADD FOREIGN KEY (tconst) REFERENCES title_basics (tconst);
ALTER TABLE title_principals ADD FOREIGN KEY (nconst) REFERENCES name_basics (nconst);
ALTER TABLE title_directors ADD FOREIGN KEY (director_nconst) REFERENCES name_basics (nconst);
ALTER TABLE title_directors ADD FOREIGN KEY (tconst) REFERENCES title_basics (tconst);
ALTER TABLE title_writers ADD FOREIGN KEY (writer_nconst) REFERENCES name_basics (nconst);
ALTER TABLE title_writers ADD FOREIGN KEY (tconst) REFERENCES title_basics (tconst);
ALTER TABLE name_known_for ADD FOREIGN KEY (tconst) REFERENCES title_basics (tconst);
ALTER TABLE name_known_for ADD FOREIGN KEY (nconst) REFERENCES name_basics (nconst);


ALTER TABLE name_title_relation RENAME TO name_known_for;
COMMIT;


