-- Cinéphile Bench v1: the frozen question set (2026-10-14).
--
-- v1 is the set phase 11 of text2sql-eval.py would run on 2026-10-14: IS_EVAL = 1,
-- DELETED = 0, at least one assertion. Each question runs in English and in French.
-- The dated result next to this file (cinephile-bench-v1-20261014.txt) is the v1
-- manifest: a Cinéphile score is "v1" only when computed on these IDs.
--
-- FINGERPRINT detects a v1 question whose content changed after the freeze
-- (question text in either language, assertions, resolution mode). For a living
-- assertion (ASSERTION_REFRESH_SQL set), the refresh SQL is fingerprinted instead of
-- ASSERTIONS_QUERY_RESULT, which the daily refresh job rewrites.
--
-- Read-only. Run: ssh vps-agent run text2sql-eval/cinephile-bench-v1.sql

SELECT COUNT(*) AS V1_QUESTIONS,
       SUM(QUESTION IS NOT NULL AND QUESTION <> '') AS V1_EN,
       SUM(QUESTION_FR IS NOT NULL AND QUESTION_FR <> '') AS V1_FR,
       SUM(ASSERTION_REFRESH_SQL IS NOT NULL AND ASSERTION_REFRESH_SQL <> '') AS V1_LIVING_ASSERTIONS
FROM T_WC_T2S_EVALUATION
WHERE IS_EVAL = 1
  AND DELETED = 0
  AND ((ASSERTIONS_QUERY_RESULT <> '' AND ASSERTIONS_QUERY_RESULT IS NOT NULL)
    OR (ASSERTIONS_ENTITY_EXTRACTION <> '' AND ASSERTIONS_ENTITY_EXTRACTION IS NOT NULL)
    OR (ASSERTIONS_SQL_QUERY <> '' AND ASSERTIONS_SQL_QUERY IS NOT NULL));

SELECT ID_T2S_EVALUATION,
       ID_T2S_EVALUATION_CATEGORY,
       MD5(CONCAT_WS(CHAR(31),
           IFNULL(QUESTION, ''),
           IFNULL(QUESTION_FR, ''),
           IF(ASSERTION_REFRESH_SQL IS NOT NULL AND ASSERTION_REFRESH_SQL <> '',
              CONCAT('refresh:', ASSERTION_REFRESH_SQL),
              IFNULL(ASSERTIONS_QUERY_RESULT, '')),
           IFNULL(ASSERTIONS_ENTITY_EXTRACTION, ''),
           IFNULL(ASSERTIONS_SQL_QUERY, ''),
           IFNULL(RESOLUTION_MODE, ''))) AS FINGERPRINT
FROM T_WC_T2S_EVALUATION
WHERE IS_EVAL = 1
  AND DELETED = 0
  AND ((ASSERTIONS_QUERY_RESULT <> '' AND ASSERTIONS_QUERY_RESULT IS NOT NULL)
    OR (ASSERTIONS_ENTITY_EXTRACTION <> '' AND ASSERTIONS_ENTITY_EXTRACTION IS NOT NULL)
    OR (ASSERTIONS_SQL_QUERY <> '' AND ASSERTIONS_SQL_QUERY IS NOT NULL))
ORDER BY ID_T2S_EVALUATION;
