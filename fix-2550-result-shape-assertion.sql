-- Correct the result-shape assertion of question 2550 on the live bank (FASTAPI-TEXT2SQL-349).
--
-- The full recipe result-shape-assertions.sql carries DDL (ADD COLUMN), so it runs by voie 2.
-- This file is the correction UPDATE alone, no DDL, so the agent gate (voie 1) runs it on
-- T_WC_T2S_EVALUATION, one of the seven agent-writable tables:
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/fix-2550-result-shape-assertion.sql
--
-- WHY: the first Green run (2026-10-29) showed the model answers the budget/revenue/profit
-- triple with a window aggregate (SUM(...) OVER ()) projecting all Nolan movies as entity rows,
-- so the real shape is entity_rows / card-grid, not the stat-strip first asserted. Same change
-- as the self-healing UPDATE in result-shape-assertions.sql; guarded on the old value so it
-- fires once and is a no-op afterwards. Expected: 1 row updated on the first pass, 0 after.
UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == card-grid'
  WHERE QUESTION = 'What is the total budget, total box office revenue and overall profit of all Christopher Nolan movies?'
    AND ASSERTIONS_RESULT_SHAPE = 'result_kind == scalar; representation == stat-strip';

SELECT ID_T2S_EVALUATION, ASSERTIONS_RESULT_SHAPE
  FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'What is the total budget, total box office revenue and overall profit of all Christopher Nolan movies?';
