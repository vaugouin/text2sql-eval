-- Open the 83 image evaluations to the campaigns (FASTAPI-TEXT2SQL-277), written 2026-11-10.
--
-- new-evaluations-vision.sql inserted 2732 to 2814 with IS_EVAL = 0 on purpose: the evaluator of
-- the day did not know INPUT_KIND. It does since 2.21.0 (--input-kind image), and a text run
-- leaves image rows out by INPUT_KIND, so they can carry IS_EVAL = 1 safely. An evaluator older
-- than 2.21.0 still never picks them: it requires a non-empty QUESTION, and theirs is empty.
-- IS_SAMPLE stays 0: the samples page shows questions, and these have none.
--
-- ROUTING: UPDATE on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/update-evaluations-vision-is-eval.sql
-- Expected: 83 rows changed on the first run, 0 on a rerun.

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

UPDATE T_WC_T2S_EVALUATION
   SET IS_EVAL = 1, TIM_UPDATED = NOW()
 WHERE INPUT_KIND = 'image' AND DELETED = 0 AND IS_EVAL = 0
   AND ID_T2S_EVALUATION BETWEEN 2732 AND 2814;

SELECT ROW_COUNT() AS ROWS_CHANGED;

SELECT IS_EVAL, IS_SAMPLE, COUNT(*) AS N, MIN(ID_T2S_EVALUATION) AS FIRST_ID, MAX(ID_T2S_EVALUATION) AS LAST_ID
  FROM T_WC_T2S_EVALUATION WHERE INPUT_KIND = 'image' AND DELETED = 0
 GROUP BY IS_EVAL, IS_SAMPLE;
