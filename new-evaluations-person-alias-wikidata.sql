-- New evaluations for FASTAPI-TEXT2SQL-293 and TMDB-MOVIE-PREPROCESS-070: a person asked for by
-- a name only Wikidata knows, and an exact alias shared by two persons. 4 evaluations, English
-- and French, category 30 (Persons - Person name queries). Written 2026-11-05.
--
-- WHY
-- Process 51 of tmdb-movie-preprocess adds the Wikidata aliases (en, fr) of the T2S persons to
-- T_WC_T2S_PERSON_ALSO_KNOWN_AS (ALIAS_SOURCE = 'wikidata'), and the exact match of the
-- resolver now orders a shared normalized form by popularity instead of taking whichever row
-- InnoDB meets first. House rule of 2026-10-31: the questions go in before the change, the
-- campaign on the current version is the baseline, the change must turn them green.
--
-- THE IDS AND SPELLINGS ARE READ, NOT REMEMBERED
-- harvest-person-alias-wikidata-20261105.txt: each name below is a Wikidata alias of the person
-- and is absent from the TMDb aliases the resolver reads today, except section 2 (shared alias).
--   91256    Sigrid Valdis   alias "Patricia Annette Olson" (en, fr), TMDb: "Sigrid Valdis" only
--   1043449  Lady Tree       alias "Maud Holt Tree" (en), TMDb: "Lady Tree" only
--   157942   Tuc Watkins     alias "Charles Curtis Watkins III" (fr), TMDb: "Tuc Watkins" only
--   67047    Paul Chu Kong   TMDb alias "Chu Kong", popularity 92.5, shared with 1025557
--                           Chugong (0.2): the exact match picks one of the two at random today
--
-- WHAT THE ASSERTIONS PROTECT
-- COUNT(*) > 0 (floor) AND ID_PERSON IN (...) (anchor on a stable TMDb id), as in
-- new-evaluations-person-alias.sql. No ASSERTION_REFRESH_SQL: process 70 would strip the floor.
-- ASSERTIONS_ENTITY_EXTRACTION left NULL: not run three times in each language yet.
--
-- RE-RUN GUARD: INSERT ... SELECT guarded by NOT EXISTS on the English question, in a derived
-- table (MySQL error 1093). Voie 1 (T_WC_T2S_EVALUATION is writable by the agent).
-- Then phase 31 to refresh the JSON export, and phases 11 + 20 to run and score them.

-- 0. Pre-flight: must return zero rows.
SELECT ID_T2S_EVALUATION, LEFT(QUESTION, 70) AS QUESTION
FROM T_WC_T2S_EVALUATION
WHERE QUESTION IN ('Who is Patricia Annette Olson?', 'Who is Maud Holt Tree?',
                   'Who is Charles Curtis Watkins III?', 'Who is Chu Kong?');

-- 1. Names only Wikidata knows.
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Who is Patricia Annette Olson?',
       'Qui est Patricia Annette Olson ?',
       1, 0, 30, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_PERSON IN (91256)',
       'Birth name of Sigrid Valdis (TMDb 91256), a Wikidata alias in English and French; TMDb lists no alias but the credited name. Red until the Wikidata aliases reach T_WC_T2S_PERSON_ALSO_KNOWN_AS (TMDB-MOVIE-PREPROCESS-070, FASTAPI-TEXT2SQL-293).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Who is Patricia Annette Olson?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Who is Maud Holt Tree?',
       'Qui est Maud Holt Tree ?',
       1, 0, 30, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_PERSON IN (1043449)',
       'Lady Tree (TMDb 1043449), credited under her title; "Maud Holt Tree" is one of eight Wikidata aliases, none of which TMDb lists. No token of the question is in the credited name, so neither the main-name strategy nor token_subset on the TMDb alias can reach her (TMDB-MOVIE-PREPROCESS-070, FASTAPI-TEXT2SQL-293).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Who is Maud Holt Tree?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Who is Charles Curtis Watkins III?',
       'Qui est Charles Curtis Watkins III ?',
       1, 0, 30, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_PERSON IN (157942)',
       'Full name of Tuc Watkins (TMDb 157942), a French Wikidata alias; the English one carries the nickname in quotes. TMDb lists only "Tuc Watkins". Red until TMDB-MOVIE-PREPROCESS-070 (FASTAPI-TEXT2SQL-293).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Who is Charles Curtis Watkins III?') AS existing);

-- 2. An exact alias shared by two persons: the most popular must win.
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Who is Chu Kong?',
       'Qui est Chu Kong ?',
       1, 0, 30, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_PERSON IN (67047)',
       'The normalized alias "chu kong" belongs to two persons of T_WC_T2S_PERSON_ALSO_KNOWN_AS: Paul Chu Kong (TMDb 67047, popularity 92.5) and Chugong (1025557, 0.2), on 2026-11-05. The exact match took LIMIT 1 without ORDER BY, so either could come back; since FASTAPI-TEXT2SQL-293 it orders by popularity. A pass before that change may be luck: read the trace.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Who is Chu Kong?') AS existing);

-- 3. Post-flight: four rows, each with its assertion, no ASSERTION_REFRESH_SQL.
SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, LEFT(QUESTION, 40) AS QUESTION,
       ASSERTIONS_QUERY_RESULT, ASSERTION_REFRESH_SQL
FROM T_WC_T2S_EVALUATION
WHERE QUESTION IN ('Who is Patricia Annette Olson?', 'Who is Maud Holt Tree?',
                   'Who is Charles Curtis Watkins III?', 'Who is Chu Kong?')
ORDER BY ID_T2S_EVALUATION;
