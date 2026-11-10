-- New evaluations for FASTAPI-TEXT2SQL-367 (first shape) and FASTAPI-TEXT2SQL-340, written
-- 2026-11-10 before any code (Philippe: "1, 2 et 3 dans la suite").
--
-- -367, FIRST SHAPE. A question that names an actor and describes ONE of their works is a
-- descriptive identification, but the complex model sometimes takes the -221 relationship branch
-- ("the series linked to Keri Russell") and answers authoritative_empty: no rewrite, no retry,
-- the error "Complex entity resolution is required". 2641 (Keri Russell, The Diplomat) is the
-- known case; four more built the same way, a named actor plus one role description:
--   1. Tom Hanks, FedEx employee on a desert island -> 8358 Cast Away (2000), credit Chuck Noland.
--   2. Meryl Streep, editor of a fashion magazine -> 350 The Devil Wears Prada (2006), Miranda Priestly.
--   3. Jim Carrey, his whole life is a television show -> 37165 The Truman Show (1998), Truman Burbank.
--   4. Bryan Cranston, chemistry teacher making meth -> series 1396 Breaking Bad (2008), Walter
--      White. 2285 asks the same series without the actor; this one tests the actor branch.
-- The second shape of -367 (Tarantino) is already covered by 2710 (-373 file).
-- Category 60 (movie descriptions) and 62 (series descriptions), as 2630 and 2641.
--
-- -340. "Who plays Spider-Man" generates CAST_CHARACTER = 'Spider-Man' (exact), which matches 2
-- credits in the base; the leads are credited 'Peter Parker / Spider-Man' (13 credits) or
-- 'Spider-Man / Peter Parker' (5). check-367-340-ids-20261110.txt lists everyone credited with
-- either name: Tom Holland 1136406 (10 films), Tobey Maguire 2219 (7), Andrew Garfield 37625 (5).
--   5. "Who plays Spider-Man in the movies?"
--   6. "Which actors have played Peter Parker in the movies?" (alter ego)
-- Assertion: the three leads, coverage (IN accepts extra rows: the animated voices and Nicholas
-- Hammond are legitimate). No NOT IN: the fix direction is containment, under which the obscure
-- 'Spider-Man' credits also come back, ordered after the leads by popularity. Category 32
-- (character actors), as 2528 Philip Marlowe.
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1; IS_SHOWCASE = 1 on the four single works, 0 on the lists.
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-367-340.sql
--
-- CONVENTIONS as new-evaluations-373-misattributed-crew-role.sql: auto-increment id, each INSERT
-- guarded by NOT EXISTS on the English QUESTION, DELETED = 0, DAT_CREAT = CURDATE(), owner 1.

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'In which film does Tom Hanks play a FedEx employee stranded on a desert island?',
       'Dans quel film Tom Hanks joue-t-il un employé de FedEx échoué sur une île déserte ?',
       60, 1, 1, 1, 0, CURDATE(), 1, 1,
       'COUNT(*) == 1 AND ID_MOVIE IN (8358)', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'In which film does Tom Hanks play a FedEx employee stranded on a desert island?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'In which film does Meryl Streep play the tyrannical editor of a New York fashion magazine?',
       'Dans quel film Meryl Streep joue-t-elle la rédactrice en chef tyrannique d''un magazine de mode new-yorkais ?',
       60, 1, 1, 1, 0, CURDATE(), 1, 1,
       'COUNT(*) == 1 AND ID_MOVIE IN (350)', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'In which film does Meryl Streep play the tyrannical editor of a New York fashion magazine?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'In which film does Jim Carrey play a man who discovers that his whole life is a television show?',
       'Dans quel film Jim Carrey joue-t-il un homme qui découvre que toute sa vie est une émission de télévision ?',
       60, 1, 1, 1, 0, CURDATE(), 1, 1,
       'COUNT(*) == 1 AND ID_MOVIE IN (37165)', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'In which film does Jim Carrey play a man who discovers that his whole life is a television show?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'In which series does Bryan Cranston play a chemistry teacher who starts making methamphetamine?',
       'Dans quelle série Bryan Cranston joue-t-il un professeur de chimie qui se met à fabriquer de la méthamphétamine ?',
       62, 1, 1, 1, 0, CURDATE(), 1, 1,
       'COUNT(*) == 1 AND ID_SERIE IN (1396)', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'In which series does Bryan Cranston play a chemistry teacher who starts making methamphetamine?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Who plays Spider-Man in the movies?',
       'Qui joue Spider-Man au cinéma ?',
       32, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (1136406, 2219, 37625)', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Who plays Spider-Man in the movies?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which actors have played Peter Parker in the movies?',
       'Quels acteurs ont joué Peter Parker au cinéma ?',
       32, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (1136406, 2219, 37625)', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which actors have played Peter Parker in the movies?') AS guard);

-- The new rows.
SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_SAMPLE, IS_SHOWCASE, ASSERTIONS_QUERY_RESULT
  FROM T_WC_T2S_EVALUATION
  WHERE QUESTION IN ('In which film does Tom Hanks play a FedEx employee stranded on a desert island?', 'In which film does Meryl Streep play the tyrannical editor of a New York fashion magazine?', 'In which film does Jim Carrey play a man who discovers that his whole life is a television show?', 'In which series does Bryan Cranston play a chemistry teacher who starts making methamphetamine?', 'Who plays Spider-Man in the movies?', 'Which actors have played Peter Parker in the movies?')
  ORDER BY ID_T2S_EVALUATION;
