-- Read-only. Rows written by the TEXT2SQL-EVAL-002 acceptance campaign of 2026-10-19
-- (FLEX_PROCESSING=--flex-processing EVAL_IDS=1,2,3 EVAL_LANGUAGE=en): Flex columns and the
-- tier OpenAI served per task, as stored in JSON_RESULT. Every Flex row, with its date.
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT ID_ROW, ID_T2S_EVALUATION, LANG, DAT_CREAT, TIM_UPDATED, FLEX_PROCESSING, FLEX_FALLBACK_COUNT,
       JSON_UNQUOTE(JSON_EXTRACT(JSON_RESULT, '$.flex_processing')) AS API_ECHO,
       JSON_UNQUOTE(JSON_EXTRACT(JSON_RESULT, '$.llm_usage.entity_extraction.service_tier')) AS EE_TIER,
       JSON_UNQUOTE(JSON_EXTRACT(JSON_RESULT, '$.llm_usage.text2sql.service_tier')) AS T2S_TIER,
       JSON_UNQUOTE(JSON_EXTRACT(JSON_RESULT, '$.llm_usage.result_entity.service_tier')) AS RE_TIER
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE FLEX_PROCESSING = 1
ORDER BY ID_ROW;

SELECT COUNT(*) AS ROWS_TOTAL, SUM(FLEX_PROCESSING = 1) AS FLEX_ON
FROM T_WC_T2S_EVALUATION_EXECUTION;
