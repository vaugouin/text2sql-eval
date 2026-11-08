-- Retire the 1.1.20 executions of the 82 questions labelled with `intent.task`, so the evaluator
-- re-runs them on the SAME version with FASTAPI-TEXT2SQL-353/-354 (fastapi-text2sql 9906b49:
-- the intent classifier, value-cards, rankings by intent, representation_options,
-- summary_facts). 2026-11-08.
--
-- WHY. Philippe keeps 1.1.20 for phase 1 (no 1.2.0, no new campaign tuple), and text2sql-eval.py
-- skips any evaluation that already has a live execution row for the same API_VERSION, models
-- and LANG: without this file the campaign would run nothing. The set is read from the bank
-- itself (every ASSERTIONS_RESULT_SHAPE that carries an intent.task clause,
-- update-evaluations-intent-task.sql), so it cannot drift from the labels. The evaluator sends
-- retrieve_from_cache=false, so the classifier runs on every call; the cached SQL rows of
-- 1.1.20 are not read. Soft delete; phase 10 of the next run hard-deletes them. The old export
-- files stay on the PC; check-result-shape.py reads the latest row per question.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-intent-20261108.sql
-- Expected: section 0 shows 82, section 1 about 82 executions per language, section 3 nothing.
--
-- THEN, the campaign on the 82 (both halves, rule of 2026-09-26), once Blue runs 9906b49:
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && ./text2sql-eval.sh
--   bash ~/docker/on-all.sh
-- The pre-flight must announce about 82 calls left per language; anything far above means other
-- questions lost their row, stop and check. Then the sync to the PC
-- (voice-agent/doc/logs-download/sync_vps_docker.py) and check-result-shape.py on the two exports.

-- 0. The labelled set.
SELECT COUNT(*) AS labelled
FROM T_WC_T2S_EVALUATION
WHERE ASSERTIONS_RESULT_SHAPE LIKE '%intent.task%';

-- 1. What is there.
SELECT LANG, COUNT(*) AS executions, COUNT(DISTINCT ID_T2S_EVALUATION) AS evaluations
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (
      SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
      WHERE ASSERTIONS_RESULT_SHAPE LIKE '%intent.task%')
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
  AND ID_T2S_EVALUATION IN (
      SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
      WHERE ASSERTIONS_RESULT_SHAPE LIKE '%intent.task%');

-- 3. Check: nothing live is left for the labelled set on this tuple.
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (
      SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
      WHERE ASSERTIONS_RESULT_SHAPE LIKE '%intent.task%')
GROUP BY LANG;
