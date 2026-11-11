-- Retire the 1.1.20 executions of the sequence, trend and timeline questions (2600 to 2619, 2721 to
-- 2730), so the evaluator re-runs them on the SAME version with the prompt fix of
-- FASTAPI-TEXT2SQL-376 to -378 (fastapi-text2sql 45bacfa). 2026-11-11.
--
-- WHY. No version bump (1.1.20 stays), and text2sql-eval.py skips any evaluation that already has a
-- live execution row for the same API_VERSION, models and LANG. The new evaluations 2830 to 2839
-- have no row yet and run anyway. The evaluator sends retrieve_from_cache=false, so the 1.1.20 cache
-- rows are not read by the campaign (fastapi-text2sql maintenance/cache-retire-376-378.sql is for the
-- users of the fronts). Soft delete; phase 10 of the next run hard-deletes them.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables), once Blue
-- runs 45bacfa (a pull, the prompts hot-reload, no restart):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-376-378-20261111.sql
-- Expected: section 1 shows 30 evaluations per language, section 3 nothing.
--
-- THEN the campaign on the forty questions, both languages:
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && EVAL_IDS=2600,2601,2602,2603,2604,2605,2606,2607,2608,2609,2610,2611,2612,2613,2614,2615,2616,2617,2618,2619,2721,2722,2723,2724,2725,2726,2727,2728,2729,2730,2830,2831,2832,2833,2834,2835,2836,2837,2838,2839 ./text2sql-eval.sh
--   bash ~/docker/on-all.sh
-- (EVAL_IDS takes explicit ids, no ranges.) Then the sync to the PC and check-result-shape.py.

-- 1. What is there.
SELECT LANG, COUNT(*) AS executions, COUNT(DISTINCT ID_T2S_EVALUATION) AS evaluations
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND (ID_T2S_EVALUATION BETWEEN 2600 AND 2619 OR ID_T2S_EVALUATION BETWEEN 2721 AND 2730)
GROUP BY LANG ORDER BY LANG;

-- 2. Retire them (soft delete).
UPDATE T_WC_T2S_EVALUATION_EXECUTION
SET DELETED = 1
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND (ID_T2S_EVALUATION BETWEEN 2600 AND 2619 OR ID_T2S_EVALUATION BETWEEN 2721 AND 2730);

-- 3. Check: nothing live is left for the set on this tuple.
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND (ID_T2S_EVALUATION BETWEEN 2600 AND 2619 OR ID_T2S_EVALUATION BETWEEN 2721 AND 2730)
GROUP BY LANG ORDER BY LANG;
