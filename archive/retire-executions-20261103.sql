-- Retire the first 1.1.20 executions of groups B and D of TEXT2SQL-EVAL-003 (evaluations
-- 2570 to 2579 and 2590 to 2599, English and French), so the evaluator re-runs them on the
-- SAME version after the prompt fixes of FASTAPI-TEXT2SQL-356 (plural superlative) and -362
-- (comparison dropped for the technical formats). 2026-11-03.
--
-- WHY. text2sql-eval.py skips any evaluation that already has a live execution row for the
-- same API_VERSION, the same models and the same LANG (the `strnotinbase` subquery). Philippe
-- keeps 1.1.20 on Blue (decision of 2026-11-03), so the 40 rows of the first run (2026-11-03,
-- 10:09 to 10:16) are soft-deleted here; phase 10 of the next run hard-deletes them. Their
-- exports are kept on the PC under
-- shared_data/text2sql-eval/evaluation_execution_archive/001.001.020_run1_20261103/.
-- The other 20 questions of the subset (2560-2569, 2580-2589, 2600-2619) keep their rows.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/archive/retire-executions-20261103.sql
-- Expected: section 1 shows 20 rows per language, section 2 updates 40 rows, section 3 shows 0.
-- Then the rerun, one language at a time:
--   API_VERSION=1.1.20 EVAL_LANGUAGE=en EVAL_IDS=$(seq -s, 2570 2579),$(seq -s, 2590 2599) ./text2sql-eval.sh
--   API_VERSION=1.1.20 EVAL_LANGUAGE=fr EVAL_IDS=$(seq -s, 2570 2579),$(seq -s, 2590 2599) ./text2sql-eval.sh

-- ===========================================================================
-- 1. What is there. Read-only: 20 rows per language expected.
-- ===========================================================================
SELECT LANG, COUNT(*) AS executions, MIN(TIM_EXECUTION) AS oldest, MAX(TIM_EXECUTION) AS newest
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION BETWEEN 2570 AND 2599
  AND ID_T2S_EVALUATION NOT BETWEEN 2580 AND 2589
GROUP BY LANG
ORDER BY LANG;

-- ===========================================================================
-- 2. Retire them. Soft delete only (DELETED = 1), what every evaluator query filters on.
-- ===========================================================================
UPDATE T_WC_T2S_EVALUATION_EXECUTION
SET DELETED = 1
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION BETWEEN 2570 AND 2599
  AND ID_T2S_EVALUATION NOT BETWEEN 2580 AND 2589;

-- ===========================================================================
-- 3. Check: nothing live is left for these ids on this tuple, the other 40 rows of the
--    subset are untouched (20 per language).
-- ===========================================================================
SELECT LANG,
       SUM(ID_T2S_EVALUATION BETWEEN 2570 AND 2599 AND ID_T2S_EVALUATION NOT BETWEEN 2580 AND 2589) AS retired_group_still_live,
       SUM(ID_T2S_EVALUATION NOT BETWEEN 2570 AND 2599 OR ID_T2S_EVALUATION BETWEEN 2580 AND 2589) AS other_rows_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION BETWEEN 2560 AND 2619
GROUP BY LANG
ORDER BY LANG;
