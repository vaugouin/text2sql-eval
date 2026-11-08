-- New evaluations for the result representations, phase 1 (TEXT2SQL-EVAL-003).
--
-- NOT YET APPLIED. Generated 2026-10-31 from the list Philippe reviewed the same day
-- (sixty candidates, all accepted; two reworked for lack of data, several reworded after a
-- check against Green, see the comments). Study: Nestor
-- projets/t2s-backlog/result-representations-answer-forms-study.md.
--
-- WHAT THIS FILE DOES
-- Adds ten questions per answer form (value per item, ranking, count, comparison, sequence,
-- trend), English with a French twin, each with the scored query_result assertion and an
-- out-of-score result_shape assertion read by check-result-shape.py.
--
-- EVAL-DRIVEN, ON PURPOSE: a result_shape assertion here states the representation API 1.2.0
-- must emit (FASTAPI-TEXT2SQL-351, -353, -354), so `value-cards` and most `ranked-bars` FAIL on
-- 1.1.19. That is the baseline the campaign measures; the forms C, E and F assert what Green
-- emits today. This departs from the house rule of result-shape-batch-20261030.sql (assert only
-- an observed shape) by Philippe's decision of 2026-10-31 (eval-driven development). The
-- intent.task assertion the ticket mentions waits for the DSL extension of -353.
--
-- EVERY ANSWER WAS CHECKED ON GREEN (1.1.19 + 369eaa3) ON 2026-10-31. Four questions carry an
-- assertion that fails today on purpose, each a real defect:
--   C05  "How many actors have played James Bond?" answers 13 (character name alone), 6 when
--        scoped to the collection.
--   E01  the Marvel Cinematic Universe resolves to every Marvel film, Howard the Duck first.
--   A06  "from oldest to newest" puts three undated, unreleased films first (NULL dates).
--   F06  "per year" opens with a NULL year row.
--   B01  orders by REVENUE without projecting it (unit(REVENUE) fails until the prompt does).
--
-- FLAGS: IS_EVAL = 1 and IS_SAMPLE = 1 on all sixty (tmdb-front samples page). IS_SHOWCASE = 1
-- on the thirty-six whose query_result lists entity ids with an image (the /samples showcase
-- hydrates cards from that list, up to 12 ids, in the listed order); a count, a CELL check or a
-- label ranking cannot be a showcase card. Three rankings whose top moves with the data carry an
-- ASSERTION_REFRESH_SQL (README 4.6), mirroring the evaluated query, LIMIT 8.
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/new-evaluations-20261031.sql
-- Commit and push before running. Then refresh the bank to the PC (phase 31 export + sync).
--
-- CONVENTIONS (as new-evaluations-20261029.sql): auto-increment id; each INSERT guarded by NOT
-- EXISTS on the English QUESTION; DELETED = 0; DAT_CREAT = CURDATE(); owner 1; `>` stored as
-- &gt; in query_result; result_shape uses == only. French twins carry their accents: the runner
-- sets --default-character-set=utf8mb4.


-- ===== Section A : value per item (1.2.0 target: value-cards) ; intent.task = value =====

-- A01 : trilogy, collection order; RUNTIME focus
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The Lord of the Rings films with the runtime of each', 'Les films du Seigneur des anneaux avec la durée de chacun', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (120, 121, 122)', 'representation == value-cards; unit(RUNTIME) == minutes'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The Lord of the Rings films with the runtime of each') AS guard);

-- A02 : 27 rows on Green 2026-10-31; the first twelve in release order anchor the showcase
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The James Bond films with the budget of each, in release order', 'Les films James Bond avec le budget de chacun, par ordre de sortie', 22, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (646, 657, 658, 660, 667, 668, 681, 253, 682, 691, 698, 699)', 'representation == value-cards; unit(BUDGET) == usd'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The James Bond films with the budget of each, in release order') AS guard);

-- A03 : 'earned' maps to REVENUE (verified: REVENUE projected)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The Toy Story movies and how much each one earned at the box office', 'Les films Toy Story et la recette de chacun au box-office', 22, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (862, 863, 10193, 301528, 1084244)', 'representation == value-cards; unit(REVENUE) == usd'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The Toy Story movies and how much each one earned at the box office') AS guard);

-- A04 : reworded: 'Nolan's films' returned 30 rows incl. shorts and producer credits; 14 with 'feature films directed by'
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The feature films directed by Christopher Nolan with their IMDb rating, by release date', 'Les longs métrages réalisés par Christopher Nolan avec leur note IMDb, par date de sortie', 4, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (11660, 77, 320, 272, 1124, 155, 27205, 49026, 157336, 374720, 577922, 872585)', 'representation == value-cards'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The feature films directed by Christopher Nolan with their IMDb rating, by release date') AS guard);

-- A05 : the Alien collection holds the four originals
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The Alien movies with the duration of each', 'Les films Alien avec la durée de chacun', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (348, 679, 8077, 8078)', 'representation == value-cards; unit(RUNTIME) == minutes'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The Alien movies with the duration of each') AS guard);

-- A06 : DEFECT seen 2026-10-31: three undated, unreleased films come first (NULL dates sort first in ASC); Toy Story (862) must open the list
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Pixar feature films with their revenue, from oldest to newest', 'Les longs métrages Pixar avec leur recette, du plus ancien au plus récent', 7, 1, 1, 0, 0, CURDATE(), 1, 1, 'CELL(0, 0) == 862', 'representation == value-cards; unit(REVENUE) == usd'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Pixar feature films with their revenue, from oldest to newest') AS guard);

-- A07 : a named set of series
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Breaking Bad, The Wire, The Sopranos and Mad Men with the number of seasons of each', 'Breaking Bad, The Wire, Les Soprano et Mad Men avec le nombre de saisons de chacune', 6, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_SERIE IN (1396, 1438, 1398, 1104)', 'representation == value-cards; unit(NUMBER_OF_SEASONS) == count'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Breaking Bad, The Wire, The Sopranos and Mad Men with the number of seasons of each') AS guard);

-- A08
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The Back to the Future trilogy with the IMDb rating of each film', 'La trilogie Retour vers le futur avec la note IMDb de chaque film', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (105, 165, 196)', 'representation == value-cards'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The Back to the Future trilogy with the IMDb rating of each film') AS guard);

-- A09 : 13 rows on Green incl. the LEGO special and The Mandalorian and Grogu; the eleven theatrical films anchor it
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The Star Wars movies and the budget of each, in release order', 'Les films Star Wars et le budget de chacun, par ordre de sortie', 22, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (11, 1891, 1892, 1893, 1894, 1895, 140607, 330459, 181808, 348350, 181812)', 'representation == value-cards; unit(BUDGET) == usd'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The Star Wars movies and the budget of each, in release order') AS guard);

-- A10 : reworded: 'Tarantino's movies' returned 50 rows of every credit (Sin City, Baby Driver...)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The films directed by Quentin Tarantino with their runtime', 'Les films réalisés par Quentin Tarantino avec leur durée', 4, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (680, 68718, 16869, 24, 500, 393, 273248, 466272, 184, 1991)', 'representation == value-cards; unit(RUNTIME) == minutes'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The films directed by Quentin Tarantino with their runtime') AS guard);


-- ===== Section B : ranking (1.2.0 target: ranked-bars) ; intent.task = rank =====

-- B01 : Green 2026-10-31 orders by REVENUE but does not project it: unit(REVENUE) fails until the SQL prompt projects the ranking metric (see -351/-354)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, ASSERTION_REFRESH_SQL)
SELECT 'Which 10 Pixar films made the most money?', 'Quels sont les 10 films Pixar qui ont rapporté le plus d''argent ?', 22, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (1022789, 260513, 1084244, 301528, 10193)', 'representation == ranked-bars; unit(REVENUE) == usd', 'SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE FROM T_WC_T2S_MOVIE JOIN T_WC_T2S_MOVIE_COMPANY ON T_WC_T2S_MOVIE_COMPANY.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE JOIN T_WC_T2S_COMPANY ON T_WC_T2S_COMPANY.ID_COMPANY = T_WC_T2S_MOVIE_COMPANY.ID_COMPANY WHERE T_WC_T2S_COMPANY.COMPANY_NAME = ''Pixar'' ORDER BY T_WC_T2S_MOVIE.REVENUE DESC LIMIT 8'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which 10 Pixar films made the most money?') AS guard);

-- B02 : concert films and documentaries included: that is the database's truth
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The five longest films directed by Martin Scorsese', 'Les cinq films les plus longs réalisés par Martin Scorsese', 4, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (75009, 53198, 9459, 398978, 19082)', 'representation == ranked-bars; unit(RUNTIME) == minutes'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The five longest films directed by Martin Scorsese') AS guard);

-- B03 : REVENUE projected on Green 2026-10-31 (Ne Zha 2, Zootopia 2, Inside Out 2...)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, ASSERTION_REFRESH_SQL)
SELECT 'Which animated films have the biggest box office? Top ten', 'Quels films d''animation ont le plus gros box-office ? Les dix premiers', 22, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (1022789, 420818, 330457)', 'representation == ranked-bars; unit(REVENUE) == usd', 'SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE FROM T_WC_T2S_MOVIE JOIN T_WC_T2S_MOVIE_GENRE ON T_WC_T2S_MOVIE_GENRE.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE WHERE T_WC_T2S_MOVIE_GENRE.ID_GENRE = 16 ORDER BY T_WC_T2S_MOVIE.REVENUE DESC LIMIT 8'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which animated films have the biggest box office? Top ten') AS guard);

-- B04 : KEY TEST: the rating is also the default sort key, only the intent (rank) tells a ranking from a plain list
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Rank the Harry Potter films by IMDb rating', 'Classe les films Harry Potter par note IMDb', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (12445, 673, 671, 674, 12444, 767, 672, 675)', 'representation == ranked-bars'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Rank the Harry Potter films by IMDb rating') AS guard);

-- B05 : news programmes lead (Tagesschau, Dagsrevyen): the database's truth
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, ASSERTION_REFRESH_SQL)
SELECT 'Which TV series have the most episodes? Top 10', 'Quelles séries ont le plus d''épisodes ? Les 10 premières', 6, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_SERIE IN (94722, 15325, 1709, 16807, 987, 50821, 2527, 2912)', 'representation == ranked-bars; unit(NUMBER_OF_EPISODES) == count', 'SELECT DISTINCT T_WC_T2S_SERIE.ID_SERIE FROM T_WC_T2S_SERIE ORDER BY T_WC_T2S_SERIE.NUMBER_OF_EPISODES DESC LIMIT 8'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which TV series have the most episodes? Top 10') AS guard);

-- B06 : replaces 'tallest actors' (no height data): Desmond Llewelyn 17, Lois Maxwell 14, Bernard Lee 11
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which actors appeared in the most James Bond films? Top 10', 'Quels acteurs sont apparus dans le plus de films James Bond ? Les 10 premiers', 27, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_PERSON IN (9906, 9878, 9874, 69678, 1595501, 5309, 738, 6610, 10222, 1166842)', 'representation == ranked-bars'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which actors appeared in the most James Bond films? Top 10') AS guard);

-- B07 : 'feature' keeps the short-film animators out; Kevin Dunn leads (405 films): he directs WWE's pay-per-view shows, a real credit, see vaugouin.com/tmdb/person.php?personid=1061603
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which directors have made the most feature films? Top 20', 'Quels réalisateurs ont fait le plus de longs métrages ? Les 20 premiers', 4, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 20', 'representation == ranked-bars'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which directors have made the most feature films? Top 20') AS guard);

-- B08 : answered from T_WC_T2S_LOCATION (country rows with SERIE_COUNT)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which countries have produced the most TV series? Top 10', 'Quels pays ont produit le plus de séries ? Les 10 premiers', 36, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 10', 'representation == ranked-bars'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which countries have produced the most TV series? Top 10') AS guard);

-- B09 : exactly the poster-row limit
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The 12 highest-rated Studio Ghibli films', 'Les 12 films du Studio Ghibli les mieux notés', 7, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (129, 12477, 128, 4935, 8392, 10515, 149871, 16859, 149870, 37797, 11621, 12429)', 'representation == ranked-bars'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The 12 highest-rated Studio Ghibli films') AS guard);

-- B10 : no N: 27 rows ordered on RUNTIME, bars with text labels beyond 12
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which James Bond films were the longest?', 'Quels films James Bond sont les plus longs ?', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (370172, 206647, 36557, 37724, 668, 36670, 709, 36669)', 'representation == ranked-bars; unit(RUNTIME) == minutes'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which James Bond films were the longest?') AS guard);


-- ===== Section C : count (number-card, observed) ; intent.task = count =====

-- C01
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many films did Alfred Hitchcock direct?', 'Combien de films Alfred Hitchcock a-t-il réalisés ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt; 40', 'result_kind == count; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many films did Alfred Hitchcock direct?') AS guard);

-- C02
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many films are in the James Bond collection?', 'Combien de films compte la collection James Bond ?', 47, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt; 20', 'result_kind == count; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many films are in the James Bond collection?') AS guard);

-- C03 : a stored total, not a COUNT(*): result_kind may be scalar
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many episodes does The Simpsons have?', 'Combien d''épisodes compte Les Simpson ?', 6, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt; 700', 'representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many episodes does The Simpsons have?') AS guard);

-- C04
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many French-language films were released in 1960?', 'Combien de films en langue française sont sortis en 1960 ?', 20, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt; 100', 'result_kind == count; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many French-language films were released in 1960?') AS guard);

-- C05 : DEFECT seen 2026-10-31: Green answers 13 (every film where a character is named James Bond); scoped to the James Bond collection the answer is 6 (Connery, Lazenby, Moore, Dalton, Brosnan, Craig)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many actors have played James Bond?', 'Combien d''acteurs ont joué James Bond ?', 15, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) == 6', 'result_kind == count; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many actors have played James Bond?') AS guard);

-- C06
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many films have won the Academy Award for Best Picture?', 'Combien de films ont remporté l''Oscar du meilleur film ?', 11, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt; 50', 'result_kind == count; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many films have won the Academy Award for Best Picture?') AS guard);

-- C07 : reworded: without 'feature' Green counts 143 (shorts included); 41 with
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many feature films has Pixar produced?', 'Combien de longs métrages Pixar a-t-il produits ?', 7, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt;= 25', 'result_kind == count; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many feature films has Pixar produced?') AS guard);

-- C08 : replaces 'born in Paris' (only COUNTRY_OF_BIRTH exists); 9,823 on Green 2026-10-31. The list form, 'People born in France' (2395), is already in the bank as a showcase; this is its count twin
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many persons were born in France?', 'Combien de personnes sont nées en France ?', 33, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt; 5000', 'result_kind == count; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many persons were born in France?') AS guard);

-- C09 : a stored attribute read as a count
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many seasons does Game of Thrones have?', 'Combien de saisons compte Game of Thrones ?', 6, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) == 8', 'representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many seasons does Game of Thrones have?') AS guard);

-- C10 : about 4,000 a year
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many documentaries were released in the 2010s?', 'Combien de documentaires sont sortis dans les années 2010 ?', 21, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) == 1 AND CELL(0, 0) &gt; 20000', 'result_kind == count; representation == number-card'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many documentaries were released in the 2010s?') AS guard);


-- ===== Section D : comparison (phase 1: value-cards; phase 2: compare-cards) ; intent.task = compare =====

-- D01 : years added: the bare titles returned 13 homonyms
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which is longer, Titanic (1997) or Avatar (2009)?', 'Lequel est le plus long, Titanic (1997) ou Avatar (2009) ?', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (597, 19995)', 'representation == value-cards; unit(RUNTIME) == minutes'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which is longer, Titanic (1997) or Avatar (2009)?') AS guard);

-- D02 : year added: 'Avatar' alone returned 7 rows
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Compare the budgets of Avatar (2009) and Avengers: Endgame', 'Compare les budgets d''Avatar (2009) et d''Avengers : Endgame', 22, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (299534, 19995)', 'representation == value-cards; unit(BUDGET) == usd'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Compare the budgets of Avatar (2009) and Avengers: Endgame') AS guard);

-- D03 : reworded twice: 'which has more' returned the winner only, 'Friends' alone returned 5 homonyms
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Compare the number of seasons of Friends (1994) and Seinfeld', 'Compare le nombre de saisons de Friends (1994) et de Seinfeld', 6, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_SERIE IN (1668, 1400)', 'representation == value-cards; unit(NUMBER_OF_SEASONS) == count'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Compare the number of seasons of Friends (1994) and Seinfeld') AS guard);

-- D04 : year added: four Barbie homonyms
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which earned more at the box office, Barbie (2023) or Oppenheimer?', 'Lequel a rapporté le plus au box-office, Barbie (2023) ou Oppenheimer ?', 22, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (346698, 872585)', 'representation == value-cards; unit(REVENUE) == usd'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which earned more at the box office, Barbie (2023) or Oppenheimer?') AS guard);

-- D05 : year added: a 2023 short called The Godfather crept in
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Compare the IMDb ratings of The Godfather (1972) and The Godfather Part II', 'Compare les notes IMDb du Parrain (1972) et du Parrain, 2e partie', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (238, 240)', 'representation == value-cards'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Compare the IMDb ratings of The Godfather (1972) and The Godfather Part II') AS guard);

-- D06 : two persons with a FILM_COUNT each (64 vs 56 on Green)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Who has directed more films, Woody Allen or Martin Scorsese?', 'Qui a réalisé le plus de films, Woody Allen ou Martin Scorsese ?', 4, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_PERSON IN (1032, 1243)', 'representation == value-cards'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Who has directed more films, Woody Allen or Martin Scorsese?') AS guard);

-- D07 : reworded: 'who was born first' returned Hitchcock alone
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Compare the birth years of Alfred Hitchcock and Orson Welles', 'Compare les années de naissance d''Alfred Hitchcock et d''Orson Welles', 35, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_PERSON IN (2636, 40)', 'representation == value-cards'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Compare the birth years of Alfred Hitchcock and Orson Welles') AS guard);

-- D08 : year added: the 2016 remake came along
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Compare the runtimes of Seven Samurai and The Magnificent Seven (1960)', 'Compare les durées des Sept Samouraïs et des Sept Mercenaires (1960)', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (346, 966)', 'representation == value-cards; unit(RUNTIME) == minutes'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Compare the runtimes of Seven Samurai and The Magnificent Seven (1960)') AS guard);

-- D09
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which has more episodes, The Simpsons or South Park?', 'Laquelle a le plus d''épisodes, Les Simpson ou South Park ?', 6, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_SERIE IN (456, 2190)', 'representation == value-cards; unit(NUMBER_OF_EPISODES) == count'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which has more episodes, The Simpsons or South Park?') AS guard);

-- D10 : two metrics per card
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Compare the budget and the revenue of Jurassic Park and Jurassic World', 'Compare le budget et la recette de Jurassic Park et de Jurassic World', 22, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (329, 135397)', 'representation == value-cards'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Compare the budget and the revenue of Jurassic Park and Jurassic World') AS guard);


-- ===== Section E : sequence (card-grid in phase 1; phase 2: sequence-strip) ; intent.task = sequence =====

-- E01 : DEFECT seen 2026-10-31: the universe resolves to every Marvel film, Howard the Duck (1986) comes first; the MCU opens with Iron Man (1726)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'In which order should I watch the Marvel Cinematic Universe films, by release date?', 'Dans quel ordre regarder les films de l''univers cinématographique Marvel, par date de sortie ?', 47, 1, 1, 0, 0, CURDATE(), 1, 1, 'CELL(0, 0) == 1726', 'representation == card-grid'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'In which order should I watch the Marvel Cinematic Universe films, by release date?') AS guard);

-- E02
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The Godfather trilogy in order', 'La trilogie du Parrain dans l''ordre', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (238, 240, 242)', 'representation == card-grid'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The Godfather trilogy in order') AS guard);

-- E03
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'List the Indiana Jones films from first to last', 'Liste les films Indiana Jones du premier au dernier', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (85, 87, 89, 217, 335977)', 'representation == card-grid'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'List the Indiana Jones films from first to last') AS guard);

-- E04
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Sergio Leone''s Dollars trilogy in order of release', 'La trilogie du dollar de Sergio Leone par ordre de sortie', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (391, 938, 429)', 'representation == card-grid'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Sergio Leone''s Dollars trilogy in order of release') AS guard);

-- E05 : reworded: 'Kieslowski's Three Colours trilogy' resolved to nothing (0 rows)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The Three Colors trilogy by Krzysztof Kieslowski in order', 'La trilogie Trois Couleurs de Krzysztof Kieslowski dans l''ordre', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (108, 109, 110)', 'representation == card-grid'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The Three Colors trilogy by Krzysztof Kieslowski in order') AS guard);

-- E06 : 16 rows on Green incl. the early shorts; the features anchor it
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which films did Stanley Kubrick direct, from his first to his last?', 'Quels films Stanley Kubrick a-t-il réalisés, du premier au dernier ?', 4, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (10165, 10056, 247, 975, 967, 802, 935, 62, 185, 3175, 694)', 'representation == card-grid'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which films did Stanley Kubrick direct, from his first to his last?') AS guard);

-- E07 : replaces Planet of the Apes, whose two collections answer differently
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The Matrix films in release order', 'Les films Matrix par ordre de sortie', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (603, 604, 605, 624860)', 'representation == card-grid'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The Matrix films in release order') AS guard);

-- E08
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Richard Linklater''s Before trilogy in order', 'La trilogie Before de Richard Linklater dans l''ordre', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (76, 80, 132344)', 'representation == card-grid'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Richard Linklater''s Before trilogy in order') AS guard);

-- E09 : same set as A03, sequence intent instead of value
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The Toy Story films from the first to the latest', 'Les films Toy Story du premier au plus récent', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (862, 863, 10193, 301528, 1084244)', 'representation == card-grid'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The Toy Story films from the first to the latest') AS guard);

-- E10 : Creed is not in the collection
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'The Rocky films in release order', 'Les films Rocky par ordre de sortie', 47, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (1366, 1367, 1371, 1374, 1375, 1246)', 'representation == card-grid'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'The Rocky films in release order') AS guard);


-- ===== Section F : trend (table in phase 1; phase 2: trend-columns) ; intent.task = trend =====

-- F01 : 7 decades on Green
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many films did Woody Allen direct per decade?', 'Combien de films Woody Allen a-t-il réalisés par décennie ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) &gt;= 6', 'representation == table'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many films did Woody Allen direct per decade?') AS guard);

-- F02
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many films were released each year since 2000?', 'Combien de films sont sortis chaque année depuis 2000 ?', 10, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) &gt;= 25', 'representation == table'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many films were released each year since 2000?') AS guard);

-- F03
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many horror films were released per decade?', 'Combien de films d''horreur sont sortis par décennie ?', 55, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) &gt;= 10', 'representation == table'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many horror films were released per decade?') AS guard);

-- F04
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many TV series started each year since 2010?', 'Combien de séries ont démarré chaque année depuis 2010 ?', 39, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) &gt;= 15', 'representation == table'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many TV series started each year since 2010?') AS guard);

-- F05 : alias observed on Green; the unit clause fails if the model renames it
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'What is the average runtime of films by decade?', 'Quelle est la durée moyenne des films par décennie ?', 3, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) &gt;= 10', 'representation == table; unit(AVERAGE_RUNTIME_MINUTES) == minutes'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'What is the average runtime of films by decade?') AS guard);

-- F06 : DEFECT seen 2026-10-31: a NULL year row opens the series; 1984 (Andre and Wally B.) must come first
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many films has Pixar released per year?', 'Combien de films Pixar a-t-il sortis par an ?', 7, 1, 1, 0, 0, CURDATE(), 1, 1, 'CELL(0, 0) == 1984', 'representation == table'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many films has Pixar released per year?') AS guard);

-- F07
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many Japanese films were released per decade since 1950?', 'Combien de films japonais sont sortis par décennie depuis 1950 ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) &gt;= 7', 'representation == table'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many Japanese films were released per decade since 1950?') AS guard);

-- F08
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'What was the average film budget per year since 2000?', 'Quel était le budget moyen des films par an depuis 2000 ?', 22, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) &gt;= 25', 'representation == table'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'What was the average film budget per year since 2000?') AS guard);

-- F09 : replaces the Best Picture nominees per year, which returned no rows: the SQL tested NOMINATION_NAME = 'Best Picture Oscar' literally (archive/check-award-nomination-data.sql tells whether the data or the name is missing)
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many Criterion Collection films were released per decade?', 'Combien de films de la collection Criterion sont sortis par décennie ?', 45, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) &gt;= 10', 'representation == table'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many Criterion Collection films were released per decade?') AS guard);

-- F10
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'How many documentaries were released per year since 2015?', 'Combien de documentaires sont sortis par an depuis 2015 ?', 21, 1, 1, 0, 0, CURDATE(), 1, 1, 'COUNT(*) &gt;= 10', 'representation == table'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'How many documentaries were released per year since 2015?') AS guard);


-- Control: the sixty rows, their flags and the showcase count.
SELECT COUNT(*) AS INSERTED_TODAY, SUM(IS_SHOWCASE) AS SHOWCASE_ROWS, SUM(ASSERTION_REFRESH_SQL IS NOT NULL) AS REFRESH_ROWS
  FROM T_WC_T2S_EVALUATION WHERE DAT_CREAT = CURDATE() AND IS_SAMPLE = 1 AND DELETED = 0;
SELECT ID_T2S_EVALUATION, QUESTION, ID_T2S_EVALUATION_CATEGORY, IS_SHOWCASE
  FROM T_WC_T2S_EVALUATION WHERE DAT_CREAT = CURDATE() AND DELETED = 0 ORDER BY ID_T2S_EVALUATION;
