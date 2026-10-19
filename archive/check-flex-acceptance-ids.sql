-- Read-only. English evaluation ids NOT yet executed for the production configuration
-- (API 1.1.19, gpt-6-sol / gpt-6-sol / gpt-6.1-sol, result entity gpt-6-luna, answer single
-- value gpt-4o or NULL), same eligibility filter as phase 11. Passed as EVAL_IDS with
-- FLEX_PROCESSING=--flex-processing, they make the TEXT2SQL-EVAL-002 acceptance campaign
-- actually call the API: Flex is not part of the skip key, so ids already run at the standard
-- tier (2245, 364, 71 on 2026-10-19) are skipped and nothing runs in Flex.
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT '1. Eligible English ids not yet run in this configuration' AS SECTION;
SELECT COUNT(*) AS N_TO_RUN
FROM T_WC_T2S_EVALUATION e
WHERE e.IS_EVAL = 1 AND e.DELETED = 0
  AND ( (e.ASSERTIONS_QUERY_RESULT <> '' AND e.ASSERTIONS_QUERY_RESULT IS NOT NULL)
     OR (e.ASSERTIONS_ENTITY_EXTRACTION <> '' AND e.ASSERTIONS_ENTITY_EXTRACTION IS NOT NULL)
     OR (e.ASSERTIONS_SQL_QUERY <> '' AND e.ASSERTIONS_SQL_QUERY IS NOT NULL) )
  AND e.QUESTION IS NOT NULL AND e.QUESTION <> ''
  AND e.ID_T2S_EVALUATION NOT IN (
    SELECT x.ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION_EXECUTION x
    WHERE x.DELETED = 0 AND x.API_VERSION = '001.001.019'
      AND x.ENTITY_EXTRACTION_MODEL = 'gpt-6-sol' AND x.TEXT2SQL_MODEL = 'gpt-6-sol'
      AND x.COMPLEX_MODEL = 'gpt-6.1-sol' AND x.RESULT_ENTITY_MODEL = 'gpt-6-luna'
      AND (x.ANSWER_SINGLE_VALUE_MODEL = 'gpt-4o' OR x.ANSWER_SINGLE_VALUE_MODEL IS NULL)
      AND x.LANG = 'en');

SELECT '2. The first of them, with their declared resolution mode' AS SECTION;
SELECT e.ID_T2S_EVALUATION, e.RESOLUTION_MODE, LEFT(e.QUESTION, 80) AS QUESTION
FROM T_WC_T2S_EVALUATION e
WHERE e.IS_EVAL = 1 AND e.DELETED = 0
  AND ( (e.ASSERTIONS_QUERY_RESULT <> '' AND e.ASSERTIONS_QUERY_RESULT IS NOT NULL)
     OR (e.ASSERTIONS_ENTITY_EXTRACTION <> '' AND e.ASSERTIONS_ENTITY_EXTRACTION IS NOT NULL)
     OR (e.ASSERTIONS_SQL_QUERY <> '' AND e.ASSERTIONS_SQL_QUERY IS NOT NULL) )
  AND e.QUESTION IS NOT NULL AND e.QUESTION <> ''
  AND e.ID_T2S_EVALUATION NOT IN (
    SELECT x.ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION_EXECUTION x
    WHERE x.DELETED = 0 AND x.API_VERSION = '001.001.019'
      AND x.ENTITY_EXTRACTION_MODEL = 'gpt-6-sol' AND x.TEXT2SQL_MODEL = 'gpt-6-sol'
      AND x.COMPLEX_MODEL = 'gpt-6.1-sol' AND x.RESULT_ENTITY_MODEL = 'gpt-6-luna'
      AND (x.ANSWER_SINGLE_VALUE_MODEL = 'gpt-4o' OR x.ANSWER_SINGLE_VALUE_MODEL IS NULL)
      AND x.LANG = 'en')
ORDER BY e.ID_T2S_EVALUATION
LIMIT 15;
