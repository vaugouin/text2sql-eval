-- Read-only. Evaluation ids already executed in BOTH languages for the production
-- configuration (API 1.1.19, gpt-6-sol / gpt-6-sol / gpt-6.1-sol, result entity gpt-6-luna,
-- answer single value gpt-4o or NULL). One of them, passed as EVAL_IDS, makes
-- text2sql-eval.sh a rescore-only run: phase 11 has nothing to do, phases 30-32 re-export
-- the whole bank (EVALUATIONS-023, samples 2428, 2429, 2435 after the nightly refresh).
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT x.ID_T2S_EVALUATION, GROUP_CONCAT(DISTINCT x.LANG ORDER BY x.LANG) AS LANGS, COUNT(*) AS N
FROM T_WC_T2S_EVALUATION_EXECUTION x
JOIN T_WC_T2S_EVALUATION e ON e.ID_T2S_EVALUATION = x.ID_T2S_EVALUATION AND e.IS_EVAL = 1 AND e.DELETED = 0
WHERE x.DELETED = 0
  AND x.API_VERSION = '001.001.019'
  AND x.ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND x.TEXT2SQL_MODEL = 'gpt-6-sol'
  AND x.COMPLEX_MODEL = 'gpt-6.1-sol'
  AND x.RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND (x.ANSWER_SINGLE_VALUE_MODEL = 'gpt-4o' OR x.ANSWER_SINGLE_VALUE_MODEL IS NULL)
GROUP BY x.ID_T2S_EVALUATION
HAVING COUNT(DISTINCT x.LANG) = 2
ORDER BY x.ID_T2S_EVALUATION
LIMIT 5;
