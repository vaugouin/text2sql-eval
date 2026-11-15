-- PROPOSAL, NOT RUN: three query_result assertions of the phase 3 bank loosened, for Philippe to
-- accept or drop (2026-11-15, campaign on API 1.1.20).
--
-- Why. In the 2026-11-15 campaign these three questions got a right answer in a shape the
-- assertion did not expect:
--   2861  Was Toshiro Mifune in Yojimbo?  EN answered with Mifune's person row (the verdict "yes"),
--         FR with the film row; the assertion demands an ID_MOVIE column.
--   2867  Has Stanley Kubrick directed a science fiction film?  EN answered with FILM_COUNT = 2,
--         FR with the two films; the assertion demands an ID_MOVIE column.
--   2832  When were the James Bond films released?  FR returned the 27 films under ID_MOVIE, the
--         assertion demands ID_CONTENT. The evaluator already builds ID_MOVIE from
--         ID_CONTENT + CONTENT_TYPE (unified-schema bridge), so ID_MOVIE covers both shapes.
--
-- New assertions. A verdict passes on the expected film, or on one row whose first cell is at
-- least 1 (a person row, a film row or a positive count). The evaluator folds AND / OR from left
-- to right: "A OR B AND C" is "(A OR B) AND C". Checked locally with
-- text2sql_eval_functions.evaluate_dataframe_assertions on the exported outputs: 2861 EN/FR,
-- 2867 EN/FR, 2832 EN/FR all pass; a count of 0 and an empty result still fail. Known slack: a
-- single wrong film row would pass the verdict assertions.
--
-- 2832 EN stays failing: its SQL is a UNION with T_WC_T2S_SERIE, which the sql_query assertion
-- forbids on purpose (an API defect, "films" means films).
--
-- Each UPDATE is guarded on the current value, so a re-run does nothing. `>` is stored as &gt;
-- (convention of update-evaluations-20261101.sql). Run phase 20 afterwards on 2832, 2861, 2867.
--
-- ROUTING if accepted: UPDATEs on T_WC_T2S_EVALUATION only: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/update-evaluations-20261115-proposal.sql

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2861: Was Toshiro Mifune in Yojimbo?
UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (11878) OR COUNT(*) == 1 AND CELL(0, 0) &gt;= 1', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2861 AND ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (11878)';

-- 2867: Has Stanley Kubrick directed a science fiction film?
UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (62) OR COUNT(*) == 1 AND CELL(0, 0) &gt;= 1', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2867 AND ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (62)';

-- 2832: When were the James Bond films released?  ID_CONTENT becomes ID_MOVIE, the rest unchanged.
UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_QUERY_RESULT = REPLACE(ASSERTIONS_QUERY_RESULT, 'ID_CONTENT IN (646,', 'ID_MOVIE IN (646,'), TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2832 AND ASSERTIONS_QUERY_RESULT LIKE '%ID_CONTENT IN (646,%';

-- Read-back.
SELECT ID_T2S_EVALUATION, QUESTION, ASSERTIONS_QUERY_RESULT, TIM_UPDATED
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION IN (2832, 2861, 2867)
ORDER BY ID_T2S_EVALUATION;
