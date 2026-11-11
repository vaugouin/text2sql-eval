-- New evaluations for phase 3 of the result representations (scatter, map, hierarchy, chain),
-- 2026-11-11. Written before any API rule or renderer (rule of 2026-10-31: a feature that changes
-- the API's behaviour starts with its evaluations). Study:
-- Nestor/projets/t2s-backlog/result-representations-phase3-study.md.
--
-- WHAT THIS FILE DOES
-- Adds forty questions with their French twins, ids 2900 to 2939 set explicitly:
--   2900-2909  scatter: entity rows and two quantities the question names (budget and revenue,
--              runtime and rating, votes and rating, year and rating, seasons and rating), one
--              point per entity. The intent already carries both focus columns on 1.1.20.
--   2910-2919  map: places as pins (2910 to 2915; the coordinates are Wikidata P625, read by the
--              API, not by the SQL) and countries as a choropleth (2916 to 2919; country codes, the
--              shape flag-list draws today). Every question asks for a map in its wording.
--   2920-2929  hierarchy: nested collections (2920, 2921, 2927), places under the region, state or
--              nation that contains them (2922, 2923, 2926, 2928), company trees (2924, 2925; thin
--              data: 26 companies of 183,273 carry a parent), films grouped by a person (2929).
--   2930-2939  chain: remake and adaptation lineages through T_WC_T2S_SOURCE_WORK.ID_MOVIE, upstream
--              (2930 to 2936), downstream (2937, 2938) and both ways (2939). Person-to-person paths
--              (How is Kevin Bacon connected to Toshiro Mifune?) are left out: blocked for a single
--              SQL query, see the study.
--
-- ASSERTIONS. query_result pins what the 1.1.20 probes returned or what the base holds
-- (check-phase3-feasibility-20261111.txt); where the 1.1.20 SQL was wrong it says so in LONG_DESC
-- and fails today (2919, 2921, 2925, 2929, 2933, 2936). result_shape (out of score) asserts the new
-- representation only, no intent.task clause: the classifier reads these as value, relate, trend,
-- sequence or list, and the phase 3 rules are not written yet.
--
-- BASELINE on the live API 1.1.20 (Blue, cache off, no cache write, 2026-11-11, 40 English and
-- 22 French calls; responses kept outside the repositories, in the session scratch folder named in
-- the study): every result_shape assertion fails, as intended (ranked-bars, value-cards, card-grid,
-- entity-page or flag-list served).
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1, IS_SHOWCASE = 0 on all forty.
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/new-evaluations-phase3.sql
-- Commit and push before running. Each INSERT is guarded by NOT EXISTS on its id or its English
-- question, so a re-run inserts nothing. `>` is stored as &gt; in query_result. French twins carry
-- their accents: the runner sets utf8mb4. AUTO_INCREMENT moves to 2940.

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2900
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2900, 'Plot the budget against the box-office revenue of Christopher Nolan''s films', 'Trace le budget en fonction des recettes des films de Christopher Nolan', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 10 AND ID_MOVIE IN (155, 27205, 157336)',
       'representation == scatter',
       'Phase 3, scatter: one point per film, x the budget, y the revenue (two focus quantities on entity rows). 13 of the 17 Nolan films carry both. Served ranked-bars on 1.1.20 (intent value, focus BUDGET and REVENUE).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2900 OR QUESTION = 'Plot the budget against the box-office revenue of Christopher Nolan''s films') AS guard);

-- 2901
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2901, 'Budget versus box-office revenue of the Marvel Cinematic Universe films', 'Budget et recettes des films de l''univers cinématographique Marvel, l''un en fonction de l''autre', 22, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 20 AND ID_MOVIE IN (1726, 10138)',
       'representation == scatter',
       'Phase 3, scatter of budget against revenue over a collection (the MCU, more than one page of films: the caption says the first N). Served value-cards in English and ranked-bars in French on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2901 OR QUESTION = 'Budget versus box-office revenue of the Marvel Cinematic Universe films') AS guard);

-- 2902
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2902, 'Is there a link between runtime and IMDb rating in Stanley Kubrick''s films?', 'Y a-t-il un lien entre la durée et la note IMDb des films de Stanley Kubrick ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 10 AND ID_MOVIE IN (975, 935)',
       'representation == scatter',
       'Phase 3, scatter worded as a relation (a link between two quantities): runtime against IMDb rating, both carried by every Kubrick film. Served ranked-bars in English, card-grid in French (intent relate).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2902 OR QUESTION = 'Is there a link between runtime and IMDb rating in Stanley Kubrick''s films?') AS guard);

-- 2903
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2903, 'Show the IMDb rating of Alfred Hitchcock''s films against their release year', 'Montre la note IMDb des films d''Alfred Hitchcock en fonction de leur année de sortie', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 20',
       'representation == scatter',
       'Phase 3, scatter with a date axis: IMDb rating against release year, one point per film (not a trend: no aggregate per year). Served card-grid on 1.1.20 (intent trend).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2903 OR QUESTION = 'Show the IMDb rating of Alfred Hitchcock''s films against their release year') AS guard);

-- 2904
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2904, 'Does a bigger budget mean a better IMDb rating for the Pixar films?', 'Un plus gros budget donne-t-il une meilleure note IMDb aux films Pixar ?', 22, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 15',
       'representation == scatter',
       'Phase 3, scatter asked as a yes/no question (does a bigger budget mean a better rating): the answer is the cloud, never a Yes or a No. Served ranked-bars (intent relate).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2904 OR QUESTION = 'Does a bigger budget mean a better IMDb rating for the Pixar films?') AS guard);

-- 2905
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2905, 'Scatter plot of the runtime and the IMDb rating of the Studio Ghibli films', 'Nuage de points de la durée et de la note IMDb des films du Studio Ghibli', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 10 AND ID_MOVIE IN (129, 128)',
       'representation == scatter',
       'Phase 3, scatter named as such (scatter plot, nuage de points): runtime against IMDb rating of the Studio Ghibli films. Served ranked-bars.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2905 OR QUESTION = 'Scatter plot of the runtime and the IMDb rating of the Studio Ghibli films') AS guard);

-- 2906
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2906, 'James Bond films: budget against box-office revenue', 'Les films de James Bond : budget en fonction des recettes', 22, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 20 AND ID_MOVIE IN (646, 658)',
       'representation == scatter',
       'Phase 3, scatter of budget against revenue for the James Bond films (27 rows). Served value-cards in English, ranked-bars in French.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2906 OR QUESTION = 'James Bond films: budget against box-office revenue') AS guard);

-- 2907
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2907, 'Plot the number of IMDb votes against the IMDb rating of Quentin Tarantino''s films', 'Trace le nombre de votes IMDb en fonction de la note IMDb des films de Quentin Tarantino', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 8 AND ID_MOVIE IN (680, 500)',
       'representation == scatter',
       'Phase 3, scatter of IMDb votes against IMDb rating (votes span three orders of magnitude: a log axis). Served ranked-bars.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2907 OR QUESTION = 'Plot the number of IMDb votes against the IMDb rating of Quentin Tarantino''s films') AS guard);

-- 2908
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2908, 'How do runtime and box-office revenue relate across the Harry Potter films?', 'Quel rapport entre la durée et les recettes des films Harry Potter ?', 22, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) == 8 AND ID_MOVIE IN (671, 12445)',
       'representation == scatter',
       'Phase 3, scatter of runtime against revenue on eight films, a small cloud where every point can carry its poster. Served ranked-bars (intent relate).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2908 OR QUESTION = 'How do runtime and box-office revenue relate across the Harry Potter films?') AS guard);

-- 2909
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2909, 'Plot the number of seasons against the IMDb rating of HBO series', 'Trace le nombre de saisons en fonction de la note IMDb des séries HBO', 6, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 10 AND ID_SERIE IN (1398, 1438)',
       'representation == scatter',
       'Phase 3, scatter on series: number of seasons against IMDb rating (a discrete x axis). Served ranked-bars.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2909 OR QUESTION = 'Plot the number of seasons against the IMDb rating of HBO series') AS guard);

-- 2910
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2910, 'Show on a map where Lawrence of Arabia was filmed', 'Montre sur une carte où Lawrence d''Arabie a été tourné', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_LOCATION IN (879, 416, 56)',
       'representation == map',
       'Phase 3, map of places (pins): the filming locations of one film, countries, a region and a city. Coordinates come from Wikidata P625 (T_WC_WIKIDATA_COORDINATE_VALUE), not from the SQL rows. Served card-grid on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2910 OR QUESTION = 'Show on a map where Lawrence of Arabia was filmed') AS guard);

-- 2911
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2911, 'Map of the filming locations of Inception', 'Carte des lieux de tournage d''Inception', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 10 AND ID_LOCATION IN (38, 202, 810)',
       'representation == map',
       'Phase 3, map of places: fifteen filming locations of Inception on four continents, mixing countries, regions, cities and structures. Served card-grid.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2911 OR QUESTION = 'Map of the filming locations of Inception') AS guard);

-- 2912
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2912, 'Where were the James Bond films shot? Show the places on a map', 'Où les films de James Bond ont-ils été tournés ? Montre les lieux sur une carte', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 20',
       'representation == map',
       'Phase 3, map of places over a collection (the James Bond films): fifty places on the first page. Served card-grid.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2912 OR QUESTION = 'Where were the James Bond films shot? Show the places on a map') AS guard);

-- 2913
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2913, 'On a map, where does the story of Lost in Translation take place?', 'Sur une carte, où se déroule l''histoire de Lost in Translation ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_LOCATION IN (202, 59)',
       'representation == map',
       'Phase 3, map of narrative locations (where the story takes place): Tokyo and Kyoto. Served card-grid.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2913 OR QUESTION = 'On a map, where does the story of Lost in Translation take place?') AS guard);

-- 2914
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2914, 'Show on a map the places where The Third Man was filmed', 'Montre sur une carte les lieux de tournage du Troisième Homme', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_LOCATION IN (41)',
       'representation == map',
       'Phase 3, map with one city and its country (Vienna, Austria): a pin map that must not zoom to a single point. Served card-grid.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2914 OR QUESTION = 'Show on a map the places where The Third Man was filmed') AS guard);

-- 2915
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2915, 'Map the filming locations of Christopher Nolan''s films', 'Cartographie les lieux de tournage des films de Christopher Nolan', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 20',
       'representation == map',
       'Phase 3, map of places over a filmography (Christopher Nolan), fifty places on the first page. Served card-grid.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2915 OR QUESTION = 'Map the filming locations of Christopher Nolan''s films') AS guard);

-- 2916
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2916, 'Show on a world map the countries that produced the most films in 2020', 'Montre sur une carte du monde les pays qui ont produit le plus de films en 2020', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNTRY_CODE IN (''US'', ''GB'', ''FR'')',
       'representation == map',
       'Phase 3, choropleth of countries asked on a world map: a country code and a count. Served flag-list on 1.1.20 (the default for country rows since lot C): the map is asked by the wording, a requested view.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2916 OR QUESTION = 'Show on a world map the countries that produced the most films in 2020') AS guard);

-- 2917
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2917, 'World map of the number of Netflix series produced per country', 'Carte du monde du nombre de séries Netflix produites par pays', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNTRY_CODE IN (''US'', ''GB'', ''JP'')',
       'representation == map',
       'Phase 3, choropleth of the Netflix series per production country. Served flag-list.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2917 OR QUESTION = 'World map of the number of Netflix series produced per country') AS guard);

-- 2918
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2918, 'On a world map, how many films has each country co-produced with France?', 'Sur une carte du monde, combien de films chaque pays a-t-il coproduits avec la France ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNTRY_CODE IN (''IT'', ''BE'', ''DE'')',
       'representation == map',
       'Phase 3, choropleth of the co-productions with France (France itself absent from the rows). Served flag-list.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2918 OR QUESTION = 'On a world map, how many films has each country co-produced with France?') AS guard);

-- 2919
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2919, 'Show on a map the countries of birth of the directors of Palme d''Or winners', 'Montre sur une carte les pays de naissance des réalisateurs lauréats de la Palme d''or', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNTRY_OF_BIRTH IN (''US'', ''IT'', ''FR'')',
       'representation == map',
       'Phase 3, choropleth of the countries of birth of the directors of Palme d''Or winners. On 1.1.20 the English SQL returned the country locations of the base by film count instead (query_result fails, served flag-list).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2919 OR QUESTION = 'Show on a map the countries of birth of the directors of Palme d''Or winners') AS guard);

-- 2920
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2920, 'Which collections make up the Marvel Cinematic Universe, with the films of each?', 'Quelles collections composent l''univers cinématographique Marvel, avec les films de chacune ?', 47, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 10',
       'representation == hierarchy',
       'Phase 3, hierarchy of collections: the Marvel Cinematic Universe, the collections nested in it (every film of the inner one is in the outer one), and their films. Served card-grid on 1.1.20 (the twelve collections, no films).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2920 OR QUESTION = 'Which collections make up the Marvel Cinematic Universe, with the films of each?') AS guard);

-- 2921
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2921, 'Show the Star Wars films grouped by trilogy', 'Montre les films Star Wars regroupés par trilogie', 47, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 9',
       'representation == hierarchy',
       'Phase 3, hierarchy as a grouping: the Star Wars films under their trilogy. On 1.1.20 the SQL required trilogies of exactly three works and returned one row (query_result fails, served entity-page).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2921 OR QUESTION = 'Show the Star Wars films grouped by trilogy') AS guard);

-- 2922
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2922, 'Which cities of Italy appear as filming locations, grouped by region?', 'Quelles villes d''Italie apparaissent comme lieux de tournage, regroupées par région ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 10',
       'representation == hierarchy',
       'Phase 3, hierarchy of places: cities of Italy under their region (T_WC_T2S_LOCATION_ANCESTOR). On 1.1.20 the SQL returned a REGION_NAME column and a place once per ancestor region (Cirella twice): served card-grid.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2922 OR QUESTION = 'Which cities of Italy appear as filming locations, grouped by region?') AS guard);

-- 2923
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2923, 'Which places of France were Woody Allen''s films shot in, grouped by the region they are in?', 'Dans quels lieux de France les films de Woody Allen ont-ils été tournés, regroupés par région ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_LOCATION IN (38)',
       'representation == hierarchy',
       'Phase 3, hierarchy of places over a filmography: Woody Allen places in France under their region. Same duplication as 2922 on 1.1.20 (Giverny three times); served card-grid.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2923 OR QUESTION = 'Which places of France were Woody Allen''s films shot in, grouped by the region they are in?') AS guard);

-- 2924
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2924, 'Which companies does Sony Pictures own, directly or through its subsidiaries?', 'Quelles sociétés Sony Pictures possède-t-elle, directement ou par ses filiales ?', 12, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_COMPANY IN (2251, 177)',
       'representation == hierarchy',
       'Phase 3, hierarchy of companies (T_WC_T2S_COMPANY.ID_PARENT, recursive): only 26 of 183,273 companies carry a parent, and TMDb files Metro-Goldwyn-Mayer under Sony Pictures. Served card-grid with four companies and no parent column.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2924 OR QUESTION = 'Which companies does Sony Pictures own, directly or through its subsidiaries?') AS guard);

-- 2925
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2925, 'Show the company tree of Time Warner', 'Montre l''arbre des sociétés de Time Warner', 12, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 3',
       'representation == hierarchy',
       'Phase 3, company tree asked by name. On 1.1.20 the name resolved to Time Warner Entertainment Company (157695), not Time Warner (128, three descendants): one row, served entity-page (query_result fails).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2925 OR QUESTION = 'Show the company tree of Time Warner') AS guard);

-- 2926
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2926, 'In which places of the United States were John Ford''s films shot, grouped by state?', 'Dans quels lieux des États-Unis les films de John Ford ont-ils été tournés, regroupés par État ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 5',
       'representation == hierarchy',
       'Phase 3, hierarchy of places grouped by state (STATE_NAME): John Ford places in the United States. Served card-grid, places repeated once per ancestor.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2926 OR QUESTION = 'In which places of the United States were John Ford''s films shot, grouped by state?') AS guard);

-- 2927
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2927, 'Show the Middle-earth films grouped by trilogy', 'Montre les films de la Terre du Milieu regroupés par trilogie', 47, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) == 6 AND ID_MOVIE IN (120, 121, 122, 49051, 57158, 122917)',
       'representation == hierarchy',
       'Phase 3, hierarchy as a grouping: the six Middle-earth films under their two trilogies (TRILOGY_NAME). Served card-grid.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2927 OR QUESTION = 'Show the Middle-earth films grouped by trilogy') AS guard);

-- 2928
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2928, 'In which places of the United Kingdom were the Harry Potter films shot, grouped by nation?', 'Dans quels lieux du Royaume-Uni les films Harry Potter ont-ils été tournés, regroupés par nation ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 10',
       'representation == hierarchy',
       'Phase 3, hierarchy of places: Harry Potter filming places in the United Kingdom under their nation (NATION_NAME: England, Scotland, Wales). Served card-grid.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2928 OR QUESTION = 'In which places of the United Kingdom were the Harry Potter films shot, grouped by nation?') AS guard);

-- 2929
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2929, 'List the James Bond films grouped by the actor who played Bond', 'Liste les films de James Bond regroupés par l''acteur qui jouait Bond', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 20',
       'representation == hierarchy',
       'Phase 3, hierarchy as a grouping by person: the James Bond films under the actor who played Bond. On 1.1.20 the SQL read the series credits and returned nothing (query_result fails).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2929 OR QUESTION = 'List the James Bond films grouped by the actor who played Bond') AS guard);

-- 2930
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2930, 'Trace the chain of remakes behind A Star Is Born (2018)', 'Retrace la chaîne des remakes derrière A Star Is Born (2018)', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (3111, 19610, 22692)',
       'representation == chain',
       'Phase 3, chain of remakes: A Star Is Born 2018 back to 1937. The data is a DAG, not a path: 2018 is linked to 1976, 1954 and 1937, and 1954 and 1976 to 1937. On 1.1.20 the model wrote a WITH RECURSIVE that ran, with 1937 twice (depth 1 and 2), served ranked-bars on REMAKE_DEPTH.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2930 OR QUESTION = 'Trace the chain of remakes behind A Star Is Born (2018)') AS guard);

-- 2931
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2931, 'What is A Fistful of Dollars based on, and what is that based on?', 'De quoi Pour une poignée de dollars est-il adapté, et de quoi cette œuvre est-elle elle-même adaptée ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_SOURCE_WORK IN (7219, 6848)',
       'representation == chain',
       'Phase 3, chain of adaptations across kinds of work: A Fistful of Dollars, Yojimbo (a film, source work 7219), Red Harvest (a novel, 6848; Fistful also cites it directly). Served card-grid of two source works, no order and no link.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2931 OR QUESTION = 'What is A Fistful of Dollars based on, and what is that based on?') AS guard);

-- 2932
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2932, 'Which film is Scarface (1983) a remake of, and what was that film adapted from?', 'De quel film Scarface (1983) est-il le remake, et de quoi ce film était-il adapté ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_SOURCE_WORK IN (7931)',
       'representation == chain',
       'Phase 3, chain of two steps: Scarface 1983, remake of Scarface 1932 (source work 11891), itself from the 1930 novel (7931; 1983 also cites it). Served entity-page with the novel only.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2932 OR QUESTION = 'Which film is Scarface (1983) a remake of, and what was that film adapted from?') AS guard);

-- 2933
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2933, 'Show the remake lineage of The Departed', 'Montre la filiation de remakes des Infiltrés', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (10775)',
       'representation == chain',
       'Phase 3, chain direction: the lineage of The Departed upstream is Infernal Affairs (10775). On 1.1.20 the model walked downstream (remakes of The Departed) and returned two other films (query_result fails, served card-grid).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2933 OR QUESTION = 'Show the remake lineage of The Departed') AS guard);

-- 2934
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2934, 'Trace The Magnificent Seven (2016) back to its origin, remake by remake', 'Remonte des Sept Mercenaires (2016) jusqu''à son origine, remake par remake', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (966, 346)',
       'representation == chain',
       'Phase 3, chain of remakes: The Magnificent Seven 2016, 1960 (966), Seven Samurai (346). Served ranked-bars on REMAKE_STEP, Seven Samurai twice.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2934 OR QUESTION = 'Trace The Magnificent Seven (2016) back to its origin, remake by remake') AS guard);

-- 2935
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2935, 'Trace Nosferatu (2024) back to its source, adaptation by adaptation', 'Remonte de Nosferatu (2024) jusqu''à sa source, adaptation par adaptation', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_SOURCE_WORK IN (5212, 11237)',
       'representation == chain',
       'Phase 3, chain film to film to novel: Nosferatu 2024, Nosferatu 1922 (source work 5212), Dracula (11237). Served ranked-bars on ADAPTATION_STEP, Dracula twice.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2935 OR QUESTION = 'Trace Nosferatu (2024) back to its source, adaptation by adaptation') AS guard);

-- 2936
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2936, 'Trace Last Man Standing (1996) back to the novel it ultimately comes from', 'Remonte de Dernier Recours (1996) jusqu''au roman dont il découle', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_SOURCE_WORK IN (7219, 6848)',
       'representation == chain',
       'Phase 3, chain through a film: Last Man Standing 1996, Yojimbo (7219), Red Harvest (6848). On 1.1.20 only the novel came back, the middle film was dropped (query_result fails, served entity-page).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2936 OR QUESTION = 'Trace Last Man Standing (1996) back to the novel it ultimately comes from') AS guard);

-- 2937
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2937, 'How did Red Harvest reach the screen, remakes included?', 'Comment La Moisson rouge est-elle arrivée à l''écran, remakes compris ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 3',
       'representation == chain',
       'Phase 3, chain downstream from a novel: Red Harvest, Yojimbo, then A Fistful of Dollars and Last Man Standing (a tree of descent, two branches). Served card-grid of three works, no link.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2937 OR QUESTION = 'How did Red Harvest reach the screen, remakes included?') AS guard);

-- 2938
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2938, 'Which films descend from Seven Samurai, remakes of remakes included?', 'Quels films descendent des Sept Samouraïs, remakes de remakes compris ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (966, 333484)',
       'representation == chain',
       'Phase 3, chain downstream with remakes of remakes: Seven Samurai, The Magnificent Seven 1960, then 2016 (whose sources include both). Served card-grid, no link.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2938 OR QUESTION = 'Which films descend from Seven Samurai, remakes of remakes included?') AS guard);

-- 2939
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2939, 'The Magnificent Seven (1960): what is it a remake of, and what was remade from it?', 'Les Sept Mercenaires (1960) : de quoi est-il le remake, et quel remake en a-t-on tiré ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (346, 333484)',
       'representation == chain',
       'Phase 3, chain in both directions around one film: Seven Samurai before The Magnificent Seven 1960, the 2016 remake after. Served card-grid of three films, no direction.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2939 OR QUESTION = 'The Magnificent Seven (1960): what is it a remake of, and what was remade from it?') AS guard);

-- Read-back: the 40 rows as stored.
SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION BETWEEN 2900 AND 2939
ORDER BY ID_T2S_EVALUATION;
