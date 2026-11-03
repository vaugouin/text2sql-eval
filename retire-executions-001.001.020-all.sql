-- Retire EVERY live 1.1.20 execution (all models, both languages), so the full campaign
-- replays the whole bank on 1.1.20 with the title lexicon switched on (FASTAPI-TEXT2SQL-360),
-- to compare with 1.1.19, which resolved titles through the ChromaDB embeddings. 2026-11-03.
--
-- WHY. text2sql-eval.py skips any evaluation that already has a live execution row for the
-- same API_VERSION, models and LANG. The 1.1.20 rows so far only validated one-off changes
-- (groups B and D of TEXT2SQL-EVAL-003, the -360 baseline of 12 questions); Philippe's
-- decision of 2026-11-03: replay everything on 1.1.20. Soft delete here; phase 10 of the next
-- run hard-deletes. The exports of these rows are kept on the PC under
-- shared_data/text2sql-eval/evaluation_execution_archive/001.001.020_run1_20261103/ and
-- 001.001.020_run2_20261103/.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-001.001.020-all.sql
-- Expected: section 1 lists the live rows (about 60 + 12 per language), section 2 updates them
-- all, section 3 shows nothing.

-- ===========================================================================
-- 1. What is there (read-only).
-- ===========================================================================
SELECT LANG, ENTITY_EXTRACTION_MODEL, TEXT2SQL_MODEL, COMPLEX_MODEL, RESULT_ENTITY_MODEL,
       COUNT(*) AS executions, MIN(TIM_EXECUTION) AS oldest, MAX(TIM_EXECUTION) AS newest
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
GROUP BY LANG, ENTITY_EXTRACTION_MODEL, TEXT2SQL_MODEL, COMPLEX_MODEL, RESULT_ENTITY_MODEL
ORDER BY LANG;

-- ===========================================================================
-- 2. Retire them. Soft delete only (DELETED = 1), what every evaluator query filters on.
-- ===========================================================================
UPDATE T_WC_T2S_EVALUATION_EXECUTION
SET DELETED = 1
WHERE DELETED = 0
  AND API_VERSION = '001.001.020';

-- ===========================================================================
-- 3. Check: nothing live is left on 1.1.20.
-- ===========================================================================
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
GROUP BY LANG;
