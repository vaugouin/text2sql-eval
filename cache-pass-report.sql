-- TEXT2SQL-EVAL-007: fresh answer vs cached answer, per question and language.
-- Read-only (voie 1). Compares the normal run (CACHE_PASS NULL or 0) with the --cache-pass run
-- (CACHE_PASS = 1) of the same API version and text-to-SQL model. Edit the two variables below.
-- Without a normal run, the score cannot be compared, but the warm-call summary kept in
-- JSON_RESULT.cache_pass still shows a representation or chain-anchor difference.

-- The connection collation must match the columns (utf8mb4_unicode_ci), or the comparisons with
-- the variables and literals fail with ERROR 1267 (illegal mix of collations).
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SET @api_version = '001.001.020';
SET @t2s_model = 'gpt-6-sol';

SELECT C.ID_T2S_EVALUATION AS ID, C.LANG,
       F.ASSERTIONS_TOTAL_SCORE AS FRESH_SCORE,
       C.ASSERTIONS_TOTAL_SCORE AS CACHED_SCORE,
       JSON_VALUE(C.JSON_RESULT, '$.cache_pass.served_from_cache') AS SERVED_FROM_CACHE,
       JSON_VALUE(C.JSON_RESULT, '$.cache_pass.warm.representation') AS WARM_REPRESENTATION,
       JSON_VALUE(C.JSON_RESULT, '$.cache_pass.cached.representation') AS CACHED_REPRESENTATION,
       JSON_VALUE(C.JSON_RESULT, '$.cache_pass.warm.chain_anchor') AS WARM_ANCHOR,
       JSON_VALUE(C.JSON_RESULT, '$.cache_pass.cached.chain_anchor') AS CACHED_ANCHOR,
       CASE
         -- JSON true comes back from JSON_VALUE as 1 on this server, 'true' elsewhere: accept both.
         WHEN COALESCE(JSON_VALUE(C.JSON_RESULT, '$.cache_pass.served_from_cache'), '') NOT IN ('true', '1') THEN 'not served from cache'
         WHEN C.ASSERTIONS_TOTAL_SCORE < F.ASSERTIONS_TOTAL_SCORE THEN 'CACHE-PATH DEFECT'
         WHEN JSON_VALUE(C.JSON_RESULT, '$.cache_pass.warm.representation')
              <> JSON_VALUE(C.JSON_RESULT, '$.cache_pass.cached.representation') THEN 'representation differs'
         WHEN JSON_VALUE(C.JSON_RESULT, '$.cache_pass.warm.chain_anchor')
              <> JSON_VALUE(C.JSON_RESULT, '$.cache_pass.cached.chain_anchor') THEN 'chain anchor differs'
         WHEN F.ID_ROW IS NULL THEN 'no fresh row to compare'
         ELSE 'same'
       END AS VERDICT
FROM T_WC_T2S_EVALUATION_EXECUTION C
LEFT JOIN T_WC_T2S_EVALUATION_EXECUTION F
  ON F.ID_T2S_EVALUATION = C.ID_T2S_EVALUATION AND F.LANG = C.LANG
 AND F.API_VERSION = C.API_VERSION AND F.TEXT2SQL_MODEL = C.TEXT2SQL_MODEL
 AND F.ENTITY_EXTRACTION_MODEL = C.ENTITY_EXTRACTION_MODEL AND F.COMPLEX_MODEL = C.COMPLEX_MODEL
 AND F.RESULT_ENTITY_MODEL <=> C.RESULT_ENTITY_MODEL AND F.ANSWER_SINGLE_VALUE_MODEL <=> C.ANSWER_SINGLE_VALUE_MODEL
 AND F.DELETED = 0 AND (F.CACHE_PASS IS NULL OR F.CACHE_PASS = 0) AND F.VISION_MODEL IS NULL
WHERE C.DELETED = 0 AND C.CACHE_PASS = 1
  AND C.API_VERSION = @api_version AND C.TEXT2SQL_MODEL = @t2s_model
ORDER BY (VERDICT = 'same'), C.ID_T2S_EVALUATION, C.LANG;
