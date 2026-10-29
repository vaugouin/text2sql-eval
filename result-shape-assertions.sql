-- Result-shape assertions (FASTAPI-TEXT2SQL-349).
--
-- NOT YET APPLIED. Generated 2026-10-29.
--
-- WHAT THIS FILE DOES
-- The API now emits a rendering hint on every result: result_kind, result_columns
-- (name/role/unit) and representation. This file lets the bank assert on it, in a new
-- column ASSERTIONS_RESULT_SHAPE, checked OUT OF SCORE by check-result-shape.py. It never
-- enters a campaign's accuracy number (the campaign pass is query_result alone,
-- harness/harness_lib.py); it evaluates the new feature without perturbing that number.
--
-- THREE SECTIONS
--   Section 0  DDL: add the column (idempotent, ADD COLUMN IF NOT EXISTS).
--   Section A  Set the assertion on EXISTING questions whose intended shape is
--              unambiguous (count, single-entity page, scalar, plain grid). Each UPDATE is
--              guarded on an empty value, so it never clobbers a hand-written one.
--   Section B  Insert the two questions no existing one covers: a runtime SUM in minutes
--              (number card) and a budget/revenue/profit triple. Each INSERT is guarded by
--              NOT EXISTS on the English question, so a second pass inserts nothing (the
--              subquery is wrapped in a derived table to avoid MariaDB 1093). B2 also carries
--              a self-healing UPDATE: see its note for why its assertion became card-grid.
--
-- WHY ONLY THESE EXISTING IDS
-- The sweep of 2026-10-29 found the asserted bank is almost all card-grid. Counts (72) and
-- single-entity pages (19) are well covered; the scalar-with-unit case that motivated -349
-- (a SUM in minutes) is the real gap, filled by B1. A stat strip remains uncovered: the
-- model prefers a window aggregate over entity rows (see B2's note), so no bank question
-- yields one yet. The
-- card-grid-versus-ranked-bars tie is deliberately NOT asserted on existing questions: the
-- standard entity projection carries several metric columns, so the shape is card-grid,
-- and a ranked-bars example belongs on a question with a single-metric projection, to be
-- added once a first run confirms the representation the API actually emits.
--
-- ROUTING: this file carries DDL, so it runs by voie 2 (Philippe), never the agent gate:
--   cd ~/docker/<clone of the live colour>   # fastapi-text2sql-green or -blue
--   git pull
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/<clone>/<path>/result-shape-assertions.sql
-- Commit and push before running. The bank is refreshed to the PC by the usual sync; then
-- the JSON exports carry assertions.result_shape and check-result-shape.py can read them.
--
-- The > sign is stored HTML-escaped as &gt; in ASSERTIONS_QUERY_RESULT, matching the column
-- and what evaluate_dataframe_assertions() unescapes before parsing. ASSERTIONS_RESULT_SHAPE
-- needs no escaping (it uses == and !=). `unit(*)` means the single metric column, the
-- robust form when the aggregate alias is the model's choice, not the bank's.

-- ===== Section 0 : schema =====
ALTER TABLE T_WC_T2S_EVALUATION
  ADD COLUMN IF NOT EXISTS ASSERTIONS_RESULT_SHAPE mediumtext DEFAULT NULL
  COMMENT 'FASTAPI-TEXT2SQL-349 : assertion sur l indice de rendu (result_kind / representation / unit), hors score, lue par check-result-shape.py'
  AFTER ASSERTIONS_SQL_QUERY;

-- ===== Section A : existing questions, unambiguous shapes =====
-- Counts -> number card.
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'result_kind == count; representation == number-card'
  WHERE ID_T2S_EVALUATION = 790 AND (ASSERTIONS_RESULT_SHAPE IS NULL OR ASSERTIONS_RESULT_SHAPE = '');
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'result_kind == count; representation == number-card'
  WHERE ID_T2S_EVALUATION = 791 AND (ASSERTIONS_RESULT_SHAPE IS NULL OR ASSERTIONS_RESULT_SHAPE = '');
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'result_kind == count; representation == number-card'
  WHERE ID_T2S_EVALUATION = 29 AND (ASSERTIONS_RESULT_SHAPE IS NULL OR ASSERTIONS_RESULT_SHAPE = '');

-- Single-entity lookup -> entity page.
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == entity-page'
  WHERE ID_T2S_EVALUATION = 79 AND (ASSERTIONS_RESULT_SHAPE IS NULL OR ASSERTIONS_RESULT_SHAPE = '');
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == entity-page'
  WHERE ID_T2S_EVALUATION = 80 AND (ASSERTIONS_RESULT_SHAPE IS NULL OR ASSERTIONS_RESULT_SHAPE = '');

-- Aggregate AVG with no entity id -> scalar number card. A diagnostic unit(*) == minutes:
-- if it fails, the API did not propagate the unit onto the computed AVG column (the open
-- question of the design note), which is a finding, not a false alarm.
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'result_kind == scalar; representation == number-card; unit(*) == minutes'
  WHERE ID_T2S_EVALUATION = 2524 AND (ASSERTIONS_RESULT_SHAPE IS NULL OR ASSERTIONS_RESULT_SHAPE = '');

-- Multi-row entity list -> card grid. Only a question whose assertion pins MANY ids is safe
-- here: entity-page versus card-grid turns on the runtime row count, so a list that returns
-- a single row renders as a page, not a grid.
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == card-grid'
  WHERE ID_T2S_EVALUATION = 3 AND (ASSERTIONS_RESULT_SHAPE IS NULL OR ASSERTIONS_RESULT_SHAPE = '');

-- DELIBERATELY NOT ASSERTED HERE (confirm with a first run, then add):
--   #2  "silent movies after 1990" pins a SINGLE id, so it returns one row and renders as
--       entity-page, not card-grid.
--   #54 "revenue of Titanic" may come back as a bare scalar OR as the movie entity with
--       revenue as a field; the answer-entity classifier decides at runtime, so neither
--       number-card nor entity-page is safe to assert blind.

-- ===== Section B : the two new questions =====
-- B1. Runtime SUM in minutes -> number card. The gap the Harry Potter take exposed: a total
-- spoken but never drawn. No hardcoded id (the pipeline resolves "Christopher Nolan").
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED,
   DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT
  'What is the combined runtime of all Christopher Nolan movies?',
  'Quelle est la duree cumulee de tous les films de Christopher Nolan ?',
  12, 1, 0, 0, 0, CURDATE(), 1, 1,
  'CELL(0, 0) &gt; 0',
  'result_kind == scalar; representation == number-card; unit(*) == minutes'
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM (
    SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'What is the combined runtime of all Christopher Nolan movies?'
  ) AS guard
);

-- B2. Budget, revenue and profit together.
-- INTENDED a stat strip, but the first Green run (2026-10-29, id 2550) showed the model does
-- NOT write a bare 2-to-5-column aggregate for this question: it writes a WINDOW aggregate
-- (SUM(...) OVER ()) that projects all 30 Nolan movies as entity rows with the totals repeated
-- on each row. That result IS entity_rows / card-grid, and the classifier describes it faithfully.
-- So the assertion is aligned on the shape the pipeline actually produces. A genuine stat-strip
-- example still has no home in the bank (it needs a question the model answers with a bare
-- multi-scalar aggregate, no id projection); left as a TODO rather than a false assertion here.
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED,
   DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT
  'What is the total budget, total box office revenue and overall profit of all Christopher Nolan movies?',
  'Quels sont le budget total, les recettes totales au box-office et le profit global de tous les films de Christopher Nolan ?',
  22, 1, 0, 0, 0, CURDATE(), 1, 1,
  'CELL(0, 0) &gt; 0',
  'result_kind == entity_rows; representation == card-grid'
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM (
    SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'What is the total budget, total box office revenue and overall profit of all Christopher Nolan movies?'
  ) AS guard
);

-- Self-healing: a DB where B2 was already inserted with the old stat-strip assertion (the first
-- run) is corrected here. Guarded on the old value, so it fires once and is a no-op afterwards.
UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == card-grid'
  WHERE QUESTION = 'What is the total budget, total box office revenue and overall profit of all Christopher Nolan movies?'
    AND ASSERTIONS_RESULT_SHAPE = 'result_kind == scalar; representation == stat-strip';
