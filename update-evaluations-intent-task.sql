-- Label the shape-asserted questions with the task the intent classifier must read
-- (`intent.task` clause of ASSERTIONS_RESULT_SHAPE, phase 1 of the result-representations
-- epic, FASTAPI-TEXT2SQL-353). Vocabulary and labels validated by Philippe on 2026-11-08: list,
-- value, rank, count, compare, sequence, trend. Written 2026-11-08.
--
-- WHAT THIS FILE DOES
-- Appends `; intent.task == <task>` to the result-shape assertion of the 82 questions that
-- carry one. `list` (added by Philippe the same day) covers a plain list or the page of one
-- entity: 3 "Which movies were filmed in 70mm format?", 79 and 80, the two id lookups.
-- The clause is OUT OF SCORE (like the whole column) and, on any API before -353, NOT EMITTED:
-- check-result-shape.py reports it apart, so the 1.1.20 shape figures (82, 60 PASS, 22 FAIL)
-- do not move. Baseline on 1.1.20: 82 intent clauses not emitted per language.
--
-- Cases worth a look: 2582 and 2588 ("How many episodes does The Simpsons have?", "How many
-- seasons does Game of Thrones have?") are `value`, not `count`: an attribute of one entity,
-- whatever the "how many"; 2558 and 2559 (counts per group, from most to least) are `rank`;
-- 2561, 2563 and 2565 ("with the budget of each, in release order") are `value`, the order
-- being the natural one of the series, not the task.
--
-- ROUTING: UPDATE on T_WC_T2S_EVALUATION only: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/update-evaluations-intent-task.sql
-- Guarded: a row that already carries an intent.task clause is left alone, so a re-run does
-- nothing. Expected: 82 rows changed, then the SELECT shows the 82 assertions, each with its task.

UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_RESULT_SHAPE = CONCAT(ASSERTIONS_RESULT_SHAPE, '; intent.task == list')
WHERE ID_T2S_EVALUATION IN (3, 79, 80)
  AND ASSERTIONS_RESULT_SHAPE NOT LIKE '%intent.task%';

UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_RESULT_SHAPE = CONCAT(ASSERTIONS_RESULT_SHAPE, '; intent.task == count')
WHERE ID_T2S_EVALUATION IN (29, 790, 791, 792, 2551, 2552, 2553, 2580, 2581, 2583, 2584, 2585, 2586, 2587, 2589)
  AND ASSERTIONS_RESULT_SHAPE NOT LIKE '%intent.task%';

UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_RESULT_SHAPE = CONCAT(ASSERTIONS_RESULT_SHAPE, '; intent.task == value')
WHERE ID_T2S_EVALUATION IN (2524, 2549, 2550, 2554, 2555, 2556, 2663, 2582, 2588,
                            2560, 2561, 2562, 2563, 2564, 2565, 2566, 2567, 2568, 2569)
  AND ASSERTIONS_RESULT_SHAPE NOT LIKE '%intent.task%';

UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_RESULT_SHAPE = CONCAT(ASSERTIONS_RESULT_SHAPE, '; intent.task == rank')
WHERE ID_T2S_EVALUATION IN (1125, 2214, 2513, 2558, 2559, 2570, 2571, 2572, 2573, 2574, 2575, 2576, 2577, 2578, 2579)
  AND ASSERTIONS_RESULT_SHAPE NOT LIKE '%intent.task%';

UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_RESULT_SHAPE = CONCAT(ASSERTIONS_RESULT_SHAPE, '; intent.task == compare')
WHERE ID_T2S_EVALUATION IN (2590, 2591, 2592, 2593, 2594, 2595, 2596, 2597, 2598, 2599)
  AND ASSERTIONS_RESULT_SHAPE NOT LIKE '%intent.task%';

UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_RESULT_SHAPE = CONCAT(ASSERTIONS_RESULT_SHAPE, '; intent.task == sequence')
WHERE ID_T2S_EVALUATION IN (2600, 2601, 2602, 2603, 2604, 2605, 2606, 2607, 2608, 2609)
  AND ASSERTIONS_RESULT_SHAPE NOT LIKE '%intent.task%';

UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_RESULT_SHAPE = CONCAT(ASSERTIONS_RESULT_SHAPE, '; intent.task == trend')
WHERE ID_T2S_EVALUATION IN (2610, 2611, 2612, 2613, 2614, 2615, 2616, 2617, 2618, 2619)
  AND ASSERTIONS_RESULT_SHAPE NOT LIKE '%intent.task%';

-- Check: every shape-asserted question, with its task.
SELECT ID_T2S_EVALUATION, ASSERTIONS_RESULT_SHAPE
FROM T_WC_T2S_EVALUATION
WHERE DELETED = 0 AND ASSERTIONS_RESULT_SHAPE IS NOT NULL AND ASSERTIONS_RESULT_SHAPE <> ''
ORDER BY ID_T2S_EVALUATION;
