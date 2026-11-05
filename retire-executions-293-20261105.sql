-- Retire the 1.1.20 executions of the person alias evaluations (2478, 2479, 2480, 2626, 2627,
-- 2628, 2629, English and French), so the evaluator re-runs them on the SAME version once the
-- Wikidata person aliases (TMDB-MOVIE-PREPROCESS-070, process 51) and the exact-match tie-break
-- (FASTAPI-TEXT2SQL-293) are live. 2026-11-05.
--
-- WHY. text2sql-eval.py skips any evaluation that already has a live execution row for the
-- same API_VERSION, models and LANG. Philippe keeps 1.1.20 (decision of 2026-11-05, few
-- evaluations to compare), so the 14 baseline rows are soft-deleted here; phase 10 of the next
-- run hard-deletes them. The evaluator sends retrieve_from_cache=False, so T_WC_T2S_CACHE cannot
-- shadow the change. Exports kept on the PC under
-- shared_data/text2sql-eval/evaluation_execution_archive/001.001.020_baseline-293_20261105/.
-- Baseline, same in both languages: green 2479, 2480, 2626, 2628, all four through the complex
-- model; red 2478 (Marion Morrison), 2627 (Maud Holt Tree), 2629 (Chu Kong).
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-293-20261105.sql
-- Expected: section 1 shows 7 rows per language, section 2 updates 14 rows, section 3 shows 0.

-- ===========================================================================
-- 1. What is there. Read-only: 7 rows per language expected.
-- ===========================================================================
SELECT LANG, COUNT(*) AS executions, MIN(TIM_EXECUTION) AS oldest, MAX(TIM_EXECUTION) AS newest
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (2478, 2479, 2480, 2626, 2627, 2628, 2629)
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
  AND ID_T2S_EVALUATION IN (2478, 2479, 2480, 2626, 2627, 2628, 2629);

-- ===========================================================================
-- 3. Check: nothing live is left for these ids on this tuple.
-- ===========================================================================
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (2478, 2479, 2480, 2626, 2627, 2628, 2629)
GROUP BY LANG;
