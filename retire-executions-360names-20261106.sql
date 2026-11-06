-- Retire the 1.1.20 executions of the 114 evaluations that mention a company, a network or a
-- collection, so the evaluator re-runs them on the SAME version once the second wave of
-- FASTAPI-TEXT2SQL-360 (name lexicon before ChromaDB for Company_name and Network_name, between
-- RapidFuzz and ChromaDB for Collection_name, API 9485a1f) is live on Blue. 2026-11-06.
-- The ids are every evaluation with such a mention in the execution exports of any version
-- (fastapi-text2sql checks/bench-lexical-360-names.py, column eids), 2653 to 2662 included.
-- Expected: 2654 Columbia, 2655 Warner Bros, 2656 Universal turn green; 2653 Paramount and 2657
-- Hammer pass without the complex model; nothing that passed fails.
--
-- WHY. text2sql-eval.py skips any evaluation that already has a live execution row for the
-- same API_VERSION, models and LANG, and Philippe keeps 1.1.20. Soft delete; phase 10 of the
-- next run hard-deletes them. Exports kept on the PC under
-- shared_data/text2sql-eval/evaluation_execution_archive/001.001.020_baseline-360names_20261106/.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-360names-20261106.sql
-- Expected: section 1 shows about 114 evaluations per language, section 3 shows 0.

-- 1. What is there.
SELECT LANG, COUNT(*) AS executions, COUNT(DISTINCT ID_T2S_EVALUATION) AS evaluations
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (11, 16, 19, 24, 25, 33, 37, 44, 45, 46, 60, 62, 63, 72, 76, 96, 120, 129, 176, 202, 208, 221, 222, 262, 290, 292, 293, 339, 352, 366, 416, 444, 446, 470, 493, 511, 718, 723, 748, 760, 825, 841, 881, 961, 986, 1064, 1123, 1127, 1129, 2133, 2136, 2140, 2141, 2158, 2191, 2192, 2196, 2198, 2199, 2216, 2244, 2255, 2273, 2277, 2297, 2340, 2346, 2347, 2454, 2455, 2499, 2500, 2507, 2508, 2523, 2554, 2555, 2556, 2557, 2560, 2561, 2562, 2564, 2565, 2567, 2568, 2570, 2573, 2575, 2578, 2579, 2581, 2586, 2600, 2601, 2602, 2603, 2604, 2606, 2607, 2608, 2609, 2615, 2618, 2653, 2654, 2655, 2656, 2657, 2658, 2659, 2660, 2661, 2662)
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
  AND ID_T2S_EVALUATION IN (11, 16, 19, 24, 25, 33, 37, 44, 45, 46, 60, 62, 63, 72, 76, 96, 120, 129, 176, 202, 208, 221, 222, 262, 290, 292, 293, 339, 352, 366, 416, 444, 446, 470, 493, 511, 718, 723, 748, 760, 825, 841, 881, 961, 986, 1064, 1123, 1127, 1129, 2133, 2136, 2140, 2141, 2158, 2191, 2192, 2196, 2198, 2199, 2216, 2244, 2255, 2273, 2277, 2297, 2340, 2346, 2347, 2454, 2455, 2499, 2500, 2507, 2508, 2523, 2554, 2555, 2556, 2557, 2560, 2561, 2562, 2564, 2565, 2567, 2568, 2570, 2573, 2575, 2578, 2579, 2581, 2586, 2600, 2601, 2602, 2603, 2604, 2606, 2607, 2608, 2609, 2615, 2618, 2653, 2654, 2655, 2656, 2657, 2658, 2659, 2660, 2661, 2662);

-- 3. Check: nothing live is left for these ids on this tuple.
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (11, 16, 19, 24, 25, 33, 37, 44, 45, 46, 60, 62, 63, 72, 76, 96, 120, 129, 176, 202, 208, 221, 222, 262, 290, 292, 293, 339, 352, 366, 416, 444, 446, 470, 493, 511, 718, 723, 748, 760, 825, 841, 881, 961, 986, 1064, 1123, 1127, 1129, 2133, 2136, 2140, 2141, 2158, 2191, 2192, 2196, 2198, 2199, 2216, 2244, 2255, 2273, 2277, 2297, 2340, 2346, 2347, 2454, 2455, 2499, 2500, 2507, 2508, 2523, 2554, 2555, 2556, 2557, 2560, 2561, 2562, 2564, 2565, 2567, 2568, 2570, 2573, 2575, 2578, 2579, 2581, 2586, 2600, 2601, 2602, 2603, 2604, 2606, 2607, 2608, 2609, 2615, 2618, 2653, 2654, 2655, 2656, 2657, 2658, 2659, 2660, 2661, 2662)
GROUP BY LANG;
