-- New evaluations for the critical reception labels (TEXT2SQL-EVAL-015), written 2026-11-28,
-- before the API learns the labels (FASTAPI-TEXT2SQL-425): they are expected to FAIL on the live
-- version (no Reception_label entity, no reception or OMDb table in the SQL) and to pass after it.
--
-- WHAT THIS FILE DOES
-- 1. Adds the category "Movies - Critical Reception Queries" under 1 (Root English evaluations), display order 80.
-- 2. Adds 21 questions with their French twins in it, all IS_EVAL = 1.
--
-- THE DATA BEHIND THE LABELS. T_WC_T2S_RECEPTION_LABEL holds 15 labels read by Claude Haiku from
-- the English Wikipedia page of 75,529 films (critics verdict 1 panned to 5 acclaimed, 6 divided
-- critics, 7 box office hit, 8 bomb, 9 record, 10 cult, 11 notoriously bad, 12 reappraised,
-- 13 controversial, 14 banned, 15 censored; ids checked on 2026-11-28 by check-reception-evals.sql).
-- Rotten Tomatoes and Metacritic come from OMDb (T_WC_OMDB_TITLE), decided by Philippe on
-- 2026-11-28; CinemaScore and the verdicts from the reception tables.
--
-- ASSERTIONS
-- * entity_extraction: a new key Reception_label (closed vocabulary, like Technical_format). Its
--   exact name is decided by FASTAPI-TEXT2SQL-425: if it changes, update these rows, not the API.
-- * sql_query: the label id after resolution (ID_RECEPTION_LABEL = n), like ID_TECHNICAL for the
--   technical formats (eval 2225); for the scores, the column family only (RT_SCORE or ROTTEN,
--   METACRITIC or METASCORE), since FASTAPI-TEXT2SQL-425 may copy them into T_WC_T2S_MOVIE.
-- * query_result: a floor at about half the count measured on 2026-11-28
--   (check-reception-evals-20261128.txt, repeated above each question), so a refresh of the
--   data does not break them.
-- * The last question is a regression guard: "best rated" stays the IMDb audience rating and must
--   not read the reception or OMDb tables.
--
-- FLAGS: IS_SAMPLE = 1 for the list questions (rule of 2026-10-31); IS_SHOWCASE = 0 for all, since
-- no assertion lists entity ids yet (the condition for a showcase card).
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION_CATEGORY and T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-reception-20261128.sql
-- Commit and push before running. Expected: 1 category and 21 questions on the first run, 0 on a
-- rerun (every INSERT is guarded by NOT EXISTS). The final SELECT gives the ids for EVAL_IDS.

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO T_WC_T2S_EVALUATION_CATEGORY
  (DESCRIPTION, DESCRIPTION_FR, LANG, ID_PARENT, DELETED, DISPLAY_ORDER, ID_CREATOR, DAT_CREAT, ID_OWNER, TIM_UPDATED, ID_USER_UPDATED)
SELECT 'Movies - Critical Reception Queries', 'Films - Questions sur l''accueil critique', NULL, 1, 0, 80, 1, CURDATE(), 1, NOW(), 1
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY
    WHERE DESCRIPTION = 'Movies - Critical Reception Queries') AS guard);

-- 01. measured 2026-11-28: 420 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which cult films came out in the 1980s?', 'Quels films cultes sont sortis dans les années 1980 ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Reception_label1&quot;])',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*10\\b)',
  'COUNT(*) &gt; 100', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which cult films came out in the 1980s?') AS guard);

-- 02. measured 2026-11-28: 12 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which Ridley Scott films were box office bombs?', 'Quels films de Ridley Scott ont été des échecs au box-office ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Person_name1&quot;, &quot;Reception_label1&quot;]) AND matches($.Person_name1, /^Ridley Scott$/i)',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*8\\b)',
  'COUNT(*) &gt; 3', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which Ridley Scott films were box office bombs?') AS guard);

-- 03. measured 2026-11-28: 76 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which films were banned in the United Kingdom?', 'Quels films ont été interdits au Royaume-Uni ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Reception_label1&quot;])',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*14\\b)(?=.*\\bDETAIL\\b.*(United Kingdom|Britain|UK))',
  'COUNT(*) &gt; 20', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which films were banned in the United Kingdom?') AS guard);

-- 04. measured 2026-11-28: 91 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Show critically acclaimed science fiction films', 'Montre les films de science-fiction acclamés par la critique',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Movie_genre1&quot;, &quot;Reception_label1&quot;])',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*5\\b)',
  'COUNT(*) &gt; 20', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Show critically acclaimed science fiction films') AS guard);

-- 05. measured 2026-11-28: 42 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which horror films are considered among the worst ever made?', 'Quels films d''horreur sont réputés parmi les pires jamais réalisés ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Movie_genre1&quot;, &quot;Reception_label1&quot;])',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*11\\b)',
  'COUNT(*) &gt; 10', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which horror films are considered among the worst ever made?') AS guard);

-- 06. measured 2026-11-28: 5 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which Stanley Kubrick films caused a controversy?', 'Quels films de Stanley Kubrick ont fait polémique ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Person_name1&quot;, &quot;Reception_label1&quot;]) AND matches($.Person_name1, /^Stanley Kubrick$/i)',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*13\\b)',
  'COUNT(*) &gt; 2', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which Stanley Kubrick films caused a controversy?') AS guard);

-- 07. measured 2026-11-28: 1692 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many films are considered cult films?', 'Combien de films sont considérés comme des films cultes ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Reception_label1&quot;])',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*10\\b)',
  'COUNT(*) == 1 AND CELL(0, 0) &gt; 1000', 'result_kind == scalar; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'How many films are considered cult films?') AS guard);

-- 08. measured 2026-11-28: 3 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which Alfred Hitchcock films were censored?', 'Quels films d''Alfred Hitchcock ont été censurés ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Person_name1&quot;, &quot;Reception_label1&quot;]) AND matches($.Person_name1, /^Alfred Hitchcock$/i)',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*15\\b)',
  'COUNT(*) &gt; 1', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which Alfred Hitchcock films were censored?') AS guard);

-- 09. measured 2026-11-28: 268 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which films broke box office records in the 1990s?', 'Quels films ont battu des records au box-office dans les années 1990 ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Reception_label1&quot;])',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*9\\b)',
  'COUNT(*) &gt; 50', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which films broke box office records in the 1990s?') AS guard);

-- 10. measured 2026-11-28: 89 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which films of the 2010s divided the critics?', 'Quels films des années 2010 ont divisé la critique ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Reception_label1&quot;])',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*6\\b)',
  'COUNT(*) &gt; 20', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which films of the 2010s divided the critics?') AS guard);

-- 11. measured 2026-11-28: 802 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which films were reappraised over time?', 'Quels films ont été réévalués avec le temps ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Reception_label1&quot;])',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*12\\b)',
  'COUNT(*) &gt; 100', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which films were reappraised over time?') AS guard);

-- 12. measured 2026-11-28: 3 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'What was the critical reception of Oppenheimer?', 'Quel a été l''accueil critique d''Oppenheimer ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 0, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Movie_title1&quot;]) AND matches($.Movie_title1, /^Oppenheimer$/i)',
  '(?is)(?=.*\\bT_WC_T2S_MOVIE_RECEPTION(_LABEL)?\\b)',
  'COUNT(*) &gt; 0', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'What was the critical reception of Oppenheimer?') AS guard);

-- 13. measured 2026-11-28: 5 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which Christopher Nolan films were box office hits with positive reviews?', 'Quels films de Christopher Nolan ont été des succès au box-office avec des critiques positives ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Person_name1&quot;, &quot;Reception_label1&quot;, &quot;Reception_label2&quot;]) AND matches($.Person_name1, /^Christopher Nolan$/i)',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*7\\b)',
  'COUNT(*) &gt; 2', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which Christopher Nolan films were box office hits with positive reviews?') AS guard);

-- 14. measured 2026-11-28: 12 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which Martin Scorsese films have a Rotten Tomatoes score of 90% or more?', 'Quels films de Martin Scorsese ont un score Rotten Tomatoes d''au moins 90 % ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Person_name1&quot;]) AND matches($.Person_name1, /^Martin Scorsese$/i)',
  '(?is)(?=.*(RT_SCORE|ROTTEN))',
  'COUNT(*) &gt; 5', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which Martin Scorsese films have a Rotten Tomatoes score of 90% or more?') AS guard);

-- 15. measured 2026-11-28: 1 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'What is the Metacritic score of The Godfather?', 'Quel est le score Metacritic du Parrain ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 0, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Movie_title1&quot;])',
  '(?is)(?=.*(METACRITIC|METASCORE))',
  'COUNT(*) == 1', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'What is the Metacritic score of The Godfather?') AS guard);

-- 16. measured 2026-11-28: 390 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which 2023 films have the best Metacritic score?', 'Quels films de 2023 ont le meilleur score Metacritic ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [])',
  '(?is)(?=.*(METACRITIC|METASCORE))',
  'COUNT(*) &gt; 5', 'representation == ranked-bars'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which 2023 films have the best Metacritic score?') AS guard);

-- 17. measured 2026-11-28: 80 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which critically acclaimed films have an IMDb rating below 6?', 'Quels films acclamés par la critique ont une note IMDb inférieure à 6 ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Reception_label1&quot;])',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*5\\b)(?=.*\\bIMDB_RATING\\b)',
  'COUNT(*) &gt; 20', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which critically acclaimed films have an IMDb rating below 6?') AS guard);

-- 18. measured 2026-11-28: 91 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which films did critics love but audiences dislike?', 'Quels films ont été adorés par la critique mais boudés par le public ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [])',
  '(?is)(?=.*(RT_SCORE|ROTTEN|METACRITIC|METASCORE|ID_RECEPTION_LABEL))(?=.*\\bIMDB_RATING\\b)',
  'COUNT(*) &gt; 10', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which films did critics love but audiences dislike?') AS guard);

-- 19. measured 2026-11-28: 125 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which films got an A+ CinemaScore?', 'Quels films ont obtenu un A+ au CinemaScore ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [])',
  '(?is)(?=.*\\bCINEMASCORE\\s*=\\s*''A\\+'')',
  'COUNT(*) &gt; 50', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which films got an A+ CinemaScore?') AS guard);

-- 20. measured 2026-11-28: 368 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which box office bombs became cult films?', 'Quels échecs au box-office sont devenus des films cultes ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 1, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [&quot;Reception_label1&quot;, &quot;Reception_label2&quot;])',
  '(?is)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*8\\b)(?=.*\\bID_RECEPTION_LABEL\\s*=\\s*10\\b)',
  'COUNT(*) &gt; 100', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'Which box office bombs became cult films?') AS guard);

-- 21. regression guard, no count
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER,
   ASSERTIONS_ENTITY_EXTRACTION, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'What are the best rated films of 2019?', 'Quels sont les films les mieux notés de 2019 ?',
  (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY WHERE DESCRIPTION = 'Movies - Critical Reception Queries'),
  1, 0, 0, 0, CURDATE(), 1, 1,
  'seteq(entity_keys($), [])',
  '(?is)^(?!.*RECEPTION)(?!.*OMDB)(?!.*RT_SCORE)(?!.*METACRITIC)(?=.*\\bIMDB_RATING\\b)',
  'COUNT(*) &gt; 5', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION WHERE QUESTION = 'What are the best rated films of 2019?') AS guard);

SELECT e.ID_T2S_EVALUATION, e.QUESTION, e.QUESTION_FR, e.IS_SAMPLE, e.ASSERTIONS_SQL_QUERY, e.ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION e JOIN T_WC_T2S_EVALUATION_CATEGORY c ON c.ID_T2S_EVALUATION_CATEGORY = e.ID_T2S_EVALUATION_CATEGORY
WHERE c.DESCRIPTION = 'Movies - Critical Reception Queries' ORDER BY e.ID_T2S_EVALUATION;
