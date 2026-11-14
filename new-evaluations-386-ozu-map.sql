-- Defect-closing evaluation for FASTAPI-TEXT2SQL-386: "the films of a director" read as any crew
-- credit. Found on 2026-11-14 at 18:10 while testing the map of places (phase 3 lot D) on the iPad.
--
-- THE DEFECT. "Map the filming locations of Yasujiro Ozu's films" (Blue 1.1.20, logs
-- 20261114-181035, -181624, -181718): the SQL joined T_WC_T2S_PERSON_MOVIE with
-- CREDIT_TYPE = 'crew' and no CREW_JOB, so a film where Ozu has another crew credit brought in
-- West Berlin (ID_LOCATION 1591) beside Japan (32). The voice model noticed and asked again,
-- "Include only films he directed, and only filming locations": one row, Japan. "X's films" means
-- the films X directed (the bank's 593, 594, 605 read it so for the film lists).
--
-- WHAT. The question as typed, category of the map evaluations (2915, "Map the filming locations
-- of Christopher Nolan's films"), French twin.
--
-- THE ASSERTIONS. `ID_LOCATION IN (32) AND ID_LOCATION NOT IN (1591)`: Japan present, West Berlin
-- absent (assertion on what went wrong, not on the full list, which follows the data).
-- ASSERTIONS_RESULT_SHAPE `representation == map` (out of score), as 2910 to 2915.
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1, IS_SHOWCASE = 0 (places, not a showcase card).
-- RE-RUN GUARD: INSERT ... SELECT ... WHERE NOT EXISTS on the English question.
-- The first SELECTs show the films behind West Berlin and the job Ozu holds on them.
--
-- ROUTING: one INSERT on T_WC_T2S_EVALUATION, no DDL: voie 1. Commit and push before running.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-386-ozu-map.sql

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT ID_LOCATION, LOCATION_NAME, LOCATION_TYPE FROM T_WC_T2S_LOCATION WHERE ID_LOCATION IN (32, 1591);

SELECT m.ID_MOVIE, m.MOVIE_TITLE, m.RELEASE_YEAR, pm.CREDIT_TYPE, pm.CREW_DEPARTMENT, pm.CREW_JOB,
       ml.ID_LOCATION, ml.LOCATION_ROLE
FROM T_WC_T2S_PERSON p
JOIN T_WC_T2S_PERSON_MOVIE pm ON pm.ID_PERSON = p.ID_PERSON
JOIN T_WC_T2S_MOVIE m ON m.ID_MOVIE = pm.ID_MOVIE
JOIN T_WC_T2S_MOVIE_LOCATION ml ON ml.ID_MOVIE = m.ID_MOVIE
WHERE p.PERSON_NAME = 'Yasujirō Ozu' AND ml.ID_LOCATION IN (32, 1591) AND ml.LOCATION_ROLE = 'filming'
ORDER BY ml.ID_LOCATION, pm.CREW_JOB, m.RELEASE_YEAR
LIMIT 60;

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, LEFT(QUESTION, 70) AS QUESTION FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION = 2915 OR QUESTION LIKE '%Ozu%map%' OR QUESTION LIKE '%map%Ozu%';

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 'Map the filming locations of Yasujiro Ozu''s films',
       'Carte des lieux de tournage des films de Yasujirō Ozu',
       1, 1, 0, e.ID_T2S_EVALUATION_CATEGORY, 0, CURDATE(), NOW(),
       'ID_LOCATION IN (32) AND ID_LOCATION NOT IN (1591)',
       'representation == map',
       'The films of a director are the films he directed. On 2026-11-14 (Blue 1.1.20) the SQL took any crew credit of Ozu and West Berlin (1591) came in beside Japan (32); the voice model had to ask again for the films he directed. FASTAPI-TEXT2SQL-386, found while testing the map of places (phase 3 lot D).'
FROM T_WC_T2S_EVALUATION e
WHERE e.ID_T2S_EVALUATION = 2915 AND NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Map the filming locations of Yasujiro Ozu''s films') AS existing);

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE,
       QUESTION, QUESTION_FR, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE
FROM T_WC_T2S_EVALUATION
WHERE LONG_DESC LIKE '%FASTAPI-TEXT2SQL-386%';
