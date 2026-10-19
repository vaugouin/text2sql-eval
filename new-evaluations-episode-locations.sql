-- New evaluations closing EVALUATIONS-025: the episode locations (T_WC_T2S_EPISODE_LOCATION).
--
-- Written 2026-10-19. 4 evaluations, English and French, category 36 (TV series, geography
-- and language). Voie 1: four INSERT on T_WC_T2S_EVALUATION, nothing else.
--
-- WHY THIS FILE EXISTS
-- Since the night of 2026-10-18, T_WC_T2S_EPISODE_LOCATION links single episodes to places
-- (TMDB-MOVIE-PREPROCESS-062), and the API reads it since FASTAPI-TEXT2SQL-334 (1.1.19). Of
-- the 1 532 questions of the bank, eight read the movie or series location tables and none
-- reads the episode one. A regression there would go unseen.
--
-- THE FACTS ARE READ, NOT REMEMBERED
-- harvest-episode-locations-20261019.txt, same day:
--   * Arlington National Cemetery (Q216344, ID_LOCATION 12674) and Air Force One (Q179969,
--     12647) have MOVIE_COUNT = 0 and SERIE_COUNT = 0: they exist in the base only through
--     episodes. Before 2026-10-18 both questions below had no possible answer.
--   * Arlington, filming: The West Wing (688) only, S1E10 In Excelsis Deo and S3E20 We Killed
--     Yamamoto. Arlington, narrative: The West Wing, The X-Files (4087, S11E2 This) and For
--     All Mankind (87917, S2E10 The Grey).
--   * Air Force One, narrative: The West Wing, 11 episodes.
--   * Lian Yu (Q25395444, fiction), episode-only too: Arrow (1412) and The Flash (60735).
--   * London (Q84, the only living "London"): series set there at series level start with
--     Sherlock (19885), Peaky Blinders (60574), Fleabag (67070). Black Mirror (42009),
--     The Simpsons (456), Parks and Recreation (8592) and Killing Eve (72750) reach London
--     ONLY through an episode (Smithereens, The Regina Monologues, "London", the first season).
--
-- THE QUESTIONS WERE RUN BEFORE BEING WRITTEN
-- Green, 1.1.19, 2026-10-19, after TMDB-MOVIE-PREPROCESS-048's first run; all eight forms
-- (four questions, EN and FR) return the expected series. The three episode questions go
-- T_WC_T2S_EPISODE_LOCATION -> T_WC_T2S_EPISODE -> T_WC_T2S_SERIE with the right role; the
-- London question stays on T_WC_T2S_SERIE_LOCATION, and its 100 rows end at a weighted
-- rating of 7.08, below every counter-example (Killing Eve, the lowest, is 7.88): their
-- absence is a decision of the query, not an effect of the LIMIT.
--
-- WHAT THE ASSERTIONS PROTECT
--   SQL regex     the episode questions must read T_WC_T2S_EPISODE_LOCATION with the role
--                 of the question; the London question must NOT read it.
--   ID_SERIE IN   the anchor, on TMDb ids that do not drift.
--   NOT IN        the counter-example where one exists: X-Files and For All Mankind are set
--                 at Arlington but were not filmed there (a query that drops the role keeps
--                 them); the four series that reach London only through an episode (a query
--                 that unions the episode table into "series set in London" brings them in).
--
-- NO ASSERTION_REFRESH_SQL, ON PURPOSE
-- Process 70 would rewrite ASSERTIONS_QUERY_RESULT from it and drop the NOT IN, which is the
-- point of two of the four. The anchors are fixed identities, not a moving top-8.
--
-- ASSERTIONS_ENTITY_EXTRACTION IS LEFT NULL
-- Each form was run once; the house method for an extraction assertion is three passes per
-- language. The English Arlington form came back from the cache with no extraction at all.
--
-- ESCAPING
-- Quotes inside the regexes are stored as &#039; and &quot;, as in 2435; the evaluator
-- unescapes first. Backslashes are doubled for MariaDB (\\s is stored as \s).
--
-- RE-RUN GUARD
-- Each INSERT ... SELECT is guarded by NOT EXISTS on the English question, in a derived
-- table (MySQL error 1093). Re-running the file is a no-op.
--
-- AFTER: phase 31 to refresh the JSON export, then phases 11 + 20 to run and score them.
--
-- APPLIED 2026-10-19 20:42 on vaugouindb (voie 1), result in
-- new-evaluations-episode-locations-20261019.txt: ids 2540 (Arlington), 2541 (Air Force One),
-- 2542 (Lian Yu), 2543 (London); regexes stored with single backslashes. The eight forms were
-- then scored against Green 1.1.19 with this repository's own assertion functions
-- (re.search on the unescaped regex, evaluate_dataframe_assertions): 8 of 8 pass.


SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 0. Pre-flight. The ids asserted below, with their titles. Then the four questions:
--    zero rows before the INSERTs, four after.
-- ---------------------------------------------------------------------------
SELECT '0. Asserted series' AS SECTION;

SELECT s.ID_SERIE, s.SERIE_TITLE, s.DELETED
FROM T_WC_T2S_SERIE s
WHERE s.ID_SERIE IN (688, 4087, 87917, 1412, 60735, 19885, 60574, 67070, 42009, 456, 8592, 72750)
ORDER BY s.ID_SERIE;

SELECT '0b. Before' AS SECTION;

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, LEFT(QUESTION, 80) AS QUESTION
FROM T_WC_T2S_EVALUATION
WHERE QUESTION IN (
  'Which TV series have an episode filmed at Arlington National Cemetery?',
  'Which TV series have an episode set aboard Air Force One?',
  'Which TV series have episodes set on Lian Yu?',
  'TV shows set in London'
);


-- ---------------------------------------------------------------------------
-- 1. The new evaluations, category 36: TV series, geography and language.
-- ---------------------------------------------------------------------------

-- 1. A filming place reached only through episodes, with a role trap.
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which TV series have an episode filmed at Arlington National Cemetery?',
       'Quelles séries ont un épisode tourné au cimetière national d''Arlington ?',
       1, 0, 36, 0, CURDATE(), NOW(),
       '(?is)T_WC_T2S_EPISODE_LOCATION.*LOCATION_ROLE\\s*=\\s*[&#039;&quot;]filming[&#039;&quot;]',
       'ID_SERIE IN (688) AND ID_SERIE NOT IN (4087, 87917)',
       'EVALUATIONS-025. Arlington National Cemetery has no movie and no series link: only episodes carry it (T_WC_T2S_EPISODE_LOCATION, since 2026-10-18). Filming: The West Wing alone (In Excelsis Deo, We Killed Yamamoto). The X-Files and For All Mankind have an episode SET there, not filmed there: a query that drops the role brings them back and fails the NOT IN.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Which TV series have an episode filmed at Arlington National Cemetery?') AS existing);

-- 2. A narrative place the series itself does not carry.
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which TV series have an episode set aboard Air Force One?',
       'Quelles séries ont un épisode qui se déroule à bord d''Air Force One ?',
       1, 0, 36, 0, CURDATE(), NOW(),
       '(?is)T_WC_T2S_EPISODE_LOCATION.*LOCATION_ROLE\\s*=\\s*[&#039;&quot;]narrative[&#039;&quot;]',
       'ID_SERIE IN (688)',
       'EVALUATIONS-025. Air Force One is linked to 11 episodes of The West Wing and to no series or movie: the series-level table returns nothing, only T_WC_T2S_EPISODE_LOCATION answers.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Which TV series have an episode set aboard Air Force One?') AS existing);

-- 3. A fictional place cited by episodes only, across two series.
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which TV series have episodes set on Lian Yu?',
       'Quelles séries ont des épisodes qui se passent sur Lian Yu ?',
       1, 0, 36, 0, CURDATE(), NOW(),
       '(?is)T_WC_T2S_EPISODE_LOCATION.*LOCATION_ROLE\\s*=\\s*[&#039;&quot;]narrative[&#039;&quot;]',
       'ID_SERIE IN (1412, 60735)',
       'EVALUATIONS-025. Lian Yu, the island of Arrow, is a fictional place (LOCATION_TYPE fiction) linked to 66 episodes and to no series or movie. Both series must come back, Arrow and The Flash, and only through the episode table.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Which TV series have episodes set on Lian Yu?') AS existing);

-- 4. The trap: a series-level question the episode table must not divert.
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'TV shows set in London',
       'Séries qui se passent à Londres',
       1, 0, 36, 0, CURDATE(), NOW(),
       '(?is)^(?!.*T_WC_T2S_EPISODE_LOCATION).*T_WC_T2S_SERIE_LOCATION',
       'ID_SERIE IN (19885, 60574, 67070) AND ID_SERIE NOT IN (42009, 456, 8592, 72750)',
       'EVALUATIONS-025, the trap. "Series set in X" stays on T_WC_T2S_SERIE_LOCATION (FASTAPI-TEXT2SQL-334). Black Mirror, The Simpsons, Parks and Recreation and Killing Eve reach London only through an episode; all four rate above the 100th row of the correct answer (7.08 on 2026-10-19), so a query that adds the episode table brings them in and fails the NOT IN. Sample 2435 asks the same at series level with a refresh SQL; this one keeps fixed anchors so that the counter-example survives process 70.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'TV shows set in London') AS existing);


-- ---------------------------------------------------------------------------
-- 2. After. Four rows, with their stored assertions (check the backslashes survived).
-- ---------------------------------------------------------------------------
SELECT '2. After' AS SECTION;

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE,
       LEFT(QUESTION, 60) AS QUESTION, LEFT(QUESTION_FR, 60) AS QUESTION_FR,
       ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION
WHERE QUESTION IN (
  'Which TV series have an episode filmed at Arlington National Cemetery?',
  'Which TV series have an episode set aboard Air Force One?',
  'Which TV series have episodes set on Lian Yu?',
  'TV shows set in London'
);
