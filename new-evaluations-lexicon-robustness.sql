-- New evaluations: robustness of the title lexicon (RapidFuzz) on tricky wordings, after the
-- 1.1.20 campaign (FASTAPI-TEXT2SQL-360, -363, -366). Philippe's request, 2026-11-05.
--
-- WHAT THIS FILE DOES
-- Adds ten title lookups, English with a French twin, each asserting the expected id. Every
-- wording was sent to Blue 1.1.20 with the cache off on 2026-11-05 before being written here;
-- ids, titles and aliases checked in base (check-lexicon-robustness-ids.sql and its result).
--   1  alias tier: 'Star Wars The Empire Strikes Back' misses the TMDb titles and resolves
--      through T_WC_T2S_MOVIE_TITLE_ALIAS, the only alias-tier hit seen so far (1891).
--   2  year guard counter-case (-363): a misspelt title with the right year must still resolve.
--   3  several fuzzy mentions in one list (typo, missing apostrophe, WALL·E with a hyphen).
--   4-5  a short title among homonyms, the year decides (Up 2009, It 2017; 'Ça' in French).
--   6-7  the same for series (The Office 2005 against 2001; Shōgun 2024 with its macron).
--   8  'Seven' is the French TMDb title of Se7en (807), and other films carry that name.
--   9  FAILS on 1.1.20 (-366): 'Les Visiteurs 2' misses the lexicon (the TMDb title is
--      'Les Couloirs du temps : Les Visiteurs II') and the ChromaDB fallback accepts the 1993
--      'Les Visiteurs' (11687), whose number disagrees; the SQL also brings the 1972 'The
--      Visitors' (102699). Asserted with NOT IN so the wrong film fails even beside the right one.
--  10  FAILS on 1.1.20 (-366): 'Star Wars épisode 4' gives 0 rows; the alias table holds
--      'Star Wars: Episode IV' and 'Star Wars 4', but roman numerals are not folded.
-- Probed on Blue 1.1.20 on 2026-11-05 with these exact wordings, cache off: 1 to 8 pass in
-- both languages (the French twin of 1 reaches the alias tier on a fuzzy hit), except the
-- French twin of 3: every title resolves (424 through MOVIE_TITLE_FR), but the SQL writes
-- MOVIE_TITLE IN (...) and the French value finds nothing in the English column, the `IN`
-- list of FASTAPI-TEXT2SQL-357, not a lexicon fault. 9 and 10 fail in both languages (-366).
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1, IS_SHOWCASE = 1 (every entity has a poster-worthy card).
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/new-evaluations-lexicon-robustness.sql
--
-- CONVENTIONS (as new-evaluations-360.sql): auto-increment id; each INSERT guarded by NOT EXISTS
-- on the English QUESTION; DELETED = 0; DAT_CREAT = CURDATE(); owner 1. Category 2 = movies
-- basic queries, 6 = TV series basic queries.

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Star Wars The Empire Strikes Back', 'Film Star Wars L''Empire contre-attaque', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (1891)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Star Wars The Empire Strikes Back') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie The Godfahter (1972)', 'Film Le Parain (1972)', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (238)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie The Godfahter (1972)') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movies Pulp Fictoin, Schindlers List and Wall-E', 'Films Pulp Fictoin, La Liste de Schindlr et Wall-E', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (680, 424, 10681)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movies Pulp Fictoin, Schindlers List and Wall-E') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Up (2009)', 'Film Up (2009)', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (14160)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Up (2009)') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie It (2017)', 'Film Ça (2017)', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (346364)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie It (2017)') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Series The Office (2005)', 'Série The Office (2005)', 6, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_SERIE IN (2316)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Series The Office (2005)') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Series Shogun (2024)', 'Série Shogun (2024)', 6, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_SERIE IN (126308)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Series Shogun (2024)') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Seven (1995)', 'Film Seven (1995)', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (807)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Seven (1995)') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie The Visitors 2', 'Film Les Visiteurs 2', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (10353) AND ID_MOVIE NOT IN (11687, 102699)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie The Visitors 2') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Star Wars Episode 4', 'Film Star Wars épisode 4', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (11)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Star Wars Episode 4') AS guard);

SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ASSERTIONS_QUERY_RESULT
  FROM T_WC_T2S_EVALUATION
 WHERE QUESTION IN ('Movie Star Wars The Empire Strikes Back',
                    'Movie The Godfahter (1972)',
                    'Movies Pulp Fictoin, Schindlers List and Wall-E',
                    'Movie Up (2009)',
                    'Movie It (2017)',
                    'Series The Office (2005)',
                    'Series Shogun (2024)',
                    'Movie Seven (1995)',
                    'Movie The Visitors 2',
                    'Movie Star Wars Episode 4')
 ORDER BY ID_T2S_EVALUATION;
