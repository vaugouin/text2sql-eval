-- Ids for the new evaluations of FASTAPI-TEXT2SQL-367 (first shape: a named actor plus one role
-- description) and FASTAPI-TEXT2SQL-340 ("who plays Spider-Man"). Read-only, voie 1.
-- Written 2026-11-10, before new-evaluations-367-340.sql.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/check-367-340-ids.sql

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT '1. Categories' AS SECTION;
SELECT ID_T2S_EVALUATION_CATEGORY, LEFT(CATEGORY_NAME, 60) AS CATEGORY_NAME
FROM T_WC_T2S_EVALUATION_CATEGORY ORDER BY ID_T2S_EVALUATION_CATEGORY;

SELECT '2. -367: the works and the actor credit' AS SECTION;
SELECT 'movie' AS KIND, m.ID_MOVIE AS ID, m.MOVIE_TITLE AS TITLE, m.RELEASE_YEAR AS YR,
       p.ID_PERSON, p.PERSON_NAME, LEFT(pm.CAST_CHARACTER, 60) AS ROLE_CREDIT
FROM T_WC_T2S_MOVIE m
JOIN T_WC_T2S_PERSON_MOVIE pm ON pm.ID_MOVIE = m.ID_MOVIE AND COALESCE(pm.DELETED, 0) = 0
JOIN T_WC_T2S_PERSON p ON p.ID_PERSON = pm.ID_PERSON
WHERE (m.MOVIE_TITLE = 'Cast Away' AND p.PERSON_NAME = 'Tom Hanks')
   OR (m.MOVIE_TITLE = 'The Devil Wears Prada' AND p.PERSON_NAME = 'Meryl Streep')
   OR (m.MOVIE_TITLE = 'The Truman Show' AND p.PERSON_NAME = 'Jim Carrey')
   OR (m.MOVIE_TITLE = 'Erin Brockovich' AND p.PERSON_NAME = 'Julia Roberts')
UNION ALL
SELECT 'serie', s.ID_SERIE, s.SERIE_TITLE, s.FIRST_AIR_YEAR, p.ID_PERSON, p.PERSON_NAME,
       LEFT(ps.CAST_CHARACTER, 60)
FROM T_WC_T2S_SERIE s
JOIN T_WC_T2S_PERSON_SERIE ps ON ps.ID_SERIE = s.ID_SERIE AND COALESCE(ps.DELETED, 0) = 0
JOIN T_WC_T2S_PERSON p ON p.ID_PERSON = ps.ID_PERSON
WHERE (s.SERIE_TITLE = 'Breaking Bad' AND p.PERSON_NAME = 'Bryan Cranston')
   OR (s.SERIE_TITLE = 'The Diplomat' AND p.PERSON_NAME = 'Keri Russell')
   OR (s.SERIE_TITLE = 'Fleabag' AND p.PERSON_NAME = 'Phoebe Waller-Bridge')
ORDER BY KIND, TITLE;

SELECT '3. -340: who is credited as Spider-Man or Peter Parker in movies' AS SECTION;
SELECT p.ID_PERSON, p.PERSON_NAME, ROUND(p.POPULARITY, 2) AS POP, COUNT(DISTINCT pm.ID_MOVIE) AS FILMS,
       LEFT(GROUP_CONCAT(DISTINCT pm.CAST_CHARACTER SEPARATOR ' | '), 90) AS CREDITS
FROM T_WC_T2S_PERSON_MOVIE pm
JOIN T_WC_T2S_PERSON p ON p.ID_PERSON = pm.ID_PERSON
WHERE COALESCE(pm.DELETED, 0) = 0
  AND (pm.CAST_CHARACTER LIKE '%Spider-Man%' OR pm.CAST_CHARACTER LIKE '%Spiderman%'
       OR pm.CAST_CHARACTER LIKE '%Peter Parker%')
GROUP BY p.ID_PERSON, p.PERSON_NAME, p.POPULARITY
ORDER BY p.POPULARITY DESC
LIMIT 40;

SELECT '4. -340: exact credit strings, as today''s SQL matches them' AS SECTION;
SELECT pm.CAST_CHARACTER, COUNT(*) AS N
FROM T_WC_T2S_PERSON_MOVIE pm
WHERE COALESCE(pm.DELETED, 0) = 0
  AND pm.CAST_CHARACTER IN ('Spider-Man', 'Peter Parker', 'Peter Parker / Spider-Man', 'Spider-Man / Peter Parker')
GROUP BY pm.CAST_CHARACTER;

SELECT '5. Existing evaluations on these subjects (no duplicate)' AS SECTION;
SELECT ID_T2S_EVALUATION, LEFT(QUESTION, 100) AS QUESTION, ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION
WHERE COALESCE(DELETED, 0) = 0
  AND (QUESTION LIKE '%Spider%' OR QUESTION LIKE '%Peter Parker%' OR QUESTION LIKE '%Keri Russell%'
       OR QUESTION LIKE '%Cast Away%' OR QUESTION LIKE '%stranded%' OR QUESTION LIKE '%chemistry teacher%')
ORDER BY ID_T2S_EVALUATION;
