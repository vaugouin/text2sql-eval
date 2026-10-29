-- New evaluations harvested from the live test session of 2026-10-29 (EVALUATIONS-027).
--
-- NOT YET APPLIED. Generated 2026-10-29.
--
-- WHAT THIS FILE DOES
-- Adds the questions the result-representation work (FASTAPI-TEXT2SQL-349, VOICE-AGENT-243/-244)
-- showed were missing from the bank, each with a query_result assertion (the scored one) and,
-- where the shape was actually observed on Green that day, a result_shape assertion (out of
-- score, read by check-result-shape.py). No shape assertion is written for a shape not yet
-- observed in a run (house rule): the ranked-bars candidate in Section C carries none yet.
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL, so the agent gate runs it (voie 1, the
-- table is one of the seven agent-writable ones):
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/new-evaluations-20261029.sql
-- Commit and push before running. Then refresh the bank to the PC (phase 31 export + sync) so
-- the JSON exports carry these questions and their assertions.
--
-- CONVENTIONS (mirrors result-shape-assertions.sql Section B)
--   - Auto-increment id, NEVER a hand-picked one (the 2540 collision of EVALUATIONS-025).
--   - Each INSERT guarded by NOT EXISTS on the English QUESTION (derived table to dodge MariaDB
--     1093), so a second pass inserts nothing.
--   - IS_EVAL = 1, IS_SAMPLE = 0, IS_SHOWCASE = 0, DELETED = 0 ; DAT_CREAT = CURDATE() ; owner 1.
--   - The > of a query_result assertion is stored HTML-escaped as &gt;, matching the column and
--     what evaluate_dataframe_assertions() unescapes before parsing. result_shape uses == / !=,
--     no escaping. unit(*) means the single metric column.

-- ===== Section A : counts (count / number-card) =====
-- Observed on Green 2026-10-29: every "how many X" returns count / number-card. The scored
-- assertion checks a single row with a positive total.

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED,
   DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many TV series are there?', 'Combien y a-t-il de series televisees ?', 6, 1, 0, 0, 0,
  CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt; 0',
  'result_kind == count; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many TV series are there?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED,
   DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many persons are there?', 'Combien y a-t-il de personnes ?', 16, 1, 0, 0, 0,
  CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt; 0',
  'result_kind == count; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many persons are there?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED,
   DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many collections are there?', 'Combien y a-t-il de collections ?', 47, 1, 0, 0, 0,
  CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt; 0',
  'result_kind == count; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many collections are there?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED,
   DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many locations are there?', 'Combien y a-t-il de lieux ?', 8, 1, 0, 0, 0,
  CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt; 0',
  'result_kind == count; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many locations are there?') AS guard);

-- "How many source works are there?" was also asked, but no evaluation category fits a source
-- work cleanly; left out of this batch until its category is decided, rather than mis-filed.

-- ===== Section B : scalar sums with a unit (scalar / number-card) =====
-- Observed on Green 2026-10-29: the Harry Potter runtime sum returns minutes, the budget and
-- revenue sums return usd. unit(*) is a diagnostic: a failure means the API did not propagate
-- the unit onto the computed aggregate column.

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED,
   DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How long would it take to watch all the Harry Potter movies back to back?',
  'Combien de temps faudrait-il pour regarder tous les films Harry Potter a la suite ?',
  12, 1, 0, 0, 0, CURDATE(), 1, 1, 'CELL(0, 0) &gt; 0',
  'result_kind == scalar; representation == number-card; unit(*) == minutes'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How long would it take to watch all the Harry Potter movies back to back?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED,
   DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'What is the total budget of all Harry Potter movies?',
  'Quel est le budget total de tous les films Harry Potter ?',
  22, 1, 0, 0, 0, CURDATE(), 1, 1, 'CELL(0, 0) &gt; 0',
  'result_kind == scalar; representation == number-card; unit(*) == usd'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'What is the total budget of all Harry Potter movies?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED,
   DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'What is the total revenue of all Harry Potter movies?',
  'Quelles sont les recettes totales de tous les films Harry Potter ?',
  22, 1, 0, 0, 0, CURDATE(), 1, 1, 'CELL(0, 0) &gt; 0',
  'result_kind == scalar; representation == number-card; unit(*) == usd'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'What is the total revenue of all Harry Potter movies?') AS guard);

-- ===== Section C : single-metric projection to exercise ranked-bars (VOICE-AGENT-244) =====
-- No question in the bank yields ranked-bars: the default movie projection carries several
-- metric columns, so the shape is card-grid. This question asks for runtime alone, ordered, to
-- try to elicit a label + one metric projection. result_shape is DELIBERATELY EMPTY: assert it
-- to 'representation == ranked-bars' only after a run confirms the API emits it (house rule, do
-- not assert a shape not yet observed). The scored assertion just checks several rows come back.

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED,
   DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'List the Harry Potter movies with only their runtime, from longest to shortest.',
  'Liste les films Harry Potter avec seulement leur duree, du plus long au plus court.',
  12, 1, 0, 0, 0, CURDATE(), 1, 1, 'COUNT(*) &gt; 1', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'List the Harry Potter movies with only their runtime, from longest to shortest.') AS guard);

-- ===== Verification: show the inserted rows =====
SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, QUESTION
  FROM T_WC_T2S_EVALUATION
  WHERE QUESTION IN (
    'How many TV series are there?',
    'How many persons are there?',
    'How many collections are there?',
    'How many locations are there?',
    'How long would it take to watch all the Harry Potter movies back to back?',
    'What is the total budget of all Harry Potter movies?',
    'What is the total revenue of all Harry Potter movies?',
    'List the Harry Potter movies with only their runtime, from longest to shortest.'
  )
  ORDER BY ID_T2S_EVALUATION;
