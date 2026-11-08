-- Read-only check of retire-executions-001.001.020-flex-result-entity.sql (2026-11-04).
-- Voie 1: ssh vps-agent run text2sql-eval/check-retire-flex-result-entity.sql

-- 1. 1.1.20 rows by state and by tier of result_entity.
SELECT LANG, DELETED,
       CASE WHEN JSON_VALUE(JSON_RESULT, '$.llm_usage.result_entity.service_tier') LIKE '%flex%' THEN 'flex'
            WHEN JSON_EXISTS(JSON_RESULT, '$.llm_usage.result_entity') THEN 'standard'
            ELSE 'no result_entity' END AS result_entity_tier,
       COUNT(*) AS n, MIN(TIM_EXECUTION) AS oldest, MAX(TIM_EXECUTION) AS newest,
       ROUND(AVG(JSON_VALUE(JSON_RESULT, '$.result_entity_processing_time')), 1) AS mean_result_entity_s,
       ROUND(AVG(JSON_VALUE(JSON_RESULT, '$.total_processing_time')), 1) AS mean_total_s
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE API_VERSION = '001.001.020'
GROUP BY LANG, DELETED, result_entity_tier
ORDER BY LANG, DELETED, result_entity_tier;

-- 2. Live 1.1.20 rows whose result_entity was retried at the Flex tier, then served at the
--    standard tier after the retries (service_tier then reads 'default', not 'flex').
SELECT LANG, COUNT(*) AS n, MIN(TIM_EXECUTION) AS oldest, MAX(TIM_EXECUTION) AS newest,
       ROUND(AVG(JSON_VALUE(JSON_RESULT, '$.result_entity_processing_time')), 1) AS mean_result_entity_s
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0 AND API_VERSION = '001.001.020'
  AND CAST(JSON_VALUE(JSON_RESULT, '$.llm_usage.result_entity.flex_retries') AS UNSIGNED) > 0
GROUP BY LANG;
