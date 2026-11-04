-- Retire the 1.1.20 executions whose result_entity call ran at the Flex tier, so they are
-- replayed with coherent timings. 2026-11-04.
--
-- WHY. On the evening of 2026-11-04 OpenAI lacked Flex capacity for gpt-6-luna: each
-- result_entity call was refused and retried up to four times (5 + 15 + 30 + 60 s), 20.6 s per
-- question on average against 1.4 s at the standard tier on 1.1.19
-- (check-campaign-speed-001.001.020-20261104.txt). fastapi-text2sql 5c4c99f keeps
-- result_entity at the standard tier since the restart of Blue that evening. The scores of
-- these rows are sound (same model, only the tier differs); their processing times are not,
-- and 1.1.20 is compared with 1.1.19 on time too. A row with no result_entity call has no
-- such key in its llm_usage and stays.
--
-- WHEN. After the English campaign in progress has finished (the evaluator picks its questions
-- at start). Then relaunch the English campaign: it replays only the rows retired here, since
-- it skips every question that still has a live 1.1.20 row. Phase 10 hard-deletes them.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-001.001.020-flex-result-entity.sql

-- 1. What will be retired (read-only).
SELECT LANG, COUNT(*) AS executions, MIN(TIM_EXECUTION) AS oldest, MAX(TIM_EXECUTION) AS newest,
       ROUND(AVG(JSON_VALUE(JSON_RESULT, '$.result_entity_processing_time')), 1) AS mean_result_entity_s
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND JSON_VALUE(JSON_RESULT, '$.llm_usage.result_entity.service_tier') LIKE '%flex%'
GROUP BY LANG;

-- 2. Retire them (soft delete).
UPDATE T_WC_T2S_EVALUATION_EXECUTION
SET DELETED = 1
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND JSON_VALUE(JSON_RESULT, '$.llm_usage.result_entity.service_tier') LIKE '%flex%';

-- 3. Check: nothing left, and what stays live on 1.1.20.
SELECT LANG,
       SUM(JSON_VALUE(JSON_RESULT, '$.llm_usage.result_entity.service_tier') LIKE '%flex%') AS flex_left,
       COUNT(*) AS live_rows
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0 AND API_VERSION = '001.001.020'
GROUP BY LANG;
