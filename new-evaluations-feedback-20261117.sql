-- Defect-closing evaluations for user feedback #16 and #17 (2026-11-16, t2s-front, API 1.1.20):
-- "what share" asked as a pie returns a film list, and two shares the client cannot draw.
--
-- THE DEFECTS (replayed on Blue 1.1.20 on 2026-11-17, retrieve_from_cache off, models of the
-- original requests; ground truth fastapi-text2sql/maintenance/feedback-016-017-pie-ground-truth.sql).
-- 1. A pie named in the question ("représente par un camembert", "Show it as a pie chart") makes
--    the SQL list the films, one row each with a CASE category column (TECHNICAL_CATEGORY,
--    FORMAT_GROUP, COUNTRY_CATEGORY) or a share repeated per row (FRENCH_WIN_PERCENT): 40 to 50
--    rows, card-grid or value-cards, no summary_facts.share. Three phrasings out of three, EN and
--    FR. The same Hitchcock question without the pie gives one row, MOVIE_SHARE 0.76, share-bar.
--    Truth: Hitchcock directed 61 films, 44 in black and white (0.72); Palme d'Or 84 films,
--    40 with a French production country.
-- 2. "Quelle part des Palmes d'or ... films français ?" without the pie: one row of the award
--    (fact-card) with FRENCH_FILM_WIN_SHARE among the award columns; an entity row is never read
--    as a single share.
-- 3. "Graph with the proportion of male/female actors in the Barbie movie": the SQL is right
--    (GENDER, ACTOR_COUNT, PERCENTAGE, 2 rows) but a table is drawn; result_shape._share()
--    demands exactly one metric and the PERCENTAGE column is a second one.
--
-- THE ASSERTIONS. query_result `COUNT(*) <= 3 AND COUNT(*) >= 1`: a share is one row (the ratio)
-- or two or three (the parts), never the film list (fails today on 1 and passes on 2 and 3, which
-- are presentation defects). ASSERTIONS_RESULT_SHAPE `representation == share-bar` (out of score,
-- fails today on all four). The pie form itself (summary_facts.share.shape) has no clause in the
-- shape grammar; the shape is set by result_intent._PIE_RE and is already right whenever a share
-- is built (2884). Stored with plain `<=` / `>=` (no &lt; form in the bank).
--
-- WHAT. Four questions, EN and FR in the same row, category 6 as 2880 to 2889 (share-bar).
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1, IS_SHOWCASE = 0.
-- RE-RUN GUARD: INSERT ... SELECT ... WHERE NOT EXISTS on the English question.
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only: voie 1. Commit and push before running.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-feedback-20261117.sql

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 1. Feedback #16
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, TIM_UPDATED, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 'What share of Hitchcock''s films are in black and white? Show it as a pie chart',
       'Quelle part des films de Hitchcock est en noir et blanc ? représente par un camembert',
       6, 1, 1, 0, 0, CURDATE(), NOW(), 1, 1,
       'COUNT(*) <= 3 AND COUNT(*) >= 1',
       'representation == share-bar',
       'User feedback #16 (2026-11-16, t2s-front, "I expected a pie chart"). A pie named in the question turned the share into the list of his films with a per-row black-and-white flag (50 rows, card-grid, Blue 1.1.20); without the pie the same question gives one row, 0.76. Truth: 44 of the 61 films he directed (0.72). FASTAPI-TEXT2SQL-411.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'What share of Hitchcock''s films are in black and white? Show it as a pie chart') AS guard);

-- 2. Feedback #17
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, TIM_UPDATED, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 'What share of the Palme d''Or winners are French films? Show it as a pie chart',
       'Quelle part des Palmes d''or a été remportée par des films français ? représente par un camembert',
       6, 1, 1, 0, 0, CURDATE(), NOW(), 1, 1,
       'COUNT(*) <= 3 AND COUNT(*) >= 1',
       'representation == share-bar',
       'User feedback #17 (2026-11-16, t2s-front, "Not a pie chart"). The SQL listed the winners, one row each with a French / other category or a share repeated per row (40 to 50 rows, ranked-bars, value-cards or card-grid, Blue 1.1.20). Truth: Palme d''Or (award 9539), 84 films, 40 with a French production country. FASTAPI-TEXT2SQL-411.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'What share of the Palme d''Or winners are French films? Show it as a pie chart') AS guard);

-- 3. The same share without the pie: an entity row carrying the share
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, TIM_UPDATED, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 'What share of the Palme d''Or winners are French films?',
       'Quelle part des Palmes d''or a été remportée par des films français ?',
       6, 1, 1, 0, 0, CURDATE(), NOW(), 1, 1,
       'COUNT(*) <= 3 AND COUNT(*) >= 1',
       'representation == share-bar',
       'Found replaying feedback #17 (2026-11-17, Blue 1.1.20): without the pie the French question returns the award row (fact-card) with FRENCH_FILM_WIN_SHARE among its columns, so no share is built. Truth: 40 of 84 films. FASTAPI-TEXT2SQL-411.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'What share of the Palme d''Or winners are French films?') AS guard);

-- 4. A count and a percentage side by side
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, TIM_UPDATED, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 'Graph with the proportion of male/female actors in the Barbie movie',
       'Graphique avec la proportion d''acteurs hommes et femmes dans le film Barbie',
       6, 1, 1, 0, 0, CURDATE(), NOW(), 1, 1,
       'COUNT(*) <= 3 AND COUNT(*) >= 1',
       'representation == share-bar',
       'Found in the logs of 2026-11-12 and replayed on 2026-11-17 (Blue 1.1.20): the SQL is right (GENDER, ACTOR_COUNT, PERCENTAGE, 2 rows) but a table is drawn, because the share needs exactly one metric and PERCENTAGE is a second one. Truth: 31 women, 33 men. FASTAPI-TEXT2SQL-411.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Graph with the proportion of male/female actors in the Barbie movie') AS guard);

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, QUESTION, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE
FROM T_WC_T2S_EVALUATION
WHERE LONG_DESC LIKE '%FASTAPI-TEXT2SQL-411%'
ORDER BY ID_T2S_EVALUATION;
