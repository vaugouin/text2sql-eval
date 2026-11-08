-- Retire the 1.1.20 executions of evaluations 2692 to 2704 (FASTAPI-TEXT2SQL-372, a described
-- person returns the namesake born the same year, or nobody when the model's birth year is off),
-- so the evaluator re-runs them on the SAME version with fastapi-text2sql 0038f39 live on Blue.
-- 2026-11-08.
--
-- WHY. Baseline of the 2026-11-08 campaign: persons 0/24 (two rows on ten descriptions, zero on
-- Chris Williams and Bob Nelson), control 2704 green. text2sql-eval.py skips any evaluation that
-- already has a live execution row for the same API_VERSION, models and LANG. Soft delete; phase
-- 10 of the next run hard-deletes them. The series 2679 to 2691 (24/24) are not retired.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables), once Blue
-- reports bktrees_ready: true:
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-372-20261108.sql
-- Expected: section 1 shows 13 evaluations per language, section 3 shows nothing.
--
-- THEN, the targeted campaign (both halves, rule of 2026-09-26):
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && EVAL_IDS=2692,2693,2694,2695,2696,2697,2698,2699,2700,2701,2702,2703,2704 ./text2sql-eval.sh
--   bash ~/docker/on-all.sh
-- Then the sync to the PC (voice-agent/doc/logs-download/sync_vps_docker.py).
-- Expected: 2692 to 2703 one row each, the asserted person, in EN and FR; 2704 still two rows.


SELECT LANG, COUNT(*) AS executions, COUNT(DISTINCT ID_T2S_EVALUATION) AS evaluations
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION BETWEEN 2692 AND 2704
GROUP BY LANG ORDER BY LANG;

UPDATE T_WC_T2S_EVALUATION_EXECUTION
SET DELETED = 1
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION BETWEEN 2692 AND 2704;

SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION BETWEEN 2692 AND 2704
GROUP BY LANG;
