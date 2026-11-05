-- Bank changes after the full campaign on 1.1.20 (TEXT2SQL-EVAL-003, 2026-11-04/05, gpt-6-sol,
-- English and French), decided by Philippe on 2026-11-05.
--
--   1125, 2214, 2513 (FASTAPI-TEXT2SQL-351) and 2558, 2559 (FASTAPI-TEXT2SQL-350): the five
--        rankings come out `ranked-bars` with the ordered metric column in both languages since
--        1.1.20 (1125 REVENUE, 2214 BUDGET, 2513 NUMBER_OF_SEASONS, 2558 and 2559 the film count).
--        The bank only checked the ids returned; the shape assertion now locks the representation,
--        so a future version that renders them as a card grid again fails the check. `unit(any)`
--        on the three entity rankings, whose standard projection carries other metric columns;
--        `unit(*)` on the two grouped aggregates, whose only metric is the count. 2559 has no
--        `result_kind` clause: countries have no entity table, the API labels it `unknown` today.
--   2513 French question repaired: the stored text was "Liste les séries télévisées Анимация avec
--        The Most saisons" (one Cyrillic word, two English ones). It passed anyway. The guard
--        avoids the Cyrillic literal.
--   2554 and 2556 (FASTAPI-TEXT2SQL-364): the campaign answered the single total with the eight
--        films and the total repeated on each row (SUM(...) OVER ()), or with the collection row
--        and the total in a subquery, and `CELL(0, 0) > 0` read an id and passed. The assertion
--        now requires one row and a floor on the true value: 1178 minutes for the eight Harry
--        Potter films, 7.76 billion dollars of revenue. The collection row (ID_T2S_COLLECTION 91)
--        and the film rows (eight) both fail it. The prompt rule shipped the same day in
--        fastapi-text2sql ec56c9d.
--
-- Each UPDATE is guarded on the id, the English question and the old value, so it fires once and
-- is a no-op afterwards. Expected: 7 rows updated on the first pass, 0 after; the SELECT shows the
-- seven rows as they stand.
--
-- ROUTING: UPDATEs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/update-evaluations-20261105.sql
-- Commit and push before running. Then refresh the bank to the PC (phase 31 export + sync).
--
-- CONVENTIONS (as update-evaluations-20261101.sql): `>` stored as &gt; in query_result; result_shape
-- uses == only; the French twin keeps the same assertions (one row carries both languages).

UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == ranked-bars; unit(any) == usd'
  WHERE ID_T2S_EVALUATION = 1125
    AND QUESTION = 'What are the highest grossing pictures of all times and what revenue for each movie?'
    AND ASSERTIONS_RESULT_SHAPE IS NULL;

UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == ranked-bars; unit(any) == usd'
  WHERE ID_T2S_EVALUATION = 2214
    AND QUESTION = 'What are the highest budget ever for a movie? List 10 movies and show the budget'
    AND ASSERTIONS_RESULT_SHAPE IS NULL;

UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == ranked-bars; unit(any) == count',
      QUESTION_FR = 'Liste les séries télévisées d''animation avec le plus de saisons'
  WHERE ID_T2S_EVALUATION = 2513
    AND QUESTION = 'List animation tv series with the most seasons'
    AND QUESTION_FR LIKE 'Liste les séries télévisées % avec The Most saisons'
    AND ASSERTIONS_RESULT_SHAPE IS NULL;

UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == ranked-bars; unit(*) == count'
  WHERE ID_T2S_EVALUATION = 2558
    AND QUESTION = 'How many movies are there in each genre, from most to least?'
    AND ASSERTIONS_RESULT_SHAPE IS NULL;

UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_RESULT_SHAPE = 'representation == ranked-bars; unit(*) == count'
  WHERE ID_T2S_EVALUATION = 2559
    AND QUESTION = 'Which ten countries have produced the most movies, with the number of movies for each?'
    AND ASSERTIONS_RESULT_SHAPE IS NULL;

UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_QUERY_RESULT = 'COUNT(*) == 1 AND CELL(0, 0) &gt; 1000'
  WHERE ID_T2S_EVALUATION = 2554
    AND QUESTION = 'How long would it take to watch all the Harry Potter movies back to back?'
    AND ASSERTIONS_QUERY_RESULT = 'CELL(0, 0) &gt; 0';

UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_QUERY_RESULT = 'COUNT(*) == 1 AND CELL(0, 0) &gt; 1000000000'
  WHERE ID_T2S_EVALUATION = 2556
    AND QUESTION = 'What is the total revenue of all Harry Potter movies?'
    AND ASSERTIONS_QUERY_RESULT = 'CELL(0, 0) &gt; 0';

SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE
  FROM T_WC_T2S_EVALUATION
  WHERE ID_T2S_EVALUATION IN (1125, 2214, 2513, 2554, 2556, 2558, 2559)
  ORDER BY ID_T2S_EVALUATION;
