-- New evaluations for FASTAPI-TEXT2SQL-345 and -346: a criterion the database stores (a
-- country, a genre) PLUS a description it does not store (a setting, themes) must return rows,
-- never the error "Complex entity resolution is required before SQL generation".
--
-- Written 2026-10-28. 2 evaluations, English and French, category 12 (movies, complex queries).
-- Voie 1: two INSERT on T_WC_T2S_EVALUATION, nothing else. Ids are AUTO_INCREMENT, never
-- hand-picked.
--
-- WHY THIS FILE EXISTS
-- On 2026-10-28 at 09:57 (tmdb-front, API 1.1.19, gpt-6-sol on all three stages), "Hong Kong
-- horror films in which high-density housing is a spooky backdrop for exploring superstitions
-- and socioeconomic anxieties." returned no row and the error above. Log:
-- shared_data/fastapi-text2sql/logs/20261028-095735_text2sql_post_1.1.19_90c31318...json.
-- Text2SQL requested complex resolution (the themes identify no title); the complex model
-- answered the opposite (a criterion, not a description), rewrote the question without a title;
-- the retry pass handed it back to Text2SQL, which refused again. Two models bouncing the
-- question, four strong-model calls, zero rows.
--   * -346 (prompt): the complex model now lists candidate works for criterion + description.
--   * -345 (code): if Text2SQL still refuses after the complex model ran, it is asked once for
--     the closest filter (country, genre), the themes declared in dropped_clause.
--
-- THE THREE ORDERED QUESTIONS, ASKED BEFORE WRITING THIS FILE
--   * Does a question of the bank cover the case? No: no fiche contains "Hong Kong",
--     "superstition" or "semi-basement" in the export of 2026-10-28.
--   * Does it carry an assertion? Not applicable, there is no question.
--   * Would an existing assertion have caught THIS defect? No: no evaluation pairs a stored
--     criterion with an unstored description.
--
-- WHAT THE ASSERTIONS PROTECT, AND WHY THEY STAY LOOSE
-- Either fix can answer, and they answer differently: -346 returns a list of titles (the SQL
-- is an ID/title lookup, no country filter), -345 returns the country + genre filter (no title
-- chosen). So:
--   * NO ASSERTIONS_SQL_QUERY. A regex on a country filter would fail the -346 path, which is
--     the better answer; a regex on a title list would fail the -345 path.
--   * Question 1 asserts the floor only, COUNT(*) > 0: the defect was zero rows. Naming a title
--     would assert what the complex model remembers, not what was missing.
--   * Question 2 adds one anchor that both paths reach: Parasite (2019), ID_MOVIE 496243 (TMDb
--     id, stable), checked in section 0. -346 names it; -345 filters Korean thrillers, where
--     it ranks near the top by popularity. If section 0 shows a different id or genre set,
--     drop the anchor and keep the floor rather than assert a guess.
-- RESOLUTION_MODE 'any': either path is a right answer, so the escalation verdict stays NULL.
-- ASSERTIONS_ENTITY_EXTRACTION is left NULL: the house method is three passes per language,
-- not run here.
--
-- WHAT IS DELIBERATELY NOT COVERED
-- The other half of -345, "a pure riddle with no applicable criterion keeps its refusal, never
-- a catalogue dump", has no stable question: on such a riddle the complex model usually names
-- the work, so the -345 branch is not reached. It is checked by reading
-- best_effort_filter_outcome in the logs, not by an evaluation.
--
-- RE-RUN GUARD: each INSERT ... SELECT is guarded by NOT EXISTS on the English question, in a
-- derived table (MySQL error 1093). Re-running the file is a no-op.
--
-- AFTER: phase 31 to refresh the JSON export, then phases 11 + 20 to run and score them,
-- against an API that carries -345 and -346.


SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 0. Pre-flight. The anchor must exist and be a Korean production; the HK horror floor must
--    be reachable by the -345 filter alone (a non-zero count). Then the two questions: zero
--    rows before the INSERTs, two after.
-- ---------------------------------------------------------------------------
SELECT '0a. Anchor: Parasite (2019), must be one row, KR among its countries' AS SECTION;

SELECT m.ID_MOVIE, m.MOVIE_TITLE, m.RELEASE_YEAR, m.DELETED,
       (SELECT GROUP_CONCAT(pc.COUNTRY_CODE) FROM T_WC_T2S_MOVIE_PRODUCTION_COUNTRY pc
         WHERE pc.ID_MOVIE = m.ID_MOVIE) AS COUNTRIES,
       (SELECT GROUP_CONCAT(g.ID_GENRE) FROM T_WC_T2S_MOVIE_GENRE g
         WHERE g.ID_MOVIE = m.ID_MOVIE) AS GENRES
FROM T_WC_T2S_MOVIE m
WHERE m.ID_MOVIE = 496243;

SELECT '0b. Hong Kong horror films the -345 filter can reach (genre 27), must be > 0' AS SECTION;

SELECT COUNT(DISTINCT pc.ID_MOVIE) AS HK_HORROR_MOVIES
FROM T_WC_T2S_MOVIE_PRODUCTION_COUNTRY pc
JOIN T_WC_T2S_MOVIE_GENRE g ON g.ID_MOVIE = pc.ID_MOVIE AND g.ID_GENRE = 27
WHERE pc.COUNTRY_CODE = 'HK';

SELECT '0c. Dream Home (2010), the title a connoisseur names for question 1 (informative)' AS SECTION;

SELECT m.ID_MOVIE, m.MOVIE_TITLE, m.RELEASE_YEAR
FROM T_WC_T2S_MOVIE m
WHERE m.MOVIE_TITLE = 'Dream Home' AND m.RELEASE_YEAR = 2010;

SELECT '0d. Before' AS SECTION;

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, LEFT(QUESTION, 60) AS QUESTION
FROM T_WC_T2S_EVALUATION
WHERE QUESTION IN (
  'Hong Kong horror films in which high-density housing is a spooky backdrop for exploring superstitions and socioeconomic anxieties.',
  'Korean thrillers in which a semi-basement apartment exposes the divide between rich and poor.'
);


-- ---------------------------------------------------------------------------
-- 1. The new evaluations, category 12: movies, complex queries.
-- ---------------------------------------------------------------------------

-- 1. FASTAPI-TEXT2SQL-345 / -346: the question of 2026-10-28, word for word.
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, RESOLUTION_MODE, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Hong Kong horror films in which high-density housing is a spooky backdrop for exploring superstitions and socioeconomic anxieties.',
       'Films d''horreur hongkongais où l''habitat surpeuplé sert de décor inquiétant pour explorer les superstitions et les angoisses socio-économiques.',
       1, 0, 12, 0, CURDATE(), NOW(), 'any',
       'COUNT(*) &gt; 0',
       'FASTAPI-TEXT2SQL-345 / -346. A stored criterion (Hong Kong, horror) plus an unstored description (setting, themes). On 2026-10-28 Text2SQL and the complex model bounced it and it ended on "Complex entity resolution is required before SQL generation", zero rows. Either fix is right: candidate titles from the complex model (-346), or the country + genre filter with the themes in dropped_clause (-345). The floor asserts what was missing: rows.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Hong Kong horror films in which high-density housing is a spooky backdrop for exploring superstitions and socioeconomic anxieties.') AS existing);

-- 2. Same shape, another country and genre, with one anchor both paths reach.
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, RESOLUTION_MODE, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Korean thrillers in which a semi-basement apartment exposes the divide between rich and poor.',
       'Thrillers coréens où un appartement en semi-sous-sol révèle le fossé entre riches et pauvres.',
       1, 0, 12, 0, CURDATE(), NOW(), 'any',
       'COUNT(*) &gt; 0 AND ID_MOVIE IN (496243)',
       'FASTAPI-TEXT2SQL-345 / -346, second instance of the criterion + description shape (Korean, thriller, plus a setting and a theme the database does not store). Parasite (2019, ID_MOVIE 496243, TMDb id) is the anchor: the complex model names it (-346), and the Korean-thriller filter (-345) returns it near the top by popularity.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Korean thrillers in which a semi-basement apartment exposes the divide between rich and poor.') AS existing);


-- ---------------------------------------------------------------------------
-- 2. After. Two rows, with their stored assertions.
-- ---------------------------------------------------------------------------
SELECT '2. After' AS SECTION;

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, RESOLUTION_MODE,
       LEFT(QUESTION, 40) AS QUESTION, LEFT(QUESTION_FR, 40) AS QUESTION_FR,
       ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION
WHERE QUESTION IN (
  'Hong Kong horror films in which high-density housing is a spooky backdrop for exploring superstitions and socioeconomic anxieties.',
  'Korean thrillers in which a semi-basement apartment exposes the divide between rich and poor.'
);
