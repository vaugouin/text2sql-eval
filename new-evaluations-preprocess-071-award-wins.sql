-- New evaluations for TMDB-MOVIE-PREPROCESS-071: award wins one row per win, with the year and
-- the work rewarded. Written on 2026-11-10, before the build (backlog rule: evaluations first,
-- failing today, baseline, implement, rerun).
--
-- THE DEFECT TO MEASURE. T_WC_T2S_PERSON_AWARD, T_WC_T2S_MOVIE_AWARD and T_WC_T2S_SERIE_AWARD
-- hold one row per (award, entity) pair and nothing else: no year, no work. "Who won Best
-- Actress in 1982" has no year to filter on, "for which films" has no film to return, and
-- Katharine Hepburn's four Oscars for Best Actress are one row. After -071 a link row is one win
-- (one P166 statement of Wikidata and one year), with AWARD_YEAR, and on a person's win
-- ID_MOVIE_FOR / ID_SERIE_FOR.
--
-- WHAT THIS FILE DOES. Three questions with their French twins.
--   1. The winner of a category in a given year, on persons (category 49):
--      Academy Award for Best Actress, 1982 -> Katharine Hepburn (6598), one row.
--   2. The films a person won a given award for (category 49):
--      Katharine Hepburn, Academy Award for Best Actress -> Morning Glory (31777), Guess Who's
--      Coming to Dinner (1879), The Lion in Winter (18988), On Golden Pond (11816), four rows.
--   3. The winner of a category in a given year, on movies (category 11):
--      César Award for Best Film, 2010 -> A Prophet (21575), one row. The year asked is the
--      year of the award, not the release year of the film.
-- None of the three needs the award family (each names one category), so they can turn green at
-- the first build. The family side of -071 is measured by two evaluations already in the bank:
-- 2313 (Katharine Hepburn's Academy Awards, 4) and 2349 (Walt Disney's, more than 10), green
-- only once WIKIDATA-CRAWLER-032 has loaded P361 and P527.
--
-- THE YEAR. AWARD_YEAR is the year Wikidata gives the win (qualifier P585), which for the
-- Oscars and the Césars is the year of the ceremony: Hepburn's Oscar for On Golden Pond (a 1981
-- film) is 1982, A Prophet (2009) is César 2010.
--
-- ASSERTIONS. ASSERTIONS_QUERY_RESULT on the ids and the row count. ASSERTIONS_SQL_QUERY is the
-- name of the column the SQL must use (a plain word, no regex operator, no backslash).
-- RESOLUTION_MODE = 'standard': the answer must come from the SQL result, not from the complex
-- model nor from the zero-count fallback.
--
-- IDS: read on 2026-11-10 in tmdb-movie-preprocess/doc/sql/check-071-prebuild-20261110.txt
-- (sections D1 to D3: the person, the four films by their Wikidata ids, the Best Actress
-- winners year by year from 1975 to 1990, the César winners of 2010 and 2012).
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1, IS_SHOWCASE = 1 on 1 and 3 (one person, one film), 0 on 2
-- (a list).
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-preprocess-071-award-wins.sql
--
-- CONVENTIONS (as new-evaluations-373-misattributed-crew-role.sql): auto-increment id; each
-- INSERT is guarded by NOT EXISTS on the English QUESTION; DELETED = 0; DAT_CREAT = CURDATE();
-- owner 1. No backslash anywhere (a MariaDB string literal would eat it).

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, RESOLUTION_MODE, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY)
SELECT 'Who won the Academy Award for Best Actress in 1982?',
       'Qui a remporté l''Oscar de la meilleure actrice en 1982 ?',
       49, 1, 1, 1, 0, CURDATE(), 1, 1, 'standard',
       'COUNT(*) == 1 AND ID_PERSON IN (6598)', 'AWARD_YEAR'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Who won the Academy Award for Best Actress in 1982?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, RESOLUTION_MODE, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY)
SELECT 'For which films did Katharine Hepburn win the Academy Award for Best Actress?',
       'Pour quels films Katharine Hepburn a-t-elle remporté l''Oscar de la meilleure actrice ?',
       49, 1, 1, 0, 0, CURDATE(), 1, 1, 'standard',
       'COUNT(*) == 4 AND ID_MOVIE IN (31777, 1879, 18988, 11816)', 'ID_MOVIE_FOR'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'For which films did Katharine Hepburn win the Academy Award for Best Actress?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, RESOLUTION_MODE, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY)
SELECT 'Which film won the César Award for Best Film in 2010?',
       'Quel film a remporté le César du meilleur film en 2010 ?',
       11, 1, 1, 1, 0, CURDATE(), 1, 1, 'standard',
       'COUNT(*) == 1 AND ID_MOVIE IN (21575)', 'AWARD_YEAR'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which film won the César Award for Best Film in 2010?') AS guard);

-- The new rows.
SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, RESOLUTION_MODE, IS_SAMPLE, IS_SHOWCASE, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY
  FROM T_WC_T2S_EVALUATION
  WHERE QUESTION IN ('Who won the Academy Award for Best Actress in 1982?', 'For which films did Katharine Hepburn win the Academy Award for Best Actress?', 'Which film won the César Award for Best Film in 2010?')
  ORDER BY ID_T2S_EVALUATION;
