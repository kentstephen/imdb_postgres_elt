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
        AND tb.startyear < '1990' -- three years after he died to filter out all the posthumous credits
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


-- SELECT titles Fred Astaire is known by from our name_known_for table which was
-- created from name_basics.knownfortitles array

SELECT
    tb.primarytitle
FROM title_basics tb
JOIN name_known_for nkf
ON tb.tconst = nkf.tconst
WHERE
    nkf.nconst IN (SELECT nconst
                  FROM name_basics
                  WHERE primaryname = 'Fred Astaire')

-- On the Beach
-- The Story of Vernon and Irene Castle
-- Funny Face
-- The Towering Inferno


-- SELECT the actors, their birth and death year joining title_principals (where all the actors nconst credits
-- have a corresponding tconst then a subquery to find the tconst from title_basics

SELECT
    nb.primaryname AS cast_and_crew,
    tp.category,
    nb.birthyear,
    nb.deathyear
FROM name_basics nb
JOIN title_principals tp
ON nb.nconst = tp.nconst
WHERE
    tp.tconst = (SELECT tconst
                  FROM title_basics
                  WHERE primarytitle = 'The Story of Vernon and Irene Castle');

-- George Haight,producer,1905,1984
-- Fred Astaire,actor,1899,1987
-- Ginger Rogers,actress,1911,1995
-- Edna May Oliver,actress,1883,1942
-- Walter Brennan,actor,1894,1974
-- H.C. Potter,director,1904,1977
-- Richard Sherman,writer,1905,1962
-- Oscar Hammerstein II,writer,1895,1960
-- Dorothy Yost,writer,1899,1967
-- Irene Castle,writer,1893,196

-- Find out the categories in title_principals

SELECT
    DISTINCT category
FROM title_principals;

-- actor -- note that actor and actress are separate, I don't understand why they did that (why not make them all actor?) but important to note
-- actress
-- archive_footage
-- archive_sound
-- cinematographer
-- composer
-- director
-- editor
-- producer
-- production_designer
-- self
-- writer

-- Find the movie actors with the most credits
-- filtering is key for performance,
-- if you leave out the titletype WHERE condition you'll find tv actors with 1000s of credits


SELECT
    nb.nconst, -- for quicker follow up queries
    nb.primaryname AS actor,
    COUNT(DISTINCT tb.tconst) as count_of_credits
FROM name_basics nb
JOIN title_principals tp
ON nb.nconst = tp.nconst
JOIN title_basics tb
ON tp.tconst = tb.tconst
WHERE
    tp.category = 'actor' -- OR tp.category = 'actress' -- uncomment to include actresses
    AND tb.titletype = 'movie'
GROUP BY
    nb.nconst, nb.primaryname
HAVING
    COUNT(DISTINCT tb.tconst) > 200
ORDER BY
    count_of_credits DESC
LIMIT 50;

-- nm0103977,Brahmanandam,788  -- i looked this guy up and now he has over 1000 acting credits on imdb.com
-- nm0648803,Matsunosuke Onoe,564
-- nm0006982,Adoor Bhasi,539
-- nm0305182,Eddie Garcia,520
-- nm0706691,Sultan Rahi,478
-- nm0619107,Masayoshi Nogami,415
-- nm0246703,Paquito Diaz,415
-- nm0793813,Shin Seong-il,408
-- nm0046850,Bahadur,384
-- nm0007123,Mammootty,377
-- nm0482320,Mohanlal,365
-- nm0000616,Eric Roberts,365 -- i know this guy