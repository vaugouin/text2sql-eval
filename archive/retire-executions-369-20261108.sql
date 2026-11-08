-- Retire the 1.1.20 executions of evaluations 2664 to 2668 (FASTAPI-TEXT2SQL-369, partial title
-- plus a named person), so the evaluator re-runs them on the SAME version with the collection
-- branch of the co-constrained rescue (fastapi-text2sql 2a4230c). 2026-11-08.
--
-- WHY. The targeted campaign of 2026-11-08 afternoon scored 9/10: 2666 FR failed because the
-- extraction reads "Astérix" as a collection and the collection lexicon picks the Animation one;
-- the API logs show the same reading on one English call in three, so the EN pass of 2666 was
-- not stable. The five pairs are re-run together as the closing measurement of -369.
-- text2sql-eval.py skips any evaluation that already has a live execution row for the same
-- API_VERSION, models and LANG. Soft delete; phase 10 of the next run hard-deletes them.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables), after the
-- Blue restart that loads 2a4230c:
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-369-20261108.sql
-- Expected: section 1 shows 5 evaluations per language, section 3 shows nothing.
--
-- THEN, the targeted campaign (both halves, rule of 2026-09-26):
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && EVAL_IDS=2664,2665,2666,2667,2668 ./text2sql-eval.sh
--   bash ~/docker/on-all.sh
-- Then the sync to the PC (voice-agent/doc/logs-download/sync_vps_docker.py).


SELECT LANG, COUNT(*) AS executions, COUNT(DISTINCT ID_T2S_EVALUATION) AS evaluations
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (2664, 2665, 2666, 2667, 2668)
GROUP BY LANG ORDER BY LANG;

UPDATE T_WC_T2S_EVALUATION_EXECUTION
SET DELETED = 1
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (2664, 2665, 2666, 2667, 2668);

SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (2664, 2665, 2666, 2667, 2668)
GROUP BY LANG;
