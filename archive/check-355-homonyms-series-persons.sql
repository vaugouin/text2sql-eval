-- Census for extending the FASTAPI-TEXT2SQL-355 evaluations beyond movies (Philippe, 2026-11-08).
--
-- -355 tells apart works that share a title AND a year (the complex rewrite `Movie|Serie <title>
-- (<year>)` loses the description; `known_credits` and the -307 identity check pick the right
-- row). The bank has eleven movie descriptions (2630 to 2640), one series (2641) and no person.
-- The rewrite of a person is `Person <name> born in <year>`: the same trap if two persons share
-- the name and the birth year. This census finds real, well-known collisions to write the
-- evaluations on, before any code.
--
-- Read-only, voie 1:
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/archive/check-355-homonyms-series-persons.sql

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT 'serie title + first air year' AS SECTION;

SELECT COUNT(*) AS GROUPS_TITLE_YEAR, SUM(N) AS ROWS_IN_GROUPS
FROM (SELECT SERIE_TITLE, FIRST_AIR_YEAR, COUNT(*) AS N
        FROM T_WC_T2S_SERIE
       WHERE COALESCE(DELETED, 0) = 0 AND SERIE_TITLE <> '' AND FIRST_AIR_YEAR IS NOT NULL
       GROUP BY SERIE_TITLE, FIRST_AIR_YEAR HAVING COUNT(*) >= 2) g;

SELECT s.SERIE_TITLE, s.FIRST_AIR_YEAR, s.ID_SERIE, s.ID_IMDB, s.ORIGINAL_TITLE,
       s.IMDB_VOTES, ROUND(s.POPULARITY, 1) AS POPULARITY
FROM T_WC_T2S_SERIE s
JOIN (SELECT SERIE_TITLE, FIRST_AIR_YEAR, MAX(COALESCE(IMDB_VOTES, 0)) AS TOPV
        FROM T_WC_T2S_SERIE
       WHERE COALESCE(DELETED, 0) = 0 AND SERIE_TITLE <> '' AND FIRST_AIR_YEAR IS NOT NULL
       GROUP BY SERIE_TITLE, FIRST_AIR_YEAR
      HAVING COUNT(*) >= 2 AND MAX(COALESCE(IMDB_VOTES, 0)) >= 20000) g
  ON g.SERIE_TITLE = s.SERIE_TITLE AND g.FIRST_AIR_YEAR = s.FIRST_AIR_YEAR
WHERE COALESCE(s.DELETED, 0) = 0
ORDER BY g.TOPV DESC, s.SERIE_TITLE, s.IMDB_VOTES DESC
LIMIT 120;

SELECT 'person name + birth year' AS SECTION;

SELECT COUNT(*) AS GROUPS_NAME_YEAR, SUM(N) AS ROWS_IN_GROUPS
FROM (SELECT PERSON_NAME, BIRTH_YEAR, COUNT(*) AS N
        FROM T_WC_T2S_PERSON
       WHERE COALESCE(DELETED, 0) = 0 AND PERSON_NAME <> '' AND BIRTH_YEAR IS NOT NULL
       GROUP BY PERSON_NAME, BIRTH_YEAR HAVING COUNT(*) >= 2) g;

SELECT p.PERSON_NAME, p.BIRTH_YEAR, p.ID_PERSON, p.ID_IMDB, p.KNOWN_FOR_DEPARTMENT,
       p.COUNTRY_OF_BIRTH, ROUND(p.POPULARITY, 2) AS POPULARITY
FROM T_WC_T2S_PERSON p
JOIN (SELECT PERSON_NAME, BIRTH_YEAR, MAX(COALESCE(POPULARITY, 0)) AS TOPP
        FROM T_WC_T2S_PERSON
       WHERE COALESCE(DELETED, 0) = 0 AND PERSON_NAME <> '' AND BIRTH_YEAR IS NOT NULL
       GROUP BY PERSON_NAME, BIRTH_YEAR HAVING COUNT(*) >= 2) g
  ON g.PERSON_NAME = p.PERSON_NAME AND g.BIRTH_YEAR = p.BIRTH_YEAR
WHERE COALESCE(p.DELETED, 0) = 0
ORDER BY g.TOPP DESC, p.PERSON_NAME, p.POPULARITY DESC
LIMIT 120;

SELECT 'person name shared, famous one, other birth year unknown' AS SECTION;

-- The rewrite carries a birth year; a namesake with no BIRTH_YEAR may or may not be filtered out.
SELECT p.PERSON_NAME, p.BIRTH_YEAR, p.ID_PERSON, p.ID_IMDB, p.KNOWN_FOR_DEPARTMENT,
       ROUND(p.POPULARITY, 2) AS POPULARITY
FROM T_WC_T2S_PERSON p
JOIN (SELECT PERSON_NAME, MAX(COALESCE(POPULARITY, 0)) AS TOPP
        FROM T_WC_T2S_PERSON
       WHERE COALESCE(DELETED, 0) = 0 AND PERSON_NAME <> ''
       GROUP BY PERSON_NAME
      HAVING COUNT(*) >= 2 AND SUM(BIRTH_YEAR IS NULL) >= 1 AND MAX(COALESCE(POPULARITY, 0)) >= 5) g
  ON g.PERSON_NAME = p.PERSON_NAME
WHERE COALESCE(p.DELETED, 0) = 0
ORDER BY g.TOPP DESC, p.PERSON_NAME, p.POPULARITY DESC
LIMIT 60;
