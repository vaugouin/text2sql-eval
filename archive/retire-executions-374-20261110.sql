-- Retire the French 1.1.20 executions of evaluations 2712 and 2713 (FASTAPI-TEXT2SQL-374, a
-- French award name resolved to another award), so the evaluator re-runs them on the SAME
-- version with the exact award lexicon live on Blue (fastapi-text2sql 4e1a971, switched on by
-- b1f4dea). 2026-11-10.
--
-- WHY. Both rows (20498 and 20500) were written on 2026-11-10 before the fix: "Oscar de la
-- meilleure actrice" resolved to 'Ophir de la meilleure actrice', 0 rows, score 0. The ticket
-- is closed by its control 2731, green in both languages, and direct calls (cache off, before
-- and after the restart of Blue) show both questions answered: Katharine Hepburn alone for
-- 1982, and her four films. text2sql-eval.py skips any evaluation that already has a live
-- execution row for the same API_VERSION, models and LANG, so the two failures weigh on the
-- 1.1.20 score until they are replayed. Soft delete; phase 10 of the next run hard-deletes
-- them. The English rows of 2712 and 2713 pass and are not retired.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-374-20261110.sql
-- Expected: section 1 shows fr, 2 executions, 2 evaluations; section 3 shows nothing.
--
-- THEN, the targeted campaign (both halves, rule of 2026-09-26; never at midnight nor between
-- 06:00 and 07:30):
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && EVAL_IDS=2712,2713 EVAL_LANGUAGE=fr ./text2sql-eval.sh
--   bash ~/docker/on-all.sh
-- Then the sync to the PC (voice-agent/doc/logs-download/sync_vps_docker.py).
-- Expected: 2712 FR one row, ID_PERSON 6598; 2713 FR four films (1879, 11816, 18988, 31777).

-- 1. What is there.
SELECT LANG, COUNT(*) AS executions, COUNT(DISTINCT ID_T2S_EVALUATION) AS evaluations
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND LANG = 'fr'
  AND ID_T2S_EVALUATION IN (2712, 2713)
GROUP BY LANG ORDER BY LANG;

-- 2. Retire them.
UPDATE T_WC_T2S_EVALUATION_EXECUTION
SET DELETED = 1
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND LANG = 'fr'
  AND ID_T2S_EVALUATION IN (2712, 2713);

-- 3. Nothing must be left.
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND LANG = 'fr'
  AND ID_T2S_EVALUATION IN (2712, 2713)
GROUP BY LANG;
