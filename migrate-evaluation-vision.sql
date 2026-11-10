-- ============================================================================
-- T_WC_T2S_EVALUATION and T_WC_T2S_EVALUATION_EXECUTION: image-input evaluations (FASTAPI-TEXT2SQL-277)
-- ============================================================================
--
-- NOT YET APPLIED. Written 2026-11-10. Run it BEFORE new-evaluations-vision.sql, which writes
-- the three new evaluation columns and stops on "Unknown column" without them. The current
-- evaluator neither reads nor writes any of these columns, so it keeps working after this
-- migration exactly as before.
--
-- WHY. The bank can only hold text questions. A vision evaluation starts from a picture: the
-- bank must say so, name the picture, and say what the picture must be identified as; an
-- execution must say which vision model read it, how long that took, and whether it read it
-- right. This is what lets a campaign compare gpt-6-astra and claude-fable-5-2 on the same
-- pictures.
--
-- MEANING, T_WC_T2S_EVALUATION.
--   INPUT_KIND                        'image' = the question starts from INPUT_IMAGE_PATH;
--                                     NULL = a text question (every existing row).
--   INPUT_IMAGE_PATH                  path of the picture relative to the evaluator fixtures root
--                                     (/shared/fixtures on the evaluator, that is
--                                     shared_data/text2sql-eval/fixtures on the VPS), e.g.
--                                     vision/20260920-131500_vision_1.1.19_<md5>.jpg. Never an
--                                     image_ref of the API: uploads are purged after 30 days.
--   ASSERTIONS_VISION_IDENTIFICATION  expected identification, JSON: {"type": movie|serie|person|
--                                     collection|book|location|none, "id": TMDb id or null,
--                                     "title": ..., "original_title": ..., "year": ...}. Scored
--                                     against vision_evidence (selected candidate), out of
--                                     ASSERTIONS_TOTAL_SCORE like ASSERTIONS_RESULT_SHAPE, so
--                                     text campaigns stay comparable.
-- MEANING, T_WC_T2S_EVALUATION_EXECUTION.
--   VISION_MODEL                            vision model of the run (llm_model_vision echoed by
--                                           the API). NULL = text evaluation, or row written
--                                           before this column. Part of the run signature.
--   VISION_IDENTIFICATION_PROCESSING_TIME   seconds spent in the vision task.
--   ASSERTIONS_VISION_IDENTIFICATION_SCORE  1 / 0 against ASSERTIONS_VISION_IDENTIFICATION;
--                                           NULL when the evaluation carries none.
--
-- No backfill: every existing row is a text evaluation and keeps NULL.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS / ADD KEY IF NOT EXISTS (MariaDB).
--
-- Run (voie 2, DDL):
--   cd ~/docker/text2sql-eval && git pull
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/migrate-evaluation-vision.sql
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT '0. Before: vision columns present' AS SECTION;
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('T_WC_T2S_EVALUATION', 'T_WC_T2S_EVALUATION_EXECUTION')
  AND (COLUMN_NAME LIKE 'INPUT\_%' OR COLUMN_NAME LIKE '%VISION%')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

ALTER TABLE T_WC_T2S_EVALUATION
  ADD COLUMN IF NOT EXISTS `INPUT_KIND` varchar(10) DEFAULT NULL COMMENT 'FASTAPI-TEXT2SQL-277 : image = la question part de INPUT_IMAGE_PATH ; NULL = question texte' AFTER `RESOLUTION_MODE`,
  ADD COLUMN IF NOT EXISTS `INPUT_IMAGE_PATH` varchar(255) DEFAULT NULL COMMENT 'FASTAPI-TEXT2SQL-277 : chemin de l image relatif a la racine des fixtures de l evaluateur (vision/<fichier>), jamais un image_ref de l API' AFTER `INPUT_KIND`,
  ADD COLUMN IF NOT EXISTS `ASSERTIONS_VISION_IDENTIFICATION` mediumtext DEFAULT NULL COMMENT 'FASTAPI-TEXT2SQL-277 : identification attendue (JSON type, id, title, original_title, year), notee hors ASSERTIONS_TOTAL_SCORE' AFTER `INPUT_IMAGE_PATH`;
ALTER TABLE T_WC_T2S_EVALUATION
  ADD KEY IF NOT EXISTS `INPUT_KIND` (`INPUT_KIND`);

ALTER TABLE T_WC_T2S_EVALUATION_EXECUTION
  ADD COLUMN IF NOT EXISTS `VISION_MODEL` varchar(50) DEFAULT NULL COMMENT 'FASTAPI-TEXT2SQL-277 : modele de vision du passage. NULL = evaluation texte ou ligne anterieure a la colonne.' AFTER `ANSWER_SINGLE_VALUE_MODEL`,
  ADD COLUMN IF NOT EXISTS `VISION_IDENTIFICATION_PROCESSING_TIME` double DEFAULT NULL COMMENT 'FASTAPI-TEXT2SQL-277 : temps de la tache de vision, en secondes' AFTER `ANSWER_SINGLE_VALUE_PROCESSING_TIME`,
  ADD COLUMN IF NOT EXISTS `ASSERTIONS_VISION_IDENTIFICATION_SCORE` double DEFAULT NULL COMMENT 'FASTAPI-TEXT2SQL-277 : 1/0 sur ASSERTIONS_VISION_IDENTIFICATION, hors ASSERTIONS_TOTAL_SCORE. NULL = pas d assertion de vision.' AFTER `ASSERTIONS_TOTAL_SCORE`;
ALTER TABLE T_WC_T2S_EVALUATION_EXECUTION
  ADD KEY IF NOT EXISTS `VISION_MODEL` (`VISION_MODEL`),
  ADD KEY IF NOT EXISTS `VISION_IDENTIFICATION_PROCESSING_TIME` (`VISION_IDENTIFICATION_PROCESSING_TIME`),
  ADD KEY IF NOT EXISTS `ASSERTIONS_VISION_IDENTIFICATION_SCORE` (`ASSERTIONS_VISION_IDENTIFICATION_SCORE`);

SELECT '1. After: vision columns present' AS SECTION;
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('T_WC_T2S_EVALUATION', 'T_WC_T2S_EVALUATION_EXECUTION')
  AND (COLUMN_NAME LIKE 'INPUT\_%' OR COLUMN_NAME LIKE '%VISION%')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT '2. Rows: every existing row stays NULL' AS SECTION;
SELECT 'T_WC_T2S_EVALUATION' AS TABLE_NAME, COUNT(*) AS ROWS_TOTAL, SUM(INPUT_KIND IS NULL) AS NEW_COLUMN_NULL FROM T_WC_T2S_EVALUATION
UNION ALL
SELECT 'T_WC_T2S_EVALUATION_EXECUTION', COUNT(*), SUM(VISION_MODEL IS NULL) FROM T_WC_T2S_EVALUATION_EXECUTION;
