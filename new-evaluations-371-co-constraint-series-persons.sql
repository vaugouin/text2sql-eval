-- New evaluations for the co-constrained rescue beyond movie titles (FASTAPI-TEXT2SQL-369 series
-- branch, and FASTAPI-TEXT2SQL-371, the broader fix: complete any partial entity within the
-- other entities of the question before accepting an empty conjunction). Asked by Philippe on
-- 2026-11-08, written the same day, before any new code.
--
-- WHAT THIS FILE DOES
-- Ten questions with their French twins. Ids measured in
-- fastapi-text2sql/doc/sql/check-371-series-persons-20261108.txt (voie 1, 2026-11-08).
-- A. Series, category 31: a partial series title plus a person credited on the series. The
--    -369 code already has a series path (T_WC_T2S_PERSON_SERIE), never evaluated until now.
--   1. "Breaking" + Bryan Cranston    -> 1396 Breaking Bad.
--   2. "Thrones" + Emilia Clarke      -> 1399 Game of Thrones.
--   3. "Wire" + Dominic West          -> 1438 The Wire (FR title "Sur écoute").
--   4. "Bureau" + Mathieu Kassovitz   -> 62476 Le Bureau des légendes; counter-example the exact
--      homonym 4215 "Le Bureau" (2006), no Kassovitz credit.
--   5. Control, "Lupin" + Omar Sy     -> 96677 Lupin (2021), the exact homonym he is credited on;
--      counter-example the other exact "Lupin" 224763 (2007).
-- B. Persons, category 30, the reverse case: a full title plus a bare surname shared by many
--    persons (Grant 129, Foster 108, Phoenix 17, Jackson 243, Clavier 5, none named by the bare
--    word alone). The surname must be completed within the cast of the resolved film. No code
--    does this today (-371).
--   6. Notting Hill + "Grant"         -> 509 (Hugh Grant, not Cary Grant).
--   7. Taxi Driver + "Foster"         -> 103 (Jodie Foster).
--   8. Gladiator + "Phoenix"          -> 98 (Joaquin Phoenix, not River Phoenix).
--   9. Les Visiteurs + "Clavier"      -> 11687 (Christian Clavier).
--  10. Pulp Fiction + "Jackson"       -> 680 (Samuel L. Jackson).
-- Steve Carell on The Office and Claire Foy on The Crown were measured too and left out: the
-- base has no PERSON_SERIE row joining them (a data gap, not this ticket).
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1 (rule of 2026-10-31), IS_SHOWCASE = 1 (each assertion lists
-- work ids with a poster).
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-371-co-constraint-series-persons.sql
--
-- CONVENTIONS (as archive/new-evaluations-369-partial-title-person.sql): auto-increment id; each INSERT
-- is guarded by NOT EXISTS on the English QUESTION; DELETED = 0; DAT_CREAT = CURDATE(); owner 1.

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Series Breaking with Bryan Cranston', 'Série Breaking avec Bryan Cranston', 31, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_SERIE IN (1396)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Series Breaking with Bryan Cranston') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Series Thrones with Emilia Clarke', 'Série Thrones avec Emilia Clarke', 31, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_SERIE IN (1399)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Series Thrones with Emilia Clarke') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Series Wire with Dominic West', 'Série Wire avec Dominic West', 31, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_SERIE IN (1438)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Series Wire with Dominic West') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Series Bureau with Mathieu Kassovitz', 'Série Bureau avec Mathieu Kassovitz', 31, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_SERIE IN (62476) AND ID_SERIE NOT IN (4215)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Series Bureau with Mathieu Kassovitz') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Series Lupin with Omar Sy', 'Série Lupin avec Omar Sy', 31, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_SERIE IN (96677) AND ID_SERIE NOT IN (224763)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Series Lupin with Omar Sy') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Notting Hill with Grant', 'Film Coup de foudre à Notting Hill avec Grant', 30, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (509)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Notting Hill with Grant') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Taxi Driver with Foster', 'Film Taxi Driver avec Foster', 30, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (103)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Taxi Driver with Foster') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Gladiator with Phoenix', 'Film Gladiator avec Phoenix', 30, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (98)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Gladiator with Phoenix') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie The Visitors with Clavier', 'Film Les Visiteurs avec Clavier', 30, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (11687)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie The Visitors with Clavier') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Pulp Fiction with Jackson', 'Film Pulp Fiction avec Jackson', 30, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (680)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Pulp Fiction with Jackson') AS guard);

-- The new rows.
SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_SAMPLE, IS_SHOWCASE, ASSERTIONS_QUERY_RESULT
  FROM T_WC_T2S_EVALUATION
  WHERE QUESTION IN ('Series Breaking with Bryan Cranston', 'Series Thrones with Emilia Clarke', 'Series Wire with Dominic West', 'Series Bureau with Mathieu Kassovitz', 'Series Lupin with Omar Sy', 'Movie Notting Hill with Grant', 'Movie Taxi Driver with Foster', 'Movie Gladiator with Phoenix', 'Movie The Visitors with Clavier', 'Movie Pulp Fiction with Jackson')
  ORDER BY ID_T2S_EVALUATION;
