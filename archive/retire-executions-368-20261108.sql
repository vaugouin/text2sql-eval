-- Retire the 1.1.20 executions of evaluations 2630 to 2642 (FASTAPI-TEXT2SQL-368, the answer
-- sentence names the database id), so the evaluator re-runs them on the SAME version with the
-- fix d692ad3 already live on Blue. 2026-11-08.
--
-- WHY. The 1.1.20 exports of 2026-11-06 predate d692ad3: on 2630 to 2641 the answer reads
-- "Here is the movie matching identifier tt..." (EN 11 FAIL, FR 12 FAIL on the answer clause
-- written by update-evaluations-368-answer-identifier.sql, text2sql-eval 2.20.0). The re-run is
-- the closing measurement of -368. text2sql-eval.py skips any evaluation that already has a live
-- execution row for the same API_VERSION, models and LANG. Soft delete; phase 10 of the next run
-- hard-deletes them.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/archive/retire-executions-368-20261108.sql
-- Expected: section 1 shows 13 evaluations per language, section 3 shows nothing.
--
-- THEN, the targeted campaign (both halves, rule of 2026-09-26):
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && EVAL_IDS=2630,2631,2632,2633,2634,2635,2636,2637,2638,2639,2640,2641,2642 ./text2sql-eval.sh
--   bash ~/docker/on-all.sh
-- Then the sync to the PC (voice-agent/doc/logs-download/sync_vps_docker.py) and, on the PC,
-- check-result-shape.py on the two 1.1.20 tuples. Expected: answer clause 13 PASS per language,
-- answer invariant 0 FAIL.


SELECT LANG, COUNT(*) AS executions, COUNT(DISTINCT ID_T2S_EVALUATION) AS evaluations
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION BETWEEN 2630 AND 2642
GROUP BY LANG ORDER BY LANG;

UPDATE T_WC_T2S_EVALUATION_EXECUTION
SET DELETED = 1
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION BETWEEN 2630 AND 2642;

SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION BETWEEN 2630 AND 2642
GROUP BY LANG;
