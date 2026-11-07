-- Retire the 1.1.20 executions of evaluation 2591 ("Compare the budgets of Avatar (2009) and
-- Avengers: Endgame" and its French twin), so the evaluator re-runs it on the SAME version with
-- the French comparison examples of FASTAPI-TEXT2SQL-362 (prompt ec56c9d, live on Blue since
-- 2026-11-05 evening). 2026-11-07.
--
-- WHY. The full campaign of 2026-11-04/05 ran 2591 before the fix: the French row (17400) still
-- lists six technical formats the two films share, score 0; the English row (17399) passes and
-- is re-run as the regression check of the new sentence. The second wave of FASTAPI-TEXT2SQL-360
-- (2026-11-06) re-ran 2554 to 2557 but not 2591. text2sql-eval.py skips any evaluation that
-- already has a live execution row for the same API_VERSION, models and LANG, and Philippe keeps
-- 1.1.20. Soft delete; phase 10 of the next run hard-deletes them. The two export files of the
-- retired rows stay on the PC; check-result-shape.py and the analysis scripts read the latest
-- row per question, so they are harmless.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-2591-20261107.sql
-- Expected: section 1 shows one execution per language, section 3 shows nothing.
--
-- THEN, the targeted campaign (both halves, rule of 2026-09-26), where <new> is the id given by
-- new-evaluations-20261107.sql (the Star Wars total, which has no row yet and needs no retire):
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && EVAL_IDS=2591,<new> ./text2sql-eval.sh
--   bash ~/docker/on-all.sh
-- Then the sync to the PC (voice-agent/doc/logs-download/sync_vps_docker.py).

-- 1. What is there.
SELECT LANG, COUNT(*) AS executions, COUNT(DISTINCT ID_T2S_EVALUATION) AS evaluations
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION = 2591
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
  AND ID_T2S_EVALUATION = 2591;

-- 3. Check: nothing live is left for 2591 on this tuple.
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION = 2591
GROUP BY LANG;
