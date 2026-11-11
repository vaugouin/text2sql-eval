-- Retire the 1.1.20 executions of the phase 2 lot C questions, so the evaluator re-runs them on the
-- SAME version once the API serves histogram, share-bar and flag-list (fastapi-text2sql, phase 2
-- lot C). 2026-11-11. Written, not run.
--
-- WHICH. The thirty new evaluations 2870 to 2899 (no execution row yet unless a campaign ran them
-- before the API was pulled: then their rows carry the old representations and must go), and the
-- asserted questions whose representation flips under lot C: 2559 and 2577 (ranked-bars to
-- flag-list).
--
-- WHY. No version bump (1.1.20 stays), and text2sql-eval.py skips any evaluation that already has a
-- live execution row for the same API_VERSION, models and LANG. The evaluator sends
-- retrieve_from_cache=false, so the cache rows are not read by the campaign. Soft delete; phase 10
-- of the next run hard-deletes them.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables), once the
-- colour in service runs lot C (a pull and a restart of the API container: result_shape.py,
-- result_intent.py and result_countries.py are not hot-reloaded; data/text_to_sql.md is) and
-- update-evaluations-phase2-lot-c-proposal.sql has been accepted and run:
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-phase2-lot-c-20261111.sql
-- Expected: section 1 shows 2 evaluations per language (2559, 2577), 32 if a campaign already ran
-- the new ones; section 3 nothing.
--
-- THEN the campaign on the thirty-two questions, both languages:
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && EVAL_IDS=2559,2577,2870,2871,2872,2873,2874,2875,2876,2877,2878,2879,2880,2881,2882,2883,2884,2885,2886,2887,2888,2889,2890,2891,2892,2893,2894,2895,2896,2897,2898,2899 ./text2sql-eval.sh
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
  AND (ID_T2S_EVALUATION IN (2559, 2577) OR ID_T2S_EVALUATION BETWEEN 2870 AND 2899)
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
  AND (ID_T2S_EVALUATION IN (2559, 2577) OR ID_T2S_EVALUATION BETWEEN 2870 AND 2899);

-- 3. Check: nothing live is left for the set on this tuple.
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND (ID_T2S_EVALUATION IN (2559, 2577) OR ID_T2S_EVALUATION BETWEEN 2870 AND 2899)
GROUP BY LANG ORDER BY LANG;
