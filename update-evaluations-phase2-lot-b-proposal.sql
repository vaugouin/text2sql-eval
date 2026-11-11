-- PROPOSAL, NOT RUN: result_shape assertion changes on existing evaluations, for Philippe to accept or
-- drop (phase 2 lot B, 2026-11-11).
--
-- Why. Phase 2 lot B (fastapi-text2sql, result_shape.py) gives two existing groups of the bank their
-- own form: the ten comparisons of two named entities 2590 to 2599 become compare-cards (they were
-- value-cards, the cards side by side with the winner marked), and the two value questions on one
-- series 2582 and 2588 ("How many episodes does The Simpsons have?") become fact-card (they were the
-- entity page). The census of the 1.1.20 exports (2026-11-08 campaign) lists exactly these as its
-- regressions: 12 in English, 11 in French (2598 FR returns one row, so it stays entity-page and
-- keeps failing its compare assertion, as before). With this file the census has no regression left.
--
-- What changes. Only the representation clause of ASSERTIONS_RESULT_SHAPE; the unit, role and
-- intent.task clauses stay as they are. The result_shape column is out of score: no campaign number
-- moves. Each UPDATE is guarded on the exact current value, so a re-run does nothing and an edit
-- made in between withdraws it.
--
-- ROUTING if accepted: UPDATEs on T_WC_T2S_EVALUATION only: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/update-evaluations-phase2-lot-b-proposal.sql

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2582: How many episodes does The Simpsons have?
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == fact-card; intent.task == value', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2582 AND ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == entity-page; intent.task == value';

-- 2588: How many seasons does Game of Thrones have?
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == fact-card; intent.task == value', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2588 AND ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == entity-page; intent.task == value';

-- 2590: Which is longer, Titanic (1997) or Avatar (2009)?
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'representation == compare-cards; unit(RUNTIME) == minutes; intent.task == compare', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2590 AND ASSERTIONS_RESULT_SHAPE = 'representation == value-cards; unit(RUNTIME) == minutes; intent.task == compare';

-- 2591: Compare the budgets of Avatar (2009) and Avengers: Endgame
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'representation == compare-cards; unit(BUDGET) == usd; intent.task == compare', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2591 AND ASSERTIONS_RESULT_SHAPE = 'representation == value-cards; unit(BUDGET) == usd; intent.task == compare';

-- 2592: Compare the number of seasons of Friends (1994) and Seinfeld
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'representation == compare-cards; unit(NUMBER_OF_SEASONS) == count; intent.task == compare', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2592 AND ASSERTIONS_RESULT_SHAPE = 'representation == value-cards; unit(NUMBER_OF_SEASONS) == count; intent.task == compare';

-- 2593: Which earned more at the box office, Barbie (2023) or Oppenheimer?
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'representation == compare-cards; unit(REVENUE) == usd; intent.task == compare', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2593 AND ASSERTIONS_RESULT_SHAPE = 'representation == value-cards; unit(REVENUE) == usd; intent.task == compare';

-- 2594: Compare the IMDb ratings of The Godfather (1972) and The Godfather Part II
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'representation == compare-cards; intent.task == compare', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2594 AND ASSERTIONS_RESULT_SHAPE = 'representation == value-cards; intent.task == compare';

-- 2595: Who has directed more films, Woody Allen or Martin Scorsese?
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'representation == compare-cards; intent.task == compare', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2595 AND ASSERTIONS_RESULT_SHAPE = 'representation == value-cards; intent.task == compare';

-- 2596: Compare the birth years of Alfred Hitchcock and Orson Welles
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'representation == compare-cards; intent.task == compare', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2596 AND ASSERTIONS_RESULT_SHAPE = 'representation == value-cards; intent.task == compare';

-- 2597: Compare the runtimes of Seven Samurai and The Magnificent Seven (1960)
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'representation == compare-cards; unit(RUNTIME) == minutes; intent.task == compare', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2597 AND ASSERTIONS_RESULT_SHAPE = 'representation == value-cards; unit(RUNTIME) == minutes; intent.task == compare';

-- 2598: Which has more episodes, The Simpsons or South Park?
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'representation == compare-cards; unit(NUMBER_OF_EPISODES) == count; intent.task == compare', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2598 AND ASSERTIONS_RESULT_SHAPE = 'representation == value-cards; unit(NUMBER_OF_EPISODES) == count; intent.task == compare';

-- 2599: Compare the budget and the revenue of Jurassic Park and Jurassic World
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_RESULT_SHAPE = 'representation == compare-cards; intent.task == compare', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2599 AND ASSERTIONS_RESULT_SHAPE = 'representation == value-cards; intent.task == compare';

-- Read-back.
SELECT ID_T2S_EVALUATION, QUESTION, ASSERTIONS_RESULT_SHAPE
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION IN (2582, 2588, 2590, 2591, 2592, 2593, 2594, 2595, 2596, 2597, 2598, 2599)
ORDER BY ID_T2S_EVALUATION;
