-- New evaluations for FASTAPI-TEXT2SQL-369 (a partial title plus a named person: the title must be
-- completed within that person's credits, not resolved alone to an exact homonym the person is
-- not credited on). Decided by Philippe on 2026-11-08, written the same day, before the fix.
--
-- WHAT THIS FILE DOES
-- Five questions with their French twins, category 29 (movies, movie-title queries). Four are
-- partial titles whose bare word is also the exact title of other films, and one is the control
-- where the exact title IS the right film (the fallback must not override it). Ids measured in
-- fastapi-text2sql/doc/sql/check-369-partial-title-person-20261108.txt (voie 1, 2026-11-08):
--   1. "Raid" + Dany Boon        -> 382597 RAID Dingue (2017, EN "R.A.I.D. Special Unit").
--      Counter-examples: the exact homonyms 503838 (2018) and 20375 (2003), no Dany Boon credit.
--      The question of the trace of 2026-11-08 (0 rows, "authoritative" empty).
--   2. "Ch'tis" + Dany Boon      -> 8265 Bienvenue chez les Ch'tis (2008).
--   3. "Astérix" + Dany Boon     -> 99770 Au service de Sa Majesté (2012). Counter-examples: the
--      three Astérix films with Depardieu and without Dany Boon, 9564, 2899, 2395.
--   4. "Rings" + Viggo Mortensen -> 120, 121, 122 (The Lord of the Rings). Counter-examples: the
--      exact homonyms 14564 (Rings, 2017) and 91908 (Rings, 2005).
--   5. Control, "Taxi" + Samy Naceri -> 2330 (Taxi, 1998), the exact homonym on which he is
--      credited. Counter-examples: the sequels 2332, 2334, 2335 and the US remake 11045, so a
--      fallback that widens a correct exact hit to the whole filmography fails.
-- `IN` is coverage, `NOT IN` names the intruders (README, assertion levels 2 and 3).
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1 (rule of 2026-10-31), IS_SHOWCASE = 1 (each assertion lists
-- film ids, all with a poster).
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/archive/new-evaluations-369-partial-title-person.sql
-- Commit and push before running. The SELECT at the end gives the new ids for EVAL_IDS.
--
-- CONVENTIONS (as new-evaluations-20261107.sql): auto-increment id; each INSERT is guarded by
-- NOT EXISTS on the English QUESTION, so it fires once; DELETED = 0; DAT_CREAT = CURDATE(); owner 1.

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Raid with Dany Boon', 'Film Raid avec Dany Boon', 29, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (382597) AND ID_MOVIE NOT IN (503838, 20375)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Raid with Dany Boon') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Ch''tis with Dany Boon', 'Film Ch''tis avec Dany Boon', 29, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (8265)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Ch''tis with Dany Boon') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Asterix with Dany Boon', 'Film Astérix avec Dany Boon', 29, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (99770) AND ID_MOVIE NOT IN (9564, 2899, 2395)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Asterix with Dany Boon') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Rings with Viggo Mortensen', 'Film Rings avec Viggo Mortensen', 29, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (120, 121, 122) AND ID_MOVIE NOT IN (14564, 91908)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Rings with Viggo Mortensen') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Taxi with Samy Naceri', 'Film Taxi avec Samy Naceri', 29, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (2330) AND ID_MOVIE NOT IN (2332, 2334, 2335, 11045)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Taxi with Samy Naceri') AS guard);

-- The new rows.
SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_SAMPLE, IS_SHOWCASE, ASSERTIONS_QUERY_RESULT
  FROM T_WC_T2S_EVALUATION
  WHERE QUESTION IN ('Movie Raid with Dany Boon', 'Movie Ch''tis with Dany Boon', 'Movie Asterix with Dany Boon',
                     'Movie Rings with Viggo Mortensen', 'Movie Taxi with Samy Naceri')
  ORDER BY ID_T2S_EVALUATION;
