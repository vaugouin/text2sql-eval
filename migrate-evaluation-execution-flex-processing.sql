-- ============================================================================
-- T_WC_T2S_EVALUATION_EXECUTION: OpenAI Flex processing per execution (TEXT2SQL-EVAL-002)
-- ============================================================================
--
-- NOT YET APPLIED. Written 2026-10-18. Run it BEFORE the first campaign launched with
-- FLEX_PROCESSING=--flex-processing: such a campaign writes these two columns, and an
-- evaluator that finds them missing stops on "Unknown column". A standard campaign does
-- not write them, so it keeps working before this migration.
--
-- WHY. A campaign can now ask the API for OpenAI Flex processing, billed at Batch API
-- rates (half the standard price) but slower. Its latencies do not compare with a
-- standard run, so each row must say how it ran. Flex is NOT part of the namespace (the
-- model tuple of the skip rule): same models, same answers.
--
-- MEANING.
--   FLEX_PROCESSING      1 = the campaign asked for Flex; NULL or 0 = standard tier.
--   FLEX_FALLBACK_COUNT  LLM calls of the request that exhausted their Flex attempts
--                        and ran once at the standard tier (full price). NULL = no Flex.
-- The tier served per task stays in JSON_RESULT:
-- JSON_EXTRACT(JSON_RESULT, '$.llm_usage.text2sql.service_tier').
--
-- No backfill: every existing row ran at the standard tier and keeps NULL.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS / ADD KEY IF NOT EXISTS (MariaDB).
--
-- Run: ~/docker/tools/runsqlvaugouindb.sh <this file>
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT '0. Before: Flex columns present on the execution table' AS SECTION;
SELECT COLUMN_NAME, COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'T_WC_T2S_EVALUATION_EXECUTION'
  AND COLUMN_NAME LIKE 'FLEX\_%'
ORDER BY ORDINAL_POSITION;

ALTER TABLE T_WC_T2S_EVALUATION_EXECUTION
  ADD COLUMN IF NOT EXISTS `FLEX_PROCESSING` tinyint(1) DEFAULT NULL
    COMMENT 'Campagne lancee en OpenAI Flex processing (TEXT2SQL-EVAL-002). 1 = Flex ; NULL ou 0 = tarif standard.'
    AFTER `ANSWER_SINGLE_VALUE_MODEL`,
  ADD COLUMN IF NOT EXISTS `FLEX_FALLBACK_COUNT` smallint(6) DEFAULT NULL
    COMMENT 'Appels LLM de la requete passes au tarif standard apres echec des essais Flex (TEXT2SQL-EVAL-002). NULL = pas de Flex.'
    AFTER `FLEX_PROCESSING`;

ALTER TABLE T_WC_T2S_EVALUATION_EXECUTION
  ADD KEY IF NOT EXISTS `FLEX_PROCESSING` (`FLEX_PROCESSING`);

SELECT '1. After: two Flex columns; every existing row NULL in them' AS SECTION;
SELECT COLUMN_NAME, COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'T_WC_T2S_EVALUATION_EXECUTION'
  AND COLUMN_NAME LIKE 'FLEX\_%'
ORDER BY ORDINAL_POSITION;

SELECT COUNT(*) AS ROWS_TOTAL,
       SUM(FLEX_PROCESSING IS NULL) AS FLEX_NULL,
       SUM(FLEX_PROCESSING = 1) AS FLEX_ON
FROM T_WC_T2S_EVALUATION_EXECUTION;
