-- Result-shape assertions of the sequence and trend questions, moved to the phase 2 lot A
-- representations (2026-11-10). Approved by Philippe on 2026-11-10.
--
-- WHY. The twenty questions 2600-2619 (new-evaluations-20261031.sql, sections E and F) assert
-- what 1.1.19 emitted: `card-grid` for a sequence ("The Godfather trilogy in order") and
-- `table` for a trend ("How many films were released each year since 2000?"). Phase 2 lot A
-- (study section 6, Philippe 2026-11-10) gives each its own form:
--   * sequence, 2600-2609: `sequence-strip`, a numbered row of posters with the year, order
--     kept (intent.task sequence; the rows are entities ordered by date or collection order);
--   * trend, 2610-2619: `trend-columns`, one column per year or decade (intent.task trend; a
--     grouped aggregate, one label plus one metric).
-- Eval-driven, as phase 1: these FAIL on 1.1.20 until the shape rule lands. The query_result
-- assertions and the intent.task clauses are untouched; only the representation clause moves.
--
-- ROUTING: UPDATEs on T_WC_T2S_EVALUATION only: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/update-evaluations-phase2-lot-a.sql
-- Expected: section 1 shows 10 + 10 rows with the old clause, section 2 updates 10 and 10,
-- section 3 shows the new clauses.

-- 1. Before.
SELECT ID_T2S_EVALUATION, ASSERTIONS_RESULT_SHAPE
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION BETWEEN 2600 AND 2619
ORDER BY ID_T2S_EVALUATION;

-- 2. Move the representation clause (guarded on the current value).
UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_RESULT_SHAPE = REPLACE(ASSERTIONS_RESULT_SHAPE, 'representation == card-grid', 'representation == sequence-strip')
WHERE ID_T2S_EVALUATION BETWEEN 2600 AND 2609
  AND ASSERTIONS_RESULT_SHAPE LIKE '%representation == card-grid%'
  AND ASSERTIONS_RESULT_SHAPE LIKE '%intent.task == sequence%';

UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_RESULT_SHAPE = REPLACE(ASSERTIONS_RESULT_SHAPE, 'representation == table', 'representation == trend-columns')
WHERE ID_T2S_EVALUATION BETWEEN 2610 AND 2619
  AND ASSERTIONS_RESULT_SHAPE LIKE '%representation == table%'
  AND ASSERTIONS_RESULT_SHAPE LIKE '%intent.task == trend%';

-- 3. After.
SELECT ID_T2S_EVALUATION, ASSERTIONS_RESULT_SHAPE
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION BETWEEN 2600 AND 2619
ORDER BY ID_T2S_EVALUATION;
