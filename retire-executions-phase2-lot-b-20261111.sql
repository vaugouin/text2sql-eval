-- Retire the 1.1.20 executions of the phase 2 lot B questions, so the evaluator re-runs them on the
-- SAME version once the API serves compare-cards, fact-card and verdict (fastapi-text2sql 421d1ea).
-- 2026-11-11. Written, not run.
--
-- WHICH. The thirty new evaluations 2840 to 2869 (no execution row yet unless a campaign ran them
-- before the API was pulled: then their rows carry the old representations and must go), and the
-- asserted questions whose representation flips under lot B: 2590 to 2599 (value-cards to
-- compare-cards) and 2582, 2588 (entity-page to fact-card).
--
-- WHY. No version bump (1.1.20 stays), and text2sql-eval.py skips any evaluation that already has a
-- live execution row for the same API_VERSION, models and LANG. The evaluator sends
-- retrieve_from_cache=false, so the cache rows are not read by the campaign. Soft delete; phase 10
-- of the next run hard-deletes them.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables), once the
-- colour in service runs 421d1ea (a pull and a restart of the API container, result_shape.py is not
-- hot-reloaded) and update-evaluations-phase2-lot-b-proposal.sql has been accepted and run:
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-phase2-lot-b-20261111.sql
-- Expected: section 1 shows 12 evaluations per language (2582, 2588, 2590 to 2599), 42 if a
-- campaign already ran the new ones; section 3 nothing.
--
-- THEN the campaign on the forty-two questions, both languages:
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && EVAL_IDS=2582,2588,2590,2591,2592,2593,2594,2595,2596,2597,2598,2599,2840,2841,2842,2843,2844,2845,2846,2847,2848,2849,2850,2851,2852,2853,2854,2855,2856,2857,2858,2859,2860,2861,2862,2863,2864,2865,2866,2867,2868,2869 ./text2sql-eval.sh
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
  AND (ID_T2S_EVALUATION IN (2582, 2588) OR ID_T2S_EVALUATION BETWEEN 2590 AND 2599
       OR ID_T2S_EVALUATION BETWEEN 2840 AND 2869)
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
  AND (ID_T2S_EVALUATION IN (2582, 2588) OR ID_T2S_EVALUATION BETWEEN 2590 AND 2599
       OR ID_T2S_EVALUATION BETWEEN 2840 AND 2869);

-- 3. Check: nothing live is left for the set on this tuple.
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND (ID_T2S_EVALUATION IN (2582, 2588) OR ID_T2S_EVALUATION BETWEEN 2590 AND 2599
       OR ID_T2S_EVALUATION BETWEEN 2840 AND 2869)
GROUP BY LANG ORDER BY LANG;
