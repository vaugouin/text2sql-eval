-- New evaluations for FASTAPI-TEXT2SQL-376, -377 and -378 (phase 2 lot A, closing), 2026-11-11.
--
-- WHAT THIS FILE DOES
-- Adds ten questions with their French twins, ids 2830 to 2839 set explicitly (the range was
-- reserved for this lot; 2823 to 2829 are kept for parallel work):
--   2830-2834  -376: a "when" or "in order" question orders by the release date, never by a rating,
--              and "movies" / "films" next to a collection name queries the film table alone.
--              2834 is the control: a saga named without a type word keeps the UNION with the series.
--   2835       -377: "the Star Wars Skywalker saga films" (no collection carries that name).
--   2836-2839  -378: a per-year trend since a year stops at the current year. 2839 is the
--              counter-example: announced films after 2026 keep the range open.
--
-- ASSERTIONS. The order is read by CELL(0, 0) and CELL(1, 0), the id column being first in every
-- result contract (ID_MOVIE, or ID_CONTENT on a UNION). The film-table scope is an
-- ASSERTIONS_SQL_QUERY regex that refuses UNION and any T_WC_T2S_SERIE table. The current-year cap
-- is an ASSERTIONS_SQL_QUERY regex on `<year column> <= YEAR(CURDATE())` (or `<` or a BETWEEN up to
-- it), not a hard-coded year in the result, so the evaluation does not expire on 1 January. The
-- result_shape (out of score) asserts timeline, sequence-strip or trend-columns.
--
-- BASELINE on Blue 1.1.20 (prompt 9d21aa7), cache off, 2026-11-11, scored offline with the
-- evaluator's own functions: 13 of 20 calls fail, as intended.
--   2830 EN fails (UNION with the series side; FR passes), 2831 EN and FR fail (UNION ordered by
--   rating, Last Crusade second), 2832 EN fails (UNION by rating, Casino Royale first; FR passes),
--   2833 EN fails (UNION; FR passes), 2834 EN and FR pass (control), 2835 EN and FR fail (the
--   collection card, one row), 2836 to 2838 EN and FR fail (no upper bound: 2099, 2027, 2030, 2031),
--   2839 EN and FR pass (counter-example).
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1 on all ten; IS_SHOWCASE = 1 on the six that list film ids.
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/new-evaluations-376-378.sql
-- Commit and push before running. Each INSERT is guarded by NOT EXISTS on its id or its English
-- question, so a re-run inserts nothing. Regex backslashes are doubled (MariaDB literal); `>` is
-- stored as &gt; in query_result. French twins carry their accents: the runner sets utf8mb4.
-- An explicit id above the current maximum moves AUTO_INCREMENT to 2840.

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;


-- 2830 : FASTAPI-TEXT2SQL-376
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2830, 'When were the Harry Potter movies released?', 'Quand sont sortis les films Harry Potter ?', 47, 1, 1, 1, 0, CURDATE(), 1, 1,
       'COUNT(*) == 8 AND CELL(0, 0) == 671 AND ID_MOVIE IN (671, 672, 673, 674, 675, 767, 12444, 12445)',
       '(?is)^(?!.*\\bUNION\\b)(?!.*T_WC_T2S_SERIE).*\\bT_WC_T2S_MOVIE\\b',
       'representation == timeline; intent.task == value',
       'FASTAPI-TEXT2SQL-376. The question says movies: films alone (no UNION with the series of the collection), in release order (Philosopher''s Stone first), never by rating.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2830 OR QUESTION = 'When were the Harry Potter movies released?') AS guard);

-- 2831 : FASTAPI-TEXT2SQL-376
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2831, 'The Indiana Jones saga in order', 'La saga Indiana Jones dans l''ordre', 47, 1, 1, 1, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 5 AND CELL(0, 0) == 85 AND CELL(1, 0) == 87 AND ID_MOVIE IN (85, 87, 89, 217, 335977)',
       NULL,
       'representation == sequence-strip; intent.task == sequence',
       'FASTAPI-TEXT2SQL-376. No type word, so the UNION of the collection is allowed, but in order means by date (DAT_FIRST_AIR on a UNION): Raiders first, Temple of Doom second. Ordered by rating, Last Crusade comes second.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2831 OR QUESTION = 'The Indiana Jones saga in order') AS guard);

-- 2832 : FASTAPI-TEXT2SQL-376
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2832, 'When were the James Bond films released?', 'Quand les films James Bond sont-ils sortis ?', 47, 1, 1, 1, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 25 AND CELL(0, 0) == 646 AND ID_MOVIE IN (646, 657, 658, 36557, 370172)',
       '(?is)^(?!.*\\bUNION\\b)(?!.*T_WC_T2S_SERIE).*\\bT_WC_T2S_MOVIE\\b',
       'representation == timeline; intent.task == value',
       'FASTAPI-TEXT2SQL-376. Films alone, in release order (Dr. No first), never a UNION ordered by rating (Casino Royale first).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2832 OR QUESTION = 'When were the James Bond films released?') AS guard);

-- 2833 : FASTAPI-TEXT2SQL-376
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2833, 'In which years did the Toy Story movies come out?', 'En quelles années sont sortis les films Toy Story ?', 47, 1, 1, 1, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 4 AND CELL(0, 0) == 862 AND ID_MOVIE IN (862, 863, 10193, 301528)',
       '(?is)^(?!.*\\bUNION\\b)(?!.*T_WC_T2S_SERIE).*\\bT_WC_T2S_MOVIE\\b',
       'representation == timeline; intent.task == value',
       'FASTAPI-TEXT2SQL-376. The question says movies: films alone, no UNION with the series side of the collection, in release order.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2833 OR QUESTION = 'In which years did the Toy Story movies come out?') AS guard);

-- 2834 : FASTAPI-TEXT2SQL-376, control
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2834, 'The Star Wars saga in release order', 'La saga Star Wars dans l''ordre de sortie', 47, 1, 1, 1, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 20 AND CELL(0, 0) == 11 AND ID_MOVIE IN (11, 181812) AND ID_SERIE IN (4194, 82856)',
       NULL,
       'representation == sequence-strip; intent.task == sequence',
       'FASTAPI-TEXT2SQL-376, control. A saga named without a type word keeps the films AND the series of the collection (UNION), ordered by DAT_FIRST_AIR; the movies-only rule must not spread to it.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2834 OR QUESTION = 'The Star Wars saga in release order') AS guard);

-- 2835 : FASTAPI-TEXT2SQL-377
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2835, 'When were the Star Wars Skywalker saga films released?', 'Quand sont sortis les films de la saga Skywalker de Star Wars ?', 47, 1, 1, 1, 0, CURDATE(), 1, 1,
       'CELL(0, 0) == 11 AND ID_MOVIE IN (11, 1891, 1892, 1893, 1894, 1895, 140607, 181808, 181812)',
       '(?is)^(?!.*\\bUNION\\b)(?!.*T_WC_T2S_SERIE).*\\bT_WC_T2S_MOVIE\\b',
       'representation == timeline; intent.task == value',
       'FASTAPI-TEXT2SQL-377. No collection carries the Skywalker saga: the name falls back to the Star Wars collection and the complex retry must keep the question (the films and their dates), not return the bare collection card. Rogue One and Solo may come with it.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2835 OR QUESTION = 'When were the Star Wars Skywalker saga films released?') AS guard);

-- 2836 : FASTAPI-TEXT2SQL-378
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2836, 'How many films were released each year since 2010?', 'Combien de films sont sortis chaque année depuis 2010 ?', 10, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 16 AND RELEASE_YEAR &gt;= 2010',
       '(?is)\\bRELEASE_YEAR\\s*(?:<=|<|BETWEEN\\s+\\S+\\s+AND)\\s*YEAR\\s*\\(\\s*(?:CURDATE|CURRENT_DATE|NOW)',
       'representation == trend-columns; intent.task == trend',
       'FASTAPI-TEXT2SQL-378. A per-year trend since a year stops at the current year (RELEASE_YEAR <= YEAR(CURDATE())): announced films (2027 on) and placeholder years (2099) are not years of the trend.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2836 OR QUESTION = 'How many films were released each year since 2010?') AS guard);

-- 2837 : FASTAPI-TEXT2SQL-378, series side
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2837, 'How many TV series started each year since 2015?', 'Combien de séries ont commencé chaque année depuis 2015 ?', 39, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 11 AND FIRST_AIR_YEAR &gt;= 2015',
       '(?is)\\bFIRST_AIR_YEAR\\s*(?:<=|<|BETWEEN\\s+\\S+\\s+AND)\\s*YEAR\\s*\\(\\s*(?:CURDATE|CURRENT_DATE|NOW)',
       'representation == trend-columns; intent.task == trend',
       'FASTAPI-TEXT2SQL-378, series side. The trend stops at the current year (FIRST_AIR_YEAR <= YEAR(CURDATE())): announced series dated up to 2030 are left out.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2837 OR QUESTION = 'How many TV series started each year since 2015?') AS guard);

-- 2838 : FASTAPI-TEXT2SQL-378 with a genre filter
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2838, 'How many science fiction films were released per year since 2000?', 'Combien de films de science-fiction sont sortis par an depuis 2000 ?', 55, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 25 AND RELEASE_YEAR &gt;= 2000',
       '(?is)\\bRELEASE_YEAR\\s*(?:<=|<|BETWEEN\\s+\\S+\\s+AND)\\s*YEAR\\s*\\(\\s*(?:CURDATE|CURRENT_DATE|NOW)',
       'representation == trend-columns; intent.task == trend',
       'FASTAPI-TEXT2SQL-378 with a genre filter. The trend stops at the current year whatever other filter the question adds.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2838 OR QUESTION = 'How many science fiction films were released per year since 2000?') AS guard);

-- 2839 : FASTAPI-TEXT2SQL-378, counter-example
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2839, 'How many films are announced for release each year after 2026?', 'Combien de films sont annoncés pour chaque année de sortie après 2026 ?', 10, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 2 AND RELEASE_YEAR IN (2027, 2028) AND RELEASE_YEAR &gt;= 2027',
       NULL,
       'representation == trend-columns; intent.task == trend',
       'FASTAPI-TEXT2SQL-378, counter-example. The question asks for announced films after a past year: the range stays open, the current-year cap must not apply.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2839 OR QUESTION = 'How many films are announced for release each year after 2026?') AS guard);

-- Read-back: the ten rows as stored.
SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY, ASSERTIONS_RESULT_SHAPE
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION BETWEEN 2830 AND 2839
ORDER BY ID_T2S_EVALUATION;
