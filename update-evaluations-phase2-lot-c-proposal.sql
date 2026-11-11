-- PROPOSAL, NOT RUN: result_shape assertion changes on existing evaluations, for Philippe to accept or
-- drop (phase 2 lot C, 2026-11-11).
--
-- Why. Phase 2 lot C (fastapi-text2sql, result_shape.py) draws a result whose rows are countries as a
-- flag-list (the flag, the name, the count), with ranked-bars kept as an option. Two asserted
-- questions of the bank rank countries by a count, and the census of the 1.1.20 exports (2026-11-08
-- campaign) lists exactly these as its regressions, in both languages:
--   2559  Which ten countries have produced the most movies, with the number of movies for each?
--   2577  Which countries have produced the most TV series? Top 10
-- Their rows are a COUNTRY_CODE and a count: the flag list with the count beside each flag answers
-- them, and "as a chart" still gives the bars. With this file (and lot B's proposal,
-- update-evaluations-phase2-lot-b-proposal.sql, which stays a separate decision) the census counts
-- no regression: 92 of 98 shape assertions pass in English, 90 of 97 in French, as before lot C.
-- The one other flip, 2230 ("What are the filming locations of tv series Game of Thrones?", ten
-- locations that are all countries), carries no shape assertion and needs none.
--
-- What changes. Only the representation clause of ASSERTIONS_RESULT_SHAPE; the unit and intent.task
-- clauses stay. The result_shape column is out of score: no campaign number moves. Each UPDATE is
-- guarded on the exact current value, so a re-run does nothing and an edit made in between withdraws
-- it.
--
-- ROUTING if accepted: UPDATEs on T_WC_T2S_EVALUATION only: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/update-evaluations-phase2-lot-c-proposal.sql

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2559: Which ten countries have produced the most movies, with the number of movies for each?
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'representation == flag-list; unit(*) == count; intent.task == rank', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2559 AND ASSERTIONS_RESULT_SHAPE = 'representation == ranked-bars; unit(*) == count; intent.task == rank';

-- 2577: Which countries have produced the most TV series? Top 10
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'representation == flag-list; intent.task == rank', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2577 AND ASSERTIONS_RESULT_SHAPE = 'representation == ranked-bars; intent.task == rank';

-- Read-back.
SELECT ID_T2S_EVALUATION, QUESTION, ASSERTIONS_RESULT_SHAPE, TIM_UPDATED
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION IN (2559, 2577)
ORDER BY ID_T2S_EVALUATION;
