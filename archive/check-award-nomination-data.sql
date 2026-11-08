-- Award and nomination data: is the Best Picture question empty for lack of data, or for a name the SQL guessed?
--
-- Why. Green (1.1.19, 2026-10-31) returned no rows for "How many films were nominated for the Best Picture Oscar
-- each year since 2010?" and for "Which actors have the most Oscar nominations?". Both generated SQLs tested a
-- literal name, NOMINATION_NAME = 'Best Picture Oscar' and NOMINATION_NAME = 'Oscar', so the empty answer may be
-- a resolution miss (no {{Nomination_name}} placeholder resolved) rather than missing data. Philippe notes the
-- tables exist and are fed from Wikidata (process 44 awards, 47 nominations of tmdb-movie-preprocess). This file
-- reads only: part 1 the volumes, part 2 what the Academy rows are called and how many titles they carry,
-- part 3 the largest nominations, part 4 the Best Picture nominees per year computed with LIKE.
--
-- Run on the VPS (SELECT only, voie 1):
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/check-award-nomination-data.sql

-- Part 1. Volumes
SELECT 'nominations' AS TABLE_NAME, COUNT(*) AS ROWS_, SUM(COALESCE(MOVIE_COUNT, 0)) AS MOVIE_LINKS,
       SUM(COALESCE(SERIE_COUNT, 0)) AS SERIE_LINKS, SUM(COALESCE(PERSON_COUNT, 0)) AS PERSON_LINKS
FROM T_WC_T2S_NOMINATION
UNION ALL
SELECT 'awards', COUNT(*), SUM(COALESCE(MOVIE_COUNT, 0)), SUM(COALESCE(SERIE_COUNT, 0)), SUM(COALESCE(PERSON_COUNT, 0))
FROM T_WC_T2S_AWARD;

SELECT NOMINATION_SOURCE, NOMINATION_TYPE, COUNT(*) AS ROWS_, SUM(COALESCE(MOVIE_COUNT, 0)) AS MOVIE_LINKS,
       SUM(COALESCE(PERSON_COUNT, 0)) AS PERSON_LINKS
FROM T_WC_T2S_NOMINATION
GROUP BY NOMINATION_SOURCE, NOMINATION_TYPE
ORDER BY ROWS_ DESC;

SELECT (SELECT COUNT(*) FROM T_WC_T2S_MOVIE_NOMINATION) AS MOVIE_NOMINATION_ROWS,
       (SELECT COUNT(*) FROM T_WC_T2S_SERIE_NOMINATION) AS SERIE_NOMINATION_ROWS,
       (SELECT COUNT(*) FROM T_WC_T2S_PERSON_NOMINATION) AS PERSON_NOMINATION_ROWS,
       (SELECT COUNT(*) FROM T_WC_T2S_MOVIE_AWARD) AS MOVIE_AWARD_ROWS,
       (SELECT COUNT(*) FROM T_WC_T2S_PERSON_AWARD) AS PERSON_AWARD_ROWS;

-- Part 2. The Academy rows, nominations then awards: their exact names and what they carry
SELECT ID_NOMINATION, ID_WIKIDATA, NOMINATION_NAME, NOMINATION_SOURCE, NOMINATION_TYPE, MOVIE_COUNT, SERIE_COUNT, PERSON_COUNT
FROM T_WC_T2S_NOMINATION
WHERE NOMINATION_NAME LIKE '%Academy%' OR NOMINATION_NAME LIKE '%Oscar%' OR NOMINATION_NAME LIKE '%Best Picture%'
ORDER BY COALESCE(MOVIE_COUNT, 0) + COALESCE(PERSON_COUNT, 0) DESC
LIMIT 40;

SELECT ID_AWARD, ID_WIKIDATA, AWARD_NAME, AWARD_SOURCE, AWARD_TYPE, MOVIE_COUNT, SERIE_COUNT, PERSON_COUNT
FROM T_WC_T2S_AWARD
WHERE AWARD_NAME LIKE '%Academy%' OR AWARD_NAME LIKE '%Oscar%' OR AWARD_NAME LIKE '%Best Picture%'
ORDER BY COALESCE(MOVIE_COUNT, 0) + COALESCE(PERSON_COUNT, 0) DESC
LIMIT 40;

-- Part 3. The largest nominations, by films then by persons
SELECT ID_NOMINATION, NOMINATION_NAME, NOMINATION_SOURCE, MOVIE_COUNT, PERSON_COUNT
FROM T_WC_T2S_NOMINATION ORDER BY COALESCE(MOVIE_COUNT, 0) DESC LIMIT 15;

SELECT ID_NOMINATION, NOMINATION_NAME, NOMINATION_SOURCE, MOVIE_COUNT, PERSON_COUNT
FROM T_WC_T2S_NOMINATION ORDER BY COALESCE(PERSON_COUNT, 0) DESC LIMIT 15;

-- Part 4. Best Picture nominees per year since 2010, with LIKE instead of the literal the model guessed
SELECT n.NOMINATION_NAME, m.RELEASE_YEAR, COUNT(DISTINCT m.ID_MOVIE) AS FILM_COUNT
FROM T_WC_T2S_NOMINATION n
JOIN T_WC_T2S_MOVIE_NOMINATION mn ON mn.ID_NOMINATION = n.ID_NOMINATION
JOIN T_WC_T2S_MOVIE m ON m.ID_MOVIE = mn.ID_MOVIE
WHERE n.NOMINATION_NAME LIKE '%Best Picture%' AND m.RELEASE_YEAR >= 2010
GROUP BY n.NOMINATION_NAME, m.RELEASE_YEAR
ORDER BY n.NOMINATION_NAME, m.RELEASE_YEAR;
