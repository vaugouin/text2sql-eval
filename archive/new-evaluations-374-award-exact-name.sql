-- Control evaluation for FASTAPI-TEXT2SQL-374: an award name written exactly as it stands in the
-- base must resolve to that award. Written on 2026-11-10, before the fix is switched on.
--
-- THE DEFECT TO MEASURE. "Oscar de la meilleure actrice" is the exact AWARD_NAME_FR of
-- ID_AWARD 269 (Academy Award for Best Actress). The API resolved it through the embeddings
-- alone and returned 'Ophir de la meilleure actrice' (ID_AWARD 15014, the Israeli award): the
-- right document was not in the ten nearest. 2712 and 2713 in French already fail on it, but
-- they also need a year and a work; this question isolates the name: no year, no film, no
-- person named.
--
-- WHAT THIS FILE DOES. One question with its French twin (category 49, persons and awards):
--   Who won the Academy Award for Best Actress? / Qui a remporté l'Oscar de la meilleure actrice ?
--
-- ASSERTION, on what was missing, not on the answer observed.
--   ID_PERSON IN (6598): Katharine Hepburn, four wins, the anchor of 2712 and 2713.
--   ID_PERSON NOT IN (8786, 765, 19942): Ayelet Zurer, Hiam Abbass, Ronit Elkabetz, three
--     winners of the Ophir who never won the Oscar (no person won both). Their presence means the
--     Ophir was resolved, or added to the Oscar.
--   COUNT(*) > 50: 82 persons and 100 win rows today for the Oscar, 21 persons and 24 rows for
--     the Ophir. The evaluator reads the first 100 rows, which holds either form of the answer
--     (one row per winner, or one row per win with its year).
-- No SQL assertion: the award may be reached by AWARD_NAME or AWARD_NAME_FR.
-- RESOLUTION_MODE = 'standard': the answer must come from the SQL result.
--
-- IDS: read on 2026-11-10 in check-374-ids-20261110.txt.
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1, IS_SHOWCASE = 0 (a list).
--
-- ROUTING: one INSERT on T_WC_T2S_EVALUATION, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-374-award-exact-name.sql
--
-- CONVENTIONS (as new-evaluations-preprocess-071-award-wins.sql): auto-increment id; the INSERT
-- is guarded by NOT EXISTS on the English QUESTION; DELETED = 0; DAT_CREAT = CURDATE(); owner 1.
-- No backslash anywhere (a MariaDB string literal would eat it).

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, RESOLUTION_MODE, ASSERTIONS_QUERY_RESULT)
SELECT 'Who won the Academy Award for Best Actress?',
       'Qui a remporté l''Oscar de la meilleure actrice ?',
       49, 1, 1, 0, 0, CURDATE(), 1, 1, 'standard',
       'COUNT(*) > 50 AND ID_PERSON IN (6598) AND ID_PERSON NOT IN (8786, 765, 19942)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Who won the Academy Award for Best Actress?') AS guard);

-- The new row.
SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, RESOLUTION_MODE, IS_SAMPLE, IS_SHOWCASE, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY
  FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Who won the Academy Award for Best Actress?'
  ORDER BY ID_T2S_EVALUATION;
