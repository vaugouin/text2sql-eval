-- Result-shape follow-up of 2026-10-30 (EVALUATIONS-027).
--
-- WHAT THIS FILE DOES
-- 1. Adds the count / number-card shape assertion to eval 792 ("How many persons are there?"),
--    which already existed and was skipped by the guard of new-evaluations-20261029.sql. The
--    shape is OBSERVED, not assumed: the 2026-10-29 campaign (001.001.019, gpt-4o) returned
--    PERSON_COUNT = 342753 in EN and FR, recomputed offline as count / number-card.
-- 2. Adds two grouped-aggregate questions (a label plus one count, ordered), the only family
--    that voice-agent 1.3.11 draws as ranked bars. The census of 2026-10-30 found 103 evals
--    emitting ranked-bars, ALL on entity rows (lists ordered by POPULARITY or VOTE_AVERAGE),
--    none on a grouped aggregate. result_shape is DELIBERATELY EMPTY on both (house rule, do
--    not assert a shape not yet observed): assert 'result_kind == unknown; representation ==
--    ranked-bars' only after a run confirms it.
--
-- ROUTING: UPDATE and INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/result-shape-batch-20261030.sql
--
-- CONVENTIONS: as new-evaluations-20261029.sql (auto-increment id, NOT EXISTS guard on the
-- English QUESTION through a derived table, &gt; stored HTML-escaped).

-- ===== 1. Shape assertion on eval 792 (guarded: only while still empty) =====
UPDATE T_WC_T2S_EVALUATION
   SET ASSERTIONS_RESULT_SHAPE = 'result_kind == count; representation == number-card'
 WHERE ID_T2S_EVALUATION = 792
   AND QUESTION = 'How many persons are there?'
   AND (ASSERTIONS_RESULT_SHAPE IS NULL OR ASSERTIONS_RESULT_SHAPE = '');

-- ===== 2. Grouped aggregates, candidates for ranked-bars =====
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED,
   DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many movies are there in each genre, from most to least?',
  'Combien y a-t-il de films dans chaque genre, du plus au moins nombreux ?',
  55, 1, 0, 0, 0, CURDATE(), 1, 1, 'COUNT(*) &gt; 5', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many movies are there in each genre, from most to least?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED,
   DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which ten countries have produced the most movies, with the number of movies for each?',
  'Quels sont les dix pays qui ont produit le plus de films, avec le nombre de films pour chacun ?',
  8, 1, 0, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 10', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which ten countries have produced the most movies, with the number of movies for each?') AS guard);

-- ===== Verification =====
SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, QUESTION
  FROM T_WC_T2S_EVALUATION
 WHERE ID_T2S_EVALUATION = 792
    OR QUESTION IN (
      'How many movies are there in each genre, from most to least?',
      'Which ten countries have produced the most movies, with the number of movies for each?')
 ORDER BY ID_T2S_EVALUATION;
