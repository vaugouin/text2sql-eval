-- ============================================================================
-- GPT-6-007: free the escalated subset for the complex-question rerun on API 1.1.19
-- ============================================================================
--
-- Written 2026-10-15. The complex-question HOLD of 2026-10-04 is reopened with three changes
-- deployed in place on Green (no version bump):
--   - data/complex_question.md: rule "Topics, genres, types, lists and rankings: NEVER replace
--     the criterion with titles from memory" (Sol had turned 71, 501 and 2471 into recalled
--     titles), and the "try to reach 10" sentence scoped to descriptions;
--   - FASTAPI-TEXT2SQL-331: answer_single_value removed (2313 and 2349 no longer escalate
--     through it);
--   - text2sql-eval: an escalated row's entity extraction is scored on the first pass
--     (475 and 477 failed on the rewritten question's extraction with the right answer).
-- The prompt is shared by both arms, so BOTH must be replayed the same day: gpt-4o (the arm
-- production serves until the switch, retired by OpenAI on 2027-01-14) and gpt-6-sol. The
-- third arm, gpt-6.1-sol, has no row yet and needs nothing here.
--
-- The ids are the subset of the 2026-10-03 run (baseline escalated plus RESOLUTION_MODE
-- complex): EN 56, FR 79, read from the gpt-6-sol subset exports. The evaluator skips every
-- question that already has a row for the same (API version, five models, language):
-- DELETED = 1 frees it, phase 10 hard-deletes it at the start of the next run. The "before"
-- stays readable in shared_data/text2sql-eval/evaluation_execution/001.001.019_*_re-gpt-6-luna/.
--
-- Writes T_WC_T2S_EVALUATION_EXECUTION, so it runs under Philippe's account (voie 2):
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/rerun-gpt-6-007.sql
-- The campaign commands follow in GPT-6-007 (topics/gpt-6-migration.md).
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT 'B0. Before: live rows of the subset, per arm and language' AS SECTION;
SELECT LANG, COMPLEX_MODEL, COUNT(*) AS ROWS_COUNT, SUM(ASSERTIONS_TOTAL_SCORE = 1) AS PASSED
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE API_VERSION = '001.001.019'
  AND (DELETED IS NULL OR DELETED = 0)
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol' AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL IN ('gpt-4o', 'gpt-6-sol') AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND (ANSWER_SINGLE_VALUE_MODEL = 'gpt-4o' OR ANSWER_SINGLE_VALUE_MODEL IS NULL)
  AND ((LANG = 'en' AND ID_T2S_EVALUATION IN (17,32,59,62,72,84,118,197,202,292,470,475,477,478,723,748,760,942,957,965,1048,1057,1070,1112,1123,1130,2137,2194,2224,2245,2261,2262,2268,2269,2273,2285,2288,2304,2305,2313,2337,2349,2458,2479,2480,2482,2483,2484,2490,2491,2492,2493,2494,2495,2496,2497))
    OR (LANG = 'fr' AND ID_T2S_EVALUATION IN (16,17,32,34,59,62,71,72,109,118,202,292,364,470,501,502,597,748,757,760,835,849,851,923,942,957,967,1033,1035,1048,1051,1057,1082,1112,1123,1130,2134,2135,2137,2193,2204,2224,2245,2261,2262,2268,2269,2270,2273,2275,2285,2290,2296,2304,2305,2309,2310,2311,2313,2349,2449,2452,2458,2471,2474,2479,2480,2482,2483,2484,2490,2491,2492,2493,2494,2495,2496,2497,2508)))
GROUP BY LANG, COMPLEX_MODEL
ORDER BY LANG, COMPLEX_MODEL;

UPDATE T_WC_T2S_EVALUATION_EXECUTION
SET DELETED = 1
WHERE API_VERSION = '001.001.019'
  AND (DELETED IS NULL OR DELETED = 0)
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol' AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL IN ('gpt-4o', 'gpt-6-sol') AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND (ANSWER_SINGLE_VALUE_MODEL = 'gpt-4o' OR ANSWER_SINGLE_VALUE_MODEL IS NULL)
  AND ((LANG = 'en' AND ID_T2S_EVALUATION IN (17,32,59,62,72,84,118,197,202,292,470,475,477,478,723,748,760,942,957,965,1048,1057,1070,1112,1123,1130,2137,2194,2224,2245,2261,2262,2268,2269,2273,2285,2288,2304,2305,2313,2337,2349,2458,2479,2480,2482,2483,2484,2490,2491,2492,2493,2494,2495,2496,2497))
    OR (LANG = 'fr' AND ID_T2S_EVALUATION IN (16,17,32,34,59,62,71,72,109,118,202,292,364,470,501,502,597,748,757,760,835,849,851,923,942,957,967,1033,1035,1048,1051,1057,1082,1112,1123,1130,2134,2135,2137,2193,2204,2224,2245,2261,2262,2268,2269,2270,2273,2275,2285,2290,2296,2304,2305,2309,2310,2311,2313,2349,2449,2452,2458,2471,2474,2479,2480,2482,2483,2484,2490,2491,2492,2493,2494,2495,2496,2497,2508)));

SELECT 'A0. After: the same rows, now freed (DELETED = 1); expect the B0 counts' AS SECTION;
SELECT LANG, COMPLEX_MODEL, COUNT(*) AS ROWS_COUNT
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE API_VERSION = '001.001.019'
  AND DELETED = 1
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol' AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL IN ('gpt-4o', 'gpt-6-sol') AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND (ANSWER_SINGLE_VALUE_MODEL = 'gpt-4o' OR ANSWER_SINGLE_VALUE_MODEL IS NULL)
  AND ((LANG = 'en' AND ID_T2S_EVALUATION IN (17,32,59,62,72,84,118,197,202,292,470,475,477,478,723,748,760,942,957,965,1048,1057,1070,1112,1123,1130,2137,2194,2224,2245,2261,2262,2268,2269,2273,2285,2288,2304,2305,2313,2337,2349,2458,2479,2480,2482,2483,2484,2490,2491,2492,2493,2494,2495,2496,2497))
    OR (LANG = 'fr' AND ID_T2S_EVALUATION IN (16,17,32,34,59,62,71,72,109,118,202,292,364,470,501,502,597,748,757,760,835,849,851,923,942,957,967,1033,1035,1048,1051,1057,1082,1112,1123,1130,2134,2135,2137,2193,2204,2224,2245,2261,2262,2268,2269,2270,2273,2275,2285,2290,2296,2304,2305,2309,2310,2311,2313,2349,2449,2452,2458,2471,2474,2479,2480,2482,2483,2484,2490,2491,2492,2493,2494,2495,2496,2497,2508)))
GROUP BY LANG, COMPLEX_MODEL
ORDER BY LANG, COMPLEX_MODEL;
