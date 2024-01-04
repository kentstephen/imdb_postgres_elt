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
        AND tb.startyear < '1990' -- three years after he died
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


-- this should yield something likeC; this:

-- tt0025164,The Gay Divorcee,Mark Sandrich
-- tt0026942,Roberta,William A. Seiter
-- tt0027125,Top Hat,Mark Sandrich
-- tt0027630,Follow the Fleet,Mark Sandrich
-- tt0028333,Swing Time,George Stevens
-- tt0028757,A Damsel in Distress,George Stevens

-- some of the movies have a lot of directors