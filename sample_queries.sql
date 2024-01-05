-- You have to join a lot of tables to get any basic info
-- from this dataset, here is the first example, 
-- all of the movies starring Fred Astaire and, their associated directors


WITH FIND_FRED AS (
    SELECT
        tb.tconst AS title_id,
        tb.primarytitle as title,
        tb.startyear as year
    FROM name_basics nb
    INNER JOIN title_principals tp ON nb.nconst = tp.nconst
    INNER JOIN title_basics tb ON tp.tconst = tb.tconst
    WHERE
        nb.primaryname = 'Fred Astaire'
        AND tb.startyear < '1990' -- three years after he died to filter out all the posthumous stuff
)

SELECT
    ff.title_id,
    ff.year,
    ff.title,
    nb.primaryname AS director
FROM FIND_FRED ff
INNER JOIN title_directors td ON ff.title_id = td.tconst
INNER JOIN name_basics nb ON td.director_nconst = nb.nconst
ORDER BY ff.year;


-- this should yield output like this:

-- tt0025164,1934,The Gay Divorcee,Mark Sandrich
-- tt0027125,1935,Top Hat,Mark Sandrich
-- tt0026942,1935,Roberta,William A. Seiter
-- tt0027630,1936,Follow the Fleet,Mark Sandrich
-- tt0028333,1936,Swing Time,George Stevens
-- tt0029546,1937,Shall We Dance,Mark Sandrich
-- tt0028757,1937,A Damsel in Distress,George Stevens
-- tt0029971,1938,Carefree,Mark Sandrich
-- tt0031983,1939,The Story of Vernon and Irene Castle,H.C. Potter
-- tt0032284,1940,Broadway Melody of 1940,Norman Taurog


-- some of the movies have a lot of directors