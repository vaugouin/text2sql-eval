-- Defect-closing evaluation for the series side of FASTAPI-TEXT2SQL-355: the Heroes tagline riddle
-- (Guess before my AI, GUESS-192, episode 53). Approved by Philippe 2026-11-11.
--
-- THE DEFECT. `"Save the cheerleader, save the world." Name the series.` On the 2026-10-31 app takes
-- (before -355) the complex model rewrote the riddle to `Serie Heroes (2006)` and the list showed
-- TWO rows: Heroes (NBC, 2006, TMDb 1639, tt0813715) and the Chilean Heroes (2007, TMDb 5365,
-- tt1042704), the lookup reading the year within one either way.
-- Since -355 (live on Blue 1.1.20 since 2026-11-05), the identity check picks Heroes on its
-- `known_credits`: API call of 2026-11-11, 1.1.20, cache on and cache off, both `picked`, one row,
-- ID_SERIE 1639, tt0813715, scores 1639 = 7 (Tim Kring, Panettiere, Ventimiglia, Masi Oka, original
-- title, language) and 5365 = 1 (original title), answer "Here is the TV series Heroes (2006),
-- created by Tim Kring.". Same day, app takes 4 to 6 by voice: one card. The evaluation guards
-- against a regression; the bank had no question on this riddle.
--
-- WHAT. One question, category 62 (TV Series - Descriptive Queries), with its French twin, in the
-- form of 2630 (the Taxi Driver tagline, GUESS-277): the quoted tagline, then "Name the series.".
--
-- THE ASSERTIONS. `COUNT(*) == 1 AND ID_SERIE IN (1639)`: the defect returns the right row PLUS
-- the namesake, so only the count catches it. ASSERTIONS_RESULT_SHAPE carries the -368 clause that
-- 2630 to 2642 carry (out of score): no IMDb id and no generic "matching identifier" line in the
-- answer. The regex has no backslash on purpose: a MariaDB string literal would eat it.
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1, IS_SHOWCASE = 1 (one series id, it has a poster).
-- No ASSERTION_REFRESH_SQL (fixed identity). The id comes from AUTO_INCREMENT (no reserved range).
-- RE-RUN GUARD: INSERT ... SELECT ... WHERE NOT EXISTS on the English question.
-- The first SELECT checks both Heroes rows in the base before the insert.
--
-- ROUTING: one INSERT on T_WC_T2S_EVALUATION, no DDL: voie 1. Commit and push before running.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-355-heroes.sql

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT ID_SERIE, SERIE_TITLE, DAT_FIRST_AIR, ID_IMDB, IMDB_VOTES
FROM T_WC_T2S_SERIE
WHERE ID_SERIE IN (1639, 5365) OR ID_IMDB IN ('tt0813715', 'tt1042704')
ORDER BY ID_SERIE;

SELECT ID_T2S_EVALUATION, LEFT(QUESTION, 70) AS QUESTION FROM T_WC_T2S_EVALUATION
WHERE QUESTION LIKE '%cheerleader%' OR LONG_DESC LIKE '%GUESS-192%';

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT '"Save the cheerleader, save the world." Name the series.',
       '« Sauvez la pom-pom girl, sauvez le monde. » Quelle est cette série ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (1639)',
       'answer !~ (tt|nm)[0-9]{7}|matching identifier|identifiant',
       'Tagline of Heroes (NBC, Tim Kring, TMDb 1639, tt0813715). The complex retry looks up "Serie Heroes (2006)" and, read at year +/- 1, also finds the Chilean Heroes (TMDb 5365, tt1042704, 2007): two rows on the 2026-10-31 app takes, one since the -355 identity check. GUESS-192, Short episode 53. FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = '"Save the cheerleader, save the world." Name the series.') AS existing);

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE,
       QUESTION, QUESTION_FR, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE
FROM T_WC_T2S_EVALUATION
WHERE LONG_DESC LIKE '%GUESS-192%'
ORDER BY ID_T2S_EVALUATION;
