-- Why is the 1.1.20 campaign slow? Read-only. 2026-11-04.
-- Compares the live 1.1.20 rows (lexicon on) with the 1.1.19 rows, stage by stage, and
-- measures the wall-clock gap between two consecutive executions (API time + evaluator
-- overhead: the 2 s sleep, the assertion checks, the export).
-- Voie 1: ssh vps-agent run text2sql-eval/check-campaign-speed-001.001.020.sql

-- 1. Per version and language: rows, flex, mean time per stage (seconds).
SELECT API_VERSION, LANG, COUNT(*) AS n,
       SUM(FLEX_PROCESSING = 1) AS flex_rows,
       SUM(COALESCE(FLEX_FALLBACK_COUNT, 0)) AS flex_fallbacks,
       ROUND(AVG(TOTAL_PROCESSING_TIME), 1) AS total,
       ROUND(AVG(ENTITY_EXTRACTION_PROCESSING_TIME), 1) AS extraction,
       ROUND(AVG(EMBEDDINGS_PROCESSING_TIME), 2) AS embeddings,
       ROUND(AVG(ENTITY_RESOLUTION_PLANNING_TIME), 2) AS planning,
       ROUND(AVG(TEXT2SQL_PROCESSING_TIME), 1) AS text2sql,
       ROUND(AVG(COMPLEX_QUESTION_PROCESSING_TIME), 1) AS complex,
       ROUND(AVG(QUERY_EXECUTION_TIME), 2) AS query,
       ROUND(AVG(RESULT_ENTITY_PROCESSING_TIME), 1) AS result_entity,
       ROUND(AVG(ANSWER_SINGLE_VALUE_PROCESSING_TIME), 1) AS single_value,
       MIN(TIM_EXECUTION) AS first_row, MAX(TIM_EXECUTION) AS last_row
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0 AND API_VERSION IN ('001.001.019', '001.001.020')
GROUP BY API_VERSION, LANG
ORDER BY API_VERSION, LANG;

-- 2. Wall clock between consecutive executions of the same campaign (version, language).
SELECT API_VERSION, LANG, COUNT(*) AS gaps,
       ROUND(AVG(gap), 1) AS mean_gap_s,
       ROUND(AVG(gap - COALESCE(TOTAL_PROCESSING_TIME, 0)), 1) AS mean_overhead_s,
       MAX(gap) AS max_gap_s
FROM (
  SELECT API_VERSION, LANG, TOTAL_PROCESSING_TIME,
         TIMESTAMPDIFF(SECOND, LAG(TIM_EXECUTION) OVER (PARTITION BY API_VERSION, LANG ORDER BY TIM_EXECUTION),
                       TIM_EXECUTION) AS gap
  FROM T_WC_T2S_EVALUATION_EXECUTION
  WHERE DELETED = 0 AND API_VERSION IN ('001.001.019', '001.001.020')
) g
WHERE gap IS NOT NULL AND gap < 1800
GROUP BY API_VERSION, LANG
ORDER BY API_VERSION, LANG;

-- 3. The twenty slowest 1.1.20 executions, with their stage times.
SELECT ID_T2S_EVALUATION AS id, LANG, TIM_EXECUTION, FLEX_PROCESSING AS flex,
       ROUND(TOTAL_PROCESSING_TIME, 1) AS total,
       ROUND(ENTITY_EXTRACTION_PROCESSING_TIME, 1) AS extraction,
       ROUND(EMBEDDINGS_PROCESSING_TIME, 2) AS embeddings,
       ROUND(TEXT2SQL_PROCESSING_TIME, 1) AS text2sql,
       ROUND(COMPLEX_QUESTION_PROCESSING_TIME, 1) AS complex,
       ROUND(QUERY_EXECUTION_TIME, 2) AS query,
       ROUND(RESULT_ENTITY_PROCESSING_TIME, 1) AS result_entity,
       COMPLEX_MODEL_USED AS esc
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0 AND API_VERSION = '001.001.020'
ORDER BY TOTAL_PROCESSING_TIME DESC
LIMIT 20;

-- 4. The timing columns are filled later in the run; on 1.1.20 read the stored response.
SELECT COUNT(*) AS n,
       ROUND(AVG(JSON_VALUE(JSON_RESULT, '$.total_processing_time')), 1) AS total,
       ROUND(AVG(JSON_VALUE(JSON_RESULT, '$.entity_extraction_processing_time')), 1) AS extraction,
       ROUND(AVG(JSON_VALUE(JSON_RESULT, '$.embeddings_processing_time')), 2) AS embeddings,
       ROUND(AVG(JSON_VALUE(JSON_RESULT, '$.entity_resolution_planning_time')), 2) AS planning,
       ROUND(AVG(JSON_VALUE(JSON_RESULT, '$.text2sql_processing_time')), 1) AS text2sql,
       ROUND(AVG(JSON_VALUE(JSON_RESULT, '$.complex_question_processing_time')), 1) AS complex,
       ROUND(AVG(JSON_VALUE(JSON_RESULT, '$.query_execution_time')), 2) AS query,
       ROUND(AVG(JSON_VALUE(JSON_RESULT, '$.result_entity_processing_time')), 1) AS result_entity,
       SUM(JSON_VALUE(JSON_RESULT, '$.total_processing_time') > 60) AS over_60s,
       SUM(JSON_RESULT LIKE '%"service_tier": "flex"%' OR JSON_RESULT LIKE '%"service_tier":"flex"%') AS rows_served_flex
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0 AND API_VERSION = '001.001.020';

-- 5. Same, 1.1.19 flex rows against 1.1.19 standard rows (the price/latency trade-off measured before).
SELECT FLEX_PROCESSING AS flex, COUNT(*) AS n, ROUND(AVG(TOTAL_PROCESSING_TIME), 1) AS total,
       ROUND(AVG(TEXT2SQL_PROCESSING_TIME), 1) AS text2sql, SUM(TOTAL_PROCESSING_TIME > 60) AS over_60s
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0 AND API_VERSION = '001.001.019'
GROUP BY FLEX_PROCESSING;

-- 6. One slow 1.1.20 row: the LLM calls it made (task, model, tier, seconds when reported).
SELECT ID_T2S_EVALUATION AS id, JSON_VALUE(JSON_RESULT, '$.total_processing_time') AS total,
       LEFT(JSON_EXTRACT(JSON_RESULT, '$.llm_usage'), 2500) AS llm_usage
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0 AND API_VERSION = '001.001.020'
ORDER BY CAST(JSON_VALUE(JSON_RESULT, '$.total_processing_time') AS DOUBLE) DESC
LIMIT 1;
