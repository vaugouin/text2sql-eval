-- Bank corrections after the 1.1.19 baseline of the phase 1 evaluations (TEXT2SQL-EVAL-003,
-- campaign of 2026-11-01, four arms: gpt-6-sol and claude-opus-5-5, English and French).
--
-- Decisions of Philippe, 2026-11-01, on the bank fixes proposed in the study (Nestor
-- projets/t2s-backlog/result-representations-answer-forms-study.md, section 9):
--
--   2582 "How many episodes does The Simpsons have?" and 2588 "How many seasons does Game of
--        Thrones have?": the API answers with the series row in all four arms (entity-page:
--        ID_SERIE, SERIE_TITLE, ..., NUMBER_OF_SEASONS, NUMBER_OF_EPISODES), so CELL(0, 0) read
--        ID_SERIE (456 and 1399) and both failed although the values were right (816 episodes,
--        8 seasons). The assertion now names the column, with the every-row form of the DSL
--        (README 4.3) and COUNT(*) == 1 kept. On the answer form: an attribute of one entity,
--        not a count; the shape assertion states what the API does today (entity-page) until
--        the fact-card representation of phase 2 exists.
--   2584 "How many actors have played James Bond?": unchanged, 6 is the true value (the Eon
--        actors). The API counts every TMDb credit of the character (12 persons in movies, 13
--        with the series credits). A failing evaluation on purpose: it closes FASTAPI-TEXT2SQL-359.
--   2614 "What is the average runtime of films by decade?": the shape assertion named the
--        average column `AVERAGE_RUNTIME_MINUTES`, an alias the model chooses (the French run
--        wrote DUREE_MOYENNE_MINUTES, Claude AVG_RUNTIME, all tagged minutes by the API). The
--        `*` form cannot help: DECADE is typed metric too. The assertion now uses the
--        `unit(any)` clause added to the grammar in 2.18.0: at least one column carries minutes.
--
-- Each UPDATE is guarded on the id, the English question and the old assertion, so it fires once
-- and is a no-op afterwards. Expected: 3 rows updated on the first pass, 0 after; the SELECT
-- shows the four rows as they stand (2584 unchanged).
--
-- ROUTING: UPDATEs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/update-evaluations-20261101.sql
-- Commit and push before running. Then refresh the bank to the PC (phase 31 export + sync).
--
-- CONVENTIONS (as new-evaluations-20261031.sql): `>` stored as &gt; in query_result; result_shape
-- uses == only; the French twin keeps the same assertions (one row carries both languages).

UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_QUERY_RESULT = 'COUNT(*) == 1 AND NUMBER_OF_EPISODES &gt; 700',
      ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == entity-page'
  WHERE ID_T2S_EVALUATION = 2582
    AND QUESTION = 'How many episodes does The Simpsons have?'
    AND ASSERTIONS_QUERY_RESULT = 'COUNT(*) == 1 AND CELL(0, 0) &gt; 700';

UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_QUERY_RESULT = 'COUNT(*) == 1 AND NUMBER_OF_SEASONS == 8',
      ASSERTIONS_RESULT_SHAPE = 'result_kind == entity_rows; representation == entity-page'
  WHERE ID_T2S_EVALUATION = 2588
    AND QUESTION = 'How many seasons does Game of Thrones have?'
    AND ASSERTIONS_QUERY_RESULT = 'COUNT(*) == 1 AND CELL(0, 0) == 8';

UPDATE T_WC_T2S_EVALUATION
  SET ASSERTIONS_RESULT_SHAPE = 'representation == table; unit(any) == minutes'
  WHERE ID_T2S_EVALUATION = 2614
    AND QUESTION = 'What is the average runtime of films by decade?'
    AND ASSERTIONS_RESULT_SHAPE = 'representation == table; unit(AVERAGE_RUNTIME_MINUTES) == minutes';

SELECT ID_T2S_EVALUATION, QUESTION, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE
  FROM T_WC_T2S_EVALUATION
  WHERE ID_T2S_EVALUATION IN (2582, 2584, 2588, 2614)
  ORDER BY ID_T2S_EVALUATION;
