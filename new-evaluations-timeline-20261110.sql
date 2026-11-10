-- New evaluations for the result representations, phase 2 lot A: the timeline (2026-11-10).
--
-- Study: Nestor projets/t2s-backlog/result-representations-answer-forms-study.md, section 6
-- (phase 2) and axis D ("When were the Batman films released?": dots on a year axis with
-- posters). Lot A of phase 2 (Philippe, 2026-11-10): sequence-strip, trend-columns, timeline,
-- plus the voice "as a table" route; API stays 1.1.20; bank first, then code.
--
-- WHAT THIS FILE DOES
-- Adds ten "when" questions, English with a French twin, each with a scored query_result
-- assertion and the out-of-score result_shape the phase 2 rule must emit: `timeline` for
-- entity rows whose focus is a date (intent.task value, focus DAT_RELEASE). Today, 1.1.20 with
-- -354, all twenty calls come out `value-cards` with DAT_RELEASE in focus: the shape assertion
-- FAILS on purpose until the rule lands (eval-driven, as new-evaluations-20261031.sql).
-- The sequence questions ("in order", 2600-2609) stay apart: an order without a date question
-- is a numbered strip, `sequence-strip` (update-evaluations-phase2-lot-a.sql).
--
-- EVERY ANSWER WAS CHECKED ON BLUE (1.1.20, b8e1fff and later) ON 2026-11-10, both languages.
-- Two rewordings after the check: "When did Christopher Nolan's feature films come out?"
-- returned his producer credits (Man of Steel, Batman v Superman), and the Miyazaki twin
-- returned 39 rows of animation credits; both now say "directed by". "When were the Star Wars
-- Skywalker saga films released?" returned no row (left out here, a resolver defect to file).
--
-- FLAGS: IS_EVAL = 1 and IS_SAMPLE = 1 on all ten; IS_SHOWCASE = 1 on the nine whose
-- query_result lists entity ids (T01 asserts a count, see its comment).
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/new-evaluations-timeline-20261110.sql
-- Commit and push before running. Then refresh the bank to the PC (phase 31 export + sync).
--
-- CONVENTIONS (as new-evaluations-20261031.sql): auto-increment id; each INSERT guarded by NOT
-- EXISTS on the English QUESTION; DELETED = 0; DAT_CREAT = CURDATE(); owner 1; result_shape
-- uses == only. French twins carry their accents: the runner sets utf8mb4.


-- ===== Section T : timeline (phase 2 target: timeline) ; intent.task = value, focus a date =====

-- T01 : Harry Potter: 8 rows on Blue 2026-11-10 but ordered by rating and aliased ID_CONTENT/DAT_FIRST_AIR (movie collection written as mixed content), so the floor is a count
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'When were the Harry Potter films released?', 'Quand les films Harry Potter sont-ils sortis ?', 47, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 8', 'representation == timeline; intent.task == value'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'When were the Harry Potter films released?') AS guard);

-- T02 : Terminator: six films 1984 to 2019, same in both languages
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'When were the Terminator films released?', 'Quand les films Terminator sont-ils sortis ?', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (218, 280, 296, 534, 87101, 290859)', 'representation == timeline; intent.task == value'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'When were the Terminator films released?') AS guard);

-- T03 : Alien: the four films of the original series
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'When did the Alien films come out?', 'Quand sont sortis les films Alien ?', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (348, 679, 8077, 8078)', 'representation == timeline; intent.task == value'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'When did the Alien films come out?') AS guard);

-- T04 : Mission: Impossible: eight films 1996 to 2025
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'When were the Mission: Impossible films released?', 'Quand les films Mission impossible sont-ils sortis ?', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (954, 955, 956, 56292, 177677, 353081, 575264, 575265)', 'representation == timeline; intent.task == value'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'When were the Mission: Impossible films released?') AS guard);

-- T05 : Nolan as director: 18 rows (shorts and a compilation included); the counter-example is the producer credits a looser wording returned (Man of Steel, Batman v Superman)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'When were the films directed by Christopher Nolan released?', 'Quand sont sortis les films réalisés par Christopher Nolan ?', 4, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (11660, 77, 320, 272, 1124, 155, 27205, 49026, 157336, 374720, 577922) AND ID_MOVIE NOT IN (49521, 209112)', 'representation == timeline; intent.task == value'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'When were the films directed by Christopher Nolan released?') AS guard);

-- T06 : Pirates of the Caribbean: five films 2003 to 2017
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'When were the Pirates of the Caribbean films released?', 'Quand les films Pirates des Caraïbes sont-ils sortis ?', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (22, 58, 285, 1865, 166426)', 'representation == timeline; intent.task == value'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'When were the Pirates of the Caribbean films released?') AS guard);

-- T07 : Jurassic Park: seven films; the question says years, the API adds RELEASE_YEAR next to DAT_RELEASE
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'In which years were the Jurassic Park films released?', 'En quelles années les films Jurassic Park sont-ils sortis ?', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (329, 330, 331, 135397, 351286, 507086, 1234821)', 'representation == timeline; intent.task == value'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'In which years were the Jurassic Park films released?') AS guard);

-- T08 : Miyazaki as director, feature films: 14 rows, the twelve canonical features anchor the floor; EN came out newest first, FR oldest first (a timeline orders by date whatever the SQL order)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'When were the feature films directed by Hayao Miyazaki released?', 'Quand sont sortis les longs métrages réalisés par Hayao Miyazaki ?', 4, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (15371, 81, 10515, 8392, 16859, 11621, 128, 129, 4935, 12429, 149870, 508883)', 'representation == timeline; intent.task == value'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'When were the feature films directed by Hayao Miyazaki released?') AS guard);

-- T09 : Back to the Future: the trilogy, three dates within five years (a dense axis)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'When were the Back to the Future films released?', 'Quand les films Retour vers le futur sont-ils sortis ?', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (105, 165, 196)', 'representation == timeline; intent.task == value'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'When were the Back to the Future films released?') AS guard);

-- T10 : Mad Max: five dated films over 45 years plus one undated project (the timeline must leave it off the axis)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'When were the Mad Max films released?', 'Quand les films Mad Max sont-ils sortis ?', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (9659, 8810, 9355, 76341, 786892)', 'representation == timeline; intent.task == value'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'When were the Mad Max films released?') AS guard);
