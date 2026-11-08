-- Retire the 1.1.20 executions of evaluations 2669 to 2678 (series and bare-surname pairs of
-- FASTAPI-TEXT2SQL-369/-371), so the evaluator re-runs them on the SAME version with the person
-- rescue of FASTAPI-TEXT2SQL-371 (fastapi-text2sql 1cb4345). 2026-11-08.
--
-- WHY. The baseline campaign of 2026-11-08 evening scored 14/20: the series pass (10/10), the
-- bare surnames fail 6 times (2674 Grant, 2676 Phoenix, 2678 Jackson, EN and FR) and 2675, 2677
-- pass only through the stronger model. text2sql-eval.py skips any evaluation that already has
-- a live execution row for the same API_VERSION, models and LANG. Soft delete; phase 10 of the
-- next run hard-deletes them.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables), after the
-- Blue restart that loads 1cb4345:
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-371-20261108.sql
-- Expected: section 1 shows 10 evaluations per language, section 3 shows nothing.
--
-- THEN, the targeted campaign:
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && EVAL_IDS=2669,2670,2671,2672,2673,2674,2675,2676,2677,2678 ./text2sql-eval.sh
--   bash ~/docker/on-all.sh


SELECT LANG, COUNT(*) AS executions, COUNT(DISTINCT ID_T2S_EVALUATION) AS evaluations
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (2669, 2670, 2671, 2672, 2673, 2674, 2675, 2676, 2677, 2678)
GROUP BY LANG ORDER BY LANG;

UPDATE T_WC_T2S_EVALUATION_EXECUTION
SET DELETED = 1
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (2669, 2670, 2671, 2672, 2673, 2674, 2675, 2676, 2677, 2678);

SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (2669, 2670, 2671, 2672, 2673, 2674, 2675, 2676, 2677, 2678)
GROUP BY LANG;
