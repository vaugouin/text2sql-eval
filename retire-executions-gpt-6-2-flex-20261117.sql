-- Retire the 1.1.20 executions of the first GPT-6.2 complex-slot runs, so they are replayed
-- once the API sends GPT-6.2 to the standard tier. 2026-11-17.
--
-- WHY. Both runs (COMPLEX_MODEL gpt-6.2-sol and gpt-6.2-astra, escalated subset, EN and FR)
-- went out with Flex, which the evaluator turns on for any GPT-6 model. OpenAI refuses Flex on
-- the 6.2 line with a 400 ("This model does not support service_tier=flex. Use background=true
-- with background_options.completion_window instead."). A 400 is not retried, so every complex
-- call failed: no complex_question entry in llm_usage on any row, about 60 rows per run ending
-- on "Complex entity resolution is required before SQL generation", 1 pass out of about 100
-- against 77 to 86 for gpt-6.1-sol. These rows measure the error, not the model.
-- fastapi-text2sql now keeps gpt-6.2-* at the standard tier, and falls back to it on that 400.
--
-- WHEN. After the API fix is live on Blue (pull + restart), before replaying the two runs:
-- the evaluator skips every question that still has a live row with the same models.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-gpt-6-2-flex-20261117.sql

-- 1. What will be retired (read-only). Expected: 99 + 99 EN, 120 + 120 FR.
SELECT LANG, COMPLEX_MODEL, COUNT(*) AS executions, MIN(TIM_EXECUTION) AS oldest, MAX(TIM_EXECUTION) AS newest
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND COMPLEX_MODEL IN ('gpt-6.2-sol', 'gpt-6.2-astra')
GROUP BY LANG, COMPLEX_MODEL;

-- 2. Retire them (soft delete).
UPDATE T_WC_T2S_EVALUATION_EXECUTION
SET DELETED = 1
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND COMPLEX_MODEL IN ('gpt-6.2-sol', 'gpt-6.2-astra');

-- 3. Check: nothing left live for the two models.
SELECT COUNT(*) AS live_rows_left
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND COMPLEX_MODEL IN ('gpt-6.2-sol', 'gpt-6.2-astra');
