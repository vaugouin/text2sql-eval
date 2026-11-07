-- New evaluation for FASTAPI-TEXT2SQL-364 (a question that asks for one total over a set of works
-- must return one row and one aggregate, never the entity rows with the total repeated on each).
-- Decided by Philippe on 2026-11-05 with lever (a) of the ticket, written 2026-11-07.
--
-- WHAT THIS FILE DOES
-- Adds "How many minutes of Star Wars films are there in total?" with its French twin, the
-- sibling of 2554 (Harry Potter, runtime) and 2556 (Harry Potter, revenue): same category (12,
-- movies complex queries), same assertions. The scored query_result requires ONE row whose first
-- cell is above 1000 minutes (the 'Star Wars Collection' of the base sums to 1675 minutes; the
-- nine saga films alone would run 1227), so the film rows, the collection row and a film id all
-- fail. The out-of-score result_shape locks the number-card, read by check-result-shape.py.
--
-- CHECKED ON BLUE (1.1.20, prompt ec56c9d) ON 2026-11-07 by direct calls without cache: both
-- languages answer `SELECT SUM(T_WC_T2S_MOVIE.RUNTIME) AS TOTAL_RUNTIME ... COLLECTION_NAME =
-- 'Star Wars Collection'`, one row, TOTAL_RUNTIME 1675, number-card, in 4 to 5 s. Nothing in the
-- bank asks this question yet (21 questions mention Star Wars: lookups, posters, characters, the
-- collection list, the budgets of 2568, none a total).
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1 (rule of 2026-10-31: every new question feeds the samples
-- page), IS_SHOWCASE = 0 (a single figure has no card to show).
--
-- ROUTING: one INSERT on T_WC_T2S_EVALUATION, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-20261107.sql
-- Commit and push before running. The next campaign's phase 31 refreshes the bank JSON; the
-- result of the SELECT below gives the new id for EVAL_IDS.
--
-- CONVENTIONS (as new-evaluations-20261031.sql): auto-increment id; the INSERT is guarded by NOT
-- EXISTS on the English QUESTION, so it fires once; DELETED = 0; DAT_CREAT = CURDATE(); owner 1;
-- `>` stored as &gt; in query_result; result_shape uses == only.

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many minutes of Star Wars films are there in total?', 'Combien de minutes de films Star Wars y a-t-il au total ?', 12, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt; 1000', 'result_kind == scalar; representation == number-card; unit(*) == minutes'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many minutes of Star Wars films are there in total?') AS guard);

-- The new row, with its two siblings for comparison.
SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_SAMPLE, IS_SHOWCASE, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE
  FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'How many minutes of Star Wars films are there in total?'
     OR ID_T2S_EVALUATION IN (2554, 2556)
  ORDER BY ID_T2S_EVALUATION;
