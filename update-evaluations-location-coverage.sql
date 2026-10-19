-- ============================================================================
-- EVALUATIONS-024: location coverage of the bank. Repairs fifteen location
-- evaluations and adds five questions for the cases never tested.
-- ============================================================================
--
-- Written 2026-10-19, the day the place hierarchy went live
-- (T_WC_T2S_LOCATION_ANCESTOR, TMDB-MOVIE-PREPROCESS-048) and the API learnt it
-- (FASTAPI-TEXT2SQL-332, 1.1.19). Voie 1: UPDATE and INSERT on
-- T_WC_T2S_EVALUATION only, nothing else.
--
-- THE FACTS ARE READ, NOT REMEMBERED: harvest-location-coverage-20261019.txt.
-- Every question below was run on Green 1.1.19 the same evening, cache off
-- (retrieve_from_cache=false, as the evaluator sends it), EN and FR, and scored
-- with this repository's assertion functions before being written here.
--
-- WHAT THE TICKET SUSPECTED, AND WHAT THE BASE SAYS
--   * "2504 and 2527 assert no series because a T_WC_T2S_SERIE.DELETED = 0
--     filter drops NULL rows": FALSE. DELETED is 0 on every row of
--     T_WC_T2S_SERIE (102 857), T_WC_T2S_SERIE_LOCATION and
--     T_WC_T2S_MOVIE_LOCATION; there is no NULL. 2504 asserts no series because
--     no series is set in Naples (Naples' two series links are filming ones).
--     2527 asserts no series because its refresh ranked by IMDB_VOTES, where
--     movies win, while the API ranks "most famous" by POPULARITY, where
--     Vancouver series win (The X-Files, Arrow, Lucifer, Fringe).
--   * 2527 failed in all four runs: its French question kept "The Most Famous"
--     as an English movie title, and its English one missed three X-Men movies
--     the vote ranking put in the refresh list but the popularity ranking
--     leaves below row 100.
--   * 2517 fails in French: the question reads "tournés W Islandii" (Polish,
--     a translation accident). Fixed.
--   * 2156 and 2434 fail in French for a reason outside this ticket: "2001,
--     l'Odyssée de l'espace" is extracted as the title "L'odyssée de l'espace"
--     and matches nothing (the base holds "2001 : L'Odyssée de l'espace"). Left
--     red on purpose; it is an API title-resolution defect.
--
-- SECTION 1, REPAIRS
--   2147, 2149, 2150   role regex (narrative, narrative, filming); they had none.
--   2156               LONG_DESC: it named three places for four asserted
--                      (Monument Valley, 2474, was missing).
--   2229, 2230         Game of Thrones: COUNT(*) > 0 replaced by the places, with
--                      the other role's places as counter-examples, plus the role.
--   2231               series set in Paris: a refresh SQL through the hierarchy,
--                      the role regex, and its first value written now.
--   2434               IS_EVAL 1; its refresh SQL returned ten columns and never
--                      ran (guardrail: one ID_ column), removed; the six places of
--                      2001 are a fixed identity. Role regex.
--   2428, 2429, 2435   refresh SQL through T_WC_T2S_LOCATION_ANCESTOR, as the API
--                      now answers (alignment rule, README 4.6). Same QIDs, same
--                      sort, same LIMIT 8.
--   2504               refresh through the hierarchy, COALESCE on DELETED; still
--                      typed, so a series set in Naples will be asserted the
--                      night one appears.
--   2517               French question repaired; refresh through the hierarchy on
--                      both sides (filmed somewhere in Iceland, no narrative place
--                      inside Iceland), as the API writes it.
--   2527               French question repaired; refresh typed, five movies and
--                      five series by POPULARITY through the hierarchy; result
--                      assertion written now with both kinds.
--
-- SECTION 2, NEW QUESTIONS (category 8, movies geography), fixed anchors, no
-- refresh SQL (process 70 would drop the NOT IN):
--   Movies shot in France          a country through the hierarchy: Inception,
--                                  Saving Private Ryan and The Intouchables are
--                                  linked to Paris or Normandy, never to France.
--   Movies shot in Paris           containment does not go upward: four movies
--                                  shot in France outside Paris must not come,
--                                  all rated above row 100 of the answer (7.07).
--   Movies filmed in Cambridge,    a homonym: four living Cambridges. RED in
--   England                        English today (the API looks up the literal
--                                  "Cambridge, England"), green in French; the
--                                  instrument for FASTAPI-TEXT2SQL-258.
--   Movies set in Venice           the French name differs: "Venise".
--   Movies set in fictional places LOCATION_TYPE = 'fiction', not 'city'.
--
-- ESCAPING. Quotes inside stored SQL and regexes as &#039; and &quot;, as in the
-- rest of the columns; process 70 and the evaluator unescape first. Backslashes
-- doubled for MariaDB.
--
-- GUARDS. Every UPDATE withdraws itself if the value changed since the export
-- or the harvest; every INSERT is guarded by NOT EXISTS on the English
-- question. Re-running the file is a no-op.
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 0. BEFORE.
-- ---------------------------------------------------------------------------
SELECT '0. Before' AS SECTION;

SELECT ID_T2S_EVALUATION, IS_EVAL, LEFT(QUESTION, 40) AS QUESTION, LEFT(QUESTION_FR, 40) AS QUESTION_FR,
       LEFT(ASSERTIONS_SQL_QUERY, 50) AS SQL_A, LEFT(ASSERTIONS_QUERY_RESULT, 50) AS RES_A,
       LEFT(ASSERTION_REFRESH_SQL, 60) AS REFRESH
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION IN (2147, 2149, 2150, 2156, 2229, 2230, 2231, 2428, 2429, 2434, 2435, 2504, 2517, 2527);

-- ---------------------------------------------------------------------------
-- 1. REPAIRS.
-- ---------------------------------------------------------------------------

-- 2147, 2149, 2150: the role.
UPDATE T_WC_T2S_EVALUATION
   SET ASSERTIONS_SQL_QUERY = '(?is)\\bLOCATION_ROLE\\s*=\\s*[&#039;&quot;]narrative[&#039;&quot;]',
       LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-19 (EVALUATIONS-024): role regex added, a story set in the place is a narrative location.'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION IN (2147, 2149) AND ASSERTIONS_SQL_QUERY IS NULL;

UPDATE T_WC_T2S_EVALUATION
   SET ASSERTIONS_SQL_QUERY = '(?is)\\bLOCATION_ROLE\\s*=\\s*[&#039;&quot;]filming[&#039;&quot;]',
       LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-19 (EVALUATIONS-024): role regex added, shot in the place is a filming location.'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION = 2150 AND ASSERTIONS_SQL_QUERY IS NULL;

-- 2156: the description.
UPDATE T_WC_T2S_EVALUATION
   SET LONG_DESC = CONCAT(LONG_DESC, ' 2026-10-19 (EVALUATIONS-024), correction: the result assertion holds FOUR places, Namibia (697), Monument Valley (2474), Amalgamated Studios (4957) and Shepperton Studios (5012); 2001 has seven filming places in all (also Arizona, Harris, Utah).'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION = 2156 AND ASSERTIONS_QUERY_RESULT = 'ID_LOCATION IN (697, 2474, 4957, 5012)'
   AND LONG_DESC NOT LIKE '%EVALUATIONS-024%';

-- 2229, 2230: Game of Thrones (1399).
UPDATE T_WC_T2S_EVALUATION
   SET ASSERTIONS_QUERY_RESULT = 'ID_LOCATION IN (2669, 4392, 332) AND ID_LOCATION NOT IN (445, 611, 609)',
       ASSERTIONS_SQL_QUERY = '(?is)\\bLOCATION_ROLE\\s*=\\s*[&#039;&quot;]narrative[&#039;&quot;]',
       LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-19 (EVALUATIONS-024): COUNT(*) > 0 replaced by the three narrative places of Game of Thrones (Westeros, Essos, Sothoryos); its filming countries (Croatia, Northern Ireland, Iceland) must not come, which catches a query that drops the role.'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION = 2229 AND ASSERTIONS_QUERY_RESULT = 'COUNT(*) &gt; 0';

UPDATE T_WC_T2S_EVALUATION
   SET ASSERTIONS_QUERY_RESULT = 'ID_LOCATION IN (445, 611, 609, 56, 688) AND ID_LOCATION NOT IN (2669, 4392)',
       ASSERTIONS_SQL_QUERY = '(?is)\\bLOCATION_ROLE\\s*=\\s*[&#039;&quot;]filming[&#039;&quot;]',
       LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-19 (EVALUATIONS-024): COUNT(*) > 0 replaced by five of the ten filming countries of Game of Thrones (Croatia, Northern Ireland, Iceland, Spain, Malta); Westeros and Essos, its narrative places, must not come.'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION = 2230 AND ASSERTIONS_QUERY_RESULT = 'COUNT(*) &gt; 0';

-- 2231: series set in Paris, through the hierarchy.
UPDATE T_WC_T2S_EVALUATION
   SET ASSERTION_REFRESH_SQL = 'SELECT DISTINCT T_WC_T2S_SERIE.ID_SERIE FROM T_WC_T2S_SERIE JOIN T_WC_T2S_SERIE_LOCATION ON T_WC_T2S_SERIE_LOCATION.ID_SERIE = T_WC_T2S_SERIE.ID_SERIE JOIN T_WC_T2S_LOCATION_ANCESTOR ON T_WC_T2S_LOCATION_ANCESTOR.ID_LOCATION = T_WC_T2S_SERIE_LOCATION.ID_LOCATION JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_LOCATION_ANCESTOR.ID_ANCESTOR WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = &#039;Q90&#039; AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_SERIE_LOCATION.LOCATION_ROLE = &#039;narrative&#039; ORDER BY T_WC_T2S_SERIE.IMDB_RATING_WEIGHTED DESC LIMIT 8',
       ASSERTIONS_QUERY_RESULT = 'ID_SERIE IN (87739, 57736, 103913, 93816, 64249, 225383, 24710, 128061)',
       ASSERTIONS_SQL_QUERY = '(?is)\\bLOCATION_ROLE\\s*=\\s*[&#039;&quot;]narrative[&#039;&quot;]',
       LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-19 (EVALUATIONS-024): COUNT(*) > 0 replaced by a refresh SQL through T_WC_T2S_LOCATION_ANCESTOR (Paris named by its QID Q90, places in Paris included), top 8 by IMDB_RATING_WEIGHTED, and the role regex.'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION = 2231 AND ASSERTIONS_QUERY_RESULT = 'COUNT(*) &gt; 0' AND ASSERTION_REFRESH_SQL IS NULL;

-- 2434: back in the campaign, without the refresh SQL that never ran.
UPDATE T_WC_T2S_EVALUATION
   SET IS_EVAL = 1,
       ASSERTION_REFRESH_SQL = NULL,
       ASSERTIONS_SQL_QUERY = '(?is)\\bLOCATION_ROLE\\s*=\\s*[&#039;&quot;]narrative[&#039;&quot;]',
       LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-19 (EVALUATIONS-024): IS_EVAL set to 1. The refresh SQL returned ten columns and was skipped by process 70 every night (one ID_ column allowed); removed, the six narrative places of 2001 (Africa, Moon, Clavius Base, Jupiter, Discovery One, Tycho) are a fixed identity. Role regex added.'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION = 2434 AND IS_EVAL = 0 AND ASSERTION_REFRESH_SQL LIKE 'SELECT DISTINCT T_WC_T2S_LOCATION.ID_LOCATION, T_WC_T2S_LOCATION.LOCATION_NAME%';

-- 2428, 2429, 2435: the three samples, through the hierarchy.
UPDATE T_WC_T2S_EVALUATION
   SET ASSERTION_REFRESH_SQL = 'SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE FROM T_WC_T2S_MOVIE JOIN T_WC_T2S_MOVIE_LOCATION ON T_WC_T2S_MOVIE_LOCATION.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE JOIN T_WC_T2S_LOCATION_ANCESTOR ON T_WC_T2S_LOCATION_ANCESTOR.ID_LOCATION = T_WC_T2S_MOVIE_LOCATION.ID_LOCATION JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_LOCATION_ANCESTOR.ID_ANCESTOR WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = &#039;Q90&#039; AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_MOVIE_LOCATION.LOCATION_ROLE = &#039;narrative&#039; ORDER BY T_WC_T2S_MOVIE.POPULARITY DESC LIMIT 8',
       LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-19 (EVALUATIONS-024): refresh SQL through T_WC_T2S_LOCATION_ANCESTOR, so that places in Paris count, as the API answers since FASTAPI-TEXT2SQL-332.'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION = 2428 AND ASSERTION_REFRESH_SQL NOT LIKE '%LOCATION_ANCESTOR%';

UPDATE T_WC_T2S_EVALUATION
   SET ASSERTION_REFRESH_SQL = 'SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE FROM T_WC_T2S_MOVIE JOIN T_WC_T2S_MOVIE_LOCATION ON T_WC_T2S_MOVIE_LOCATION.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE JOIN T_WC_T2S_LOCATION_ANCESTOR ON T_WC_T2S_LOCATION_ANCESTOR.ID_LOCATION = T_WC_T2S_MOVIE_LOCATION.ID_LOCATION JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_LOCATION_ANCESTOR.ID_ANCESTOR WHERE T_WC_T2S_LOCATION.ID_WIKIDATA IN (&#039;Q1490&#039;, &#039;Q7473516&#039;) AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_MOVIE_LOCATION.LOCATION_ROLE = &#039;filming&#039; ORDER BY T_WC_T2S_MOVIE.IMDB_RATING_WEIGHTED DESC LIMIT 8',
       LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-19 (EVALUATIONS-024): refresh SQL through T_WC_T2S_LOCATION_ANCESTOR, so that places in Tokyo count, as the API answers since FASTAPI-TEXT2SQL-332.'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION = 2429 AND ASSERTION_REFRESH_SQL NOT LIKE '%LOCATION_ANCESTOR%';

UPDATE T_WC_T2S_EVALUATION
   SET ASSERTION_REFRESH_SQL = 'SELECT DISTINCT T_WC_T2S_SERIE.ID_SERIE FROM T_WC_T2S_SERIE JOIN T_WC_T2S_SERIE_LOCATION ON T_WC_T2S_SERIE_LOCATION.ID_SERIE = T_WC_T2S_SERIE.ID_SERIE JOIN T_WC_T2S_LOCATION_ANCESTOR ON T_WC_T2S_LOCATION_ANCESTOR.ID_LOCATION = T_WC_T2S_SERIE_LOCATION.ID_LOCATION JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_LOCATION_ANCESTOR.ID_ANCESTOR WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = &#039;Q84&#039; AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_SERIE_LOCATION.LOCATION_ROLE = &#039;narrative&#039; ORDER BY T_WC_T2S_SERIE.IMDB_RATING_WEIGHTED DESC LIMIT 8',
       LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-19 (EVALUATIONS-024): refresh SQL through T_WC_T2S_LOCATION_ANCESTOR, so that places in London count, as the API answers since FASTAPI-TEXT2SQL-332.'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION = 2435 AND ASSERTION_REFRESH_SQL NOT LIKE '%LOCATION_ANCESTOR%';

-- 2504: Naples, through the hierarchy, still typed.
UPDATE T_WC_T2S_EVALUATION
   SET ASSERTION_REFRESH_SQL = 'SELECT U.ID_CONTENT, U.CONTENT_TYPE FROM ((SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE AS ID_CONTENT, &#039;movie&#039; AS CONTENT_TYPE, T_WC_T2S_MOVIE.IMDB_RATING_WEIGHTED AS SORT_KEY FROM T_WC_T2S_MOVIE JOIN T_WC_T2S_MOVIE_LOCATION ON T_WC_T2S_MOVIE_LOCATION.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE JOIN T_WC_T2S_LOCATION_ANCESTOR ON T_WC_T2S_LOCATION_ANCESTOR.ID_LOCATION = T_WC_T2S_MOVIE_LOCATION.ID_LOCATION JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_LOCATION_ANCESTOR.ID_ANCESTOR WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = &#039;Q2634&#039; AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_MOVIE_LOCATION.LOCATION_ROLE = &#039;narrative&#039; AND COALESCE(T_WC_T2S_MOVIE_LOCATION.DELETED, 0) = 0 AND COALESCE(T_WC_T2S_MOVIE.DELETED, 0) = 0 ORDER BY T_WC_T2S_MOVIE.IMDB_RATING_WEIGHTED DESC LIMIT 10) UNION ALL (SELECT DISTINCT T_WC_T2S_SERIE.ID_SERIE AS ID_CONTENT, &#039;serie&#039; AS CONTENT_TYPE, T_WC_T2S_SERIE.IMDB_RATING_WEIGHTED AS SORT_KEY FROM T_WC_T2S_SERIE JOIN T_WC_T2S_SERIE_LOCATION ON T_WC_T2S_SERIE_LOCATION.ID_SERIE = T_WC_T2S_SERIE.ID_SERIE JOIN T_WC_T2S_LOCATION_ANCESTOR ON T_WC_T2S_LOCATION_ANCESTOR.ID_LOCATION = T_WC_T2S_SERIE_LOCATION.ID_LOCATION JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_LOCATION_ANCESTOR.ID_ANCESTOR WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = &#039;Q2634&#039; AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_SERIE_LOCATION.LOCATION_ROLE = &#039;narrative&#039; AND COALESCE(T_WC_T2S_SERIE_LOCATION.DELETED, 0) = 0 AND COALESCE(T_WC_T2S_SERIE.DELETED, 0) = 0 ORDER BY T_WC_T2S_SERIE.IMDB_RATING_WEIGHTED DESC LIMIT 10)) AS U ORDER BY U.SORT_KEY DESC LIMIT 20',
       LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-19 (EVALUATIONS-024): the assertion holds movies only because NO series is set in Naples today (its two series links are filming ones), not because of a DELETED filter (no NULL in the base). Refresh SQL through T_WC_T2S_LOCATION_ANCESTOR, Naples by its QID Q2634, still typed: the first series set in Naples will be asserted the night it appears.'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION = 2504 AND ASSERTION_REFRESH_SQL NOT LIKE '%LOCATION_ANCESTOR%';

-- 2517: Iceland, French question repaired, hierarchy on both sides.
UPDATE T_WC_T2S_EVALUATION
   SET QUESTION_FR = 'Films tournés en Islande mais dont l''intrigue se déroule ailleurs',
       ASSERTION_REFRESH_SQL = 'SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE FROM T_WC_T2S_MOVIE JOIN T_WC_T2S_MOVIE_LOCATION filming_link ON filming_link.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE JOIN T_WC_T2S_LOCATION_ANCESTOR filming_ancestor ON filming_ancestor.ID_LOCATION = filming_link.ID_LOCATION JOIN T_WC_T2S_LOCATION iceland ON iceland.ID_LOCATION = filming_ancestor.ID_ANCESTOR WHERE iceland.ID_WIKIDATA = &#039;Q189&#039; AND iceland.DELETED = 0 AND filming_link.LOCATION_ROLE = &#039;filming&#039; AND EXISTS (SELECT 1 FROM T_WC_T2S_MOVIE_LOCATION narrative_link WHERE narrative_link.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE AND narrative_link.LOCATION_ROLE = &#039;narrative&#039;) AND NOT EXISTS (SELECT 1 FROM T_WC_T2S_MOVIE_LOCATION narrative_here JOIN T_WC_T2S_LOCATION_ANCESTOR narrative_ancestor ON narrative_ancestor.ID_LOCATION = narrative_here.ID_LOCATION WHERE narrative_here.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE AND narrative_here.LOCATION_ROLE = &#039;narrative&#039; AND narrative_ancestor.ID_ANCESTOR = iceland.ID_LOCATION) ORDER BY T_WC_T2S_MOVIE.IMDB_RATING_WEIGHTED DESC LIMIT 15',
       ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (157336, 935, 272, 271110, 330459, 1251, 140607, 54138, 18, 2270, 116745, 1563, 493529, 62204, 3683)',
       LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-19 (EVALUATIONS-024): French question repaired (it read "tournés W Islandii", Polish). Refresh SQL through T_WC_T2S_LOCATION_ANCESTOR on both sides: filmed anywhere in Iceland (Q189), and no narrative place inside Iceland, as the API writes it since FASTAPI-TEXT2SQL-332; first value written now.'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION = 2517 AND QUESTION_FR LIKE '%W Islandii%';

-- 2527: Vancouver, French question repaired, typed refresh by POPULARITY.
UPDATE T_WC_T2S_EVALUATION
   SET QUESTION_FR = 'Liste les films et séries télévisées les plus célèbres tournés à Vancouver',
       ASSERTION_REFRESH_SQL = 'SELECT U.ID_CONTENT, U.CONTENT_TYPE FROM ((SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE AS ID_CONTENT, &#039;movie&#039; AS CONTENT_TYPE, T_WC_T2S_MOVIE.POPULARITY AS SORT_KEY FROM T_WC_T2S_MOVIE JOIN T_WC_T2S_MOVIE_LOCATION ON T_WC_T2S_MOVIE_LOCATION.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE JOIN T_WC_T2S_LOCATION_ANCESTOR ON T_WC_T2S_LOCATION_ANCESTOR.ID_LOCATION = T_WC_T2S_MOVIE_LOCATION.ID_LOCATION JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_LOCATION_ANCESTOR.ID_ANCESTOR WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = &#039;Q24639&#039; AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_MOVIE_LOCATION.LOCATION_ROLE = &#039;filming&#039; ORDER BY T_WC_T2S_MOVIE.POPULARITY DESC LIMIT 5) UNION ALL (SELECT DISTINCT T_WC_T2S_SERIE.ID_SERIE AS ID_CONTENT, &#039;serie&#039; AS CONTENT_TYPE, T_WC_T2S_SERIE.POPULARITY AS SORT_KEY FROM T_WC_T2S_SERIE JOIN T_WC_T2S_SERIE_LOCATION ON T_WC_T2S_SERIE_LOCATION.ID_SERIE = T_WC_T2S_SERIE.ID_SERIE JOIN T_WC_T2S_LOCATION_ANCESTOR ON T_WC_T2S_LOCATION_ANCESTOR.ID_LOCATION = T_WC_T2S_SERIE_LOCATION.ID_LOCATION JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_LOCATION_ANCESTOR.ID_ANCESTOR WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = &#039;Q24639&#039; AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_SERIE_LOCATION.LOCATION_ROLE = &#039;filming&#039; ORDER BY T_WC_T2S_SERIE.POPULARITY DESC LIMIT 5)) AS U ORDER BY U.SORT_KEY DESC LIMIT 10',
       ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (597) AND ID_SERIE IN (4087, 1412, 63174, 1705)',
       LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-19 (EVALUATIONS-024): French question repaired (it kept "The Most Famous" as an English movie title). The refresh ranked by IMDB_VOTES while the API ranks "most famous" by POPULARITY, so three X-Men movies of the expected list fell below row 100. Now typed, five movies and five series by POPULARITY through T_WC_T2S_LOCATION_ANCESTOR (Vancouver, Q24639); the series half is no longer empty.'),
       TIM_UPDATED = NOW()
 WHERE ID_T2S_EVALUATION = 2527 AND QUESTION_FR LIKE '%The Most Famous%';


-- ---------------------------------------------------------------------------
-- 2. NEW QUESTIONS, category 8 (movies, geography and language).
-- ---------------------------------------------------------------------------

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Movies shot in France', 'Films tournés en France',
       1, 0, 8, 0, CURDATE(), NOW(),
       '(?is)T_WC_T2S_LOCATION_ANCESTOR.*LOCATION_ROLE\\s*=\\s*[&#039;&quot;]filming[&#039;&quot;]',
       'ID_MOVIE IN (27205, 857, 77338)',
       'EVALUATIONS-024. A country covers the places it contains (T_WC_T2S_LOCATION_ANCESTOR, TMDB-MOVIE-PREPROCESS-048). Inception (Paris), Saving Private Ryan (Calvados) and The Intouchables (Paris, Merville-Franceville) are filming-linked to places in France and never to France itself: without the hierarchy they cannot come. Before 2026-10-19, 27 movies were shot "in France"; through the hierarchy, 1 796.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Movies shot in France') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Movies shot in Paris', 'Films tournés à Paris',
       1, 0, 8, 0, CURDATE(), NOW(),
       '(?is)\\bLOCATION_ROLE\\s*=\\s*[&#039;&quot;]filming[&#039;&quot;]',
       'ID_MOVIE IN (27205, 101) AND ID_MOVIE NOT IN (857, 85, 387, 374720)',
       'EVALUATIONS-024. Containment goes down, never up: a smaller place does not cover a bigger one. Saving Private Ryan, Raiders of the Lost Ark, Das Boot and Dunkirk were shot in France and nowhere in Paris; a query that matches the country, or walks the hierarchy the wrong way, brings them in. All four rate above row 100 of the correct answer (7.07 on 2026-10-19), so their absence is a decision of the query, not an effect of the LIMIT.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Movies shot in Paris') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Movies filmed in Cambridge, England', 'Films tournés à Cambridge, en Angleterre',
       1, 0, 8, 0, CURDATE(), NOW(),
       '(?is)\\bLOCATION_ROLE\\s*=\\s*[&#039;&quot;]filming[&#039;&quot;]',
       'ID_MOVIE IN (266856) AND ID_MOVIE NOT IN (1167351)',
       'EVALUATIONS-024, homonyms (FASTAPI-TEXT2SQL-258). Four living places are named Cambridge (England Q350, Massachusetts Q49111, Ontario Q1028279, Ohio Q249454). The Theory of Everything was filmed in the English one; Longing (1167351) in the Ontario one and must not come. On 2026-10-19 the French form passes (Cambridge and England as two places, joined through the hierarchy) and the English one returns nothing (the API looks up the literal name "Cambridge, England"): red until homonyms are resolved.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Movies filmed in Cambridge, England') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Movies set in Venice', 'Films qui se passent à Venise',
       1, 0, 8, 0, CURDATE(), NOW(),
       '(?is)\\bLOCATION_ROLE\\s*=\\s*[&#039;&quot;]narrative[&#039;&quot;]',
       'ID_MOVIE IN (36557, 1213, 6619)',
       'EVALUATIONS-024. A French place name that differs from the English one: "Venise" must resolve through LOCATION_NAME_FR to Venice (Q641). Casino Royale, The Talented Mr. Ripley and Death in Venice are set there.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Movies set in Venice') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Movies set in fictional places', 'Films qui se déroulent dans des lieux imaginaires',
       1, 0, 8, 0, CURDATE(), NOW(),
       '(?is)\\bLOCATION_TYPE\\s*=\\s*[&#039;&quot;]fiction[&#039;&quot;]',
       'ID_MOVIE IN (155, 1891, 105)',
       'EVALUATIONS-024. A LOCATION_TYPE other than city: 575 living places are typed fiction. The Dark Knight (Gotham City), The Empire Strikes Back (Hoth, Dagobah, Bespin) and Back to the Future (Hill Valley) are set in one.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Movies set in fictional places') AS existing);


-- ---------------------------------------------------------------------------
-- 3. AFTER.
-- ---------------------------------------------------------------------------
SELECT '3. After, repaired rows' AS SECTION;

SELECT ID_T2S_EVALUATION, IS_EVAL, LEFT(QUESTION_FR, 50) AS QUESTION_FR,
       ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT,
       CASE WHEN ASSERTION_REFRESH_SQL LIKE '%LOCATION_ANCESTOR%' THEN 'hierarchy'
            WHEN ASSERTION_REFRESH_SQL IS NULL THEN 'none' ELSE 'other' END AS REFRESH
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION IN (2147, 2149, 2150, 2156, 2229, 2230, 2231, 2428, 2429, 2434, 2435, 2504, 2517, 2527);

SELECT '3b. After, new rows' AS SECTION;

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, QUESTION, QUESTION_FR, ASSERTIONS_SQL_QUERY, ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION
WHERE QUESTION IN ('Movies shot in France', 'Movies shot in Paris', 'Movies filmed in Cambridge, England',
                   'Movies set in Venice', 'Movies set in fictional places');

SELECT '3c. The refresh SQL as stored, run here unescaped: 2231, 2504, 2517, 2527 must return ids' AS SECTION;

SELECT DISTINCT T_WC_T2S_SERIE.ID_SERIE FROM T_WC_T2S_SERIE JOIN T_WC_T2S_SERIE_LOCATION ON T_WC_T2S_SERIE_LOCATION.ID_SERIE = T_WC_T2S_SERIE.ID_SERIE JOIN T_WC_T2S_LOCATION_ANCESTOR ON T_WC_T2S_LOCATION_ANCESTOR.ID_LOCATION = T_WC_T2S_SERIE_LOCATION.ID_LOCATION JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_LOCATION_ANCESTOR.ID_ANCESTOR WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = 'Q90' AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_SERIE_LOCATION.LOCATION_ROLE = 'narrative' ORDER BY T_WC_T2S_SERIE.IMDB_RATING_WEIGHTED DESC LIMIT 8;

SELECT U.ID_CONTENT, U.CONTENT_TYPE FROM ((SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE AS ID_CONTENT, 'movie' AS CONTENT_TYPE, T_WC_T2S_MOVIE.POPULARITY AS SORT_KEY FROM T_WC_T2S_MOVIE JOIN T_WC_T2S_MOVIE_LOCATION ON T_WC_T2S_MOVIE_LOCATION.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE JOIN T_WC_T2S_LOCATION_ANCESTOR ON T_WC_T2S_LOCATION_ANCESTOR.ID_LOCATION = T_WC_T2S_MOVIE_LOCATION.ID_LOCATION JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_LOCATION_ANCESTOR.ID_ANCESTOR WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = 'Q24639' AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_MOVIE_LOCATION.LOCATION_ROLE = 'filming' ORDER BY T_WC_T2S_MOVIE.POPULARITY DESC LIMIT 5) UNION ALL (SELECT DISTINCT T_WC_T2S_SERIE.ID_SERIE AS ID_CONTENT, 'serie' AS CONTENT_TYPE, T_WC_T2S_SERIE.POPULARITY AS SORT_KEY FROM T_WC_T2S_SERIE JOIN T_WC_T2S_SERIE_LOCATION ON T_WC_T2S_SERIE_LOCATION.ID_SERIE = T_WC_T2S_SERIE.ID_SERIE JOIN T_WC_T2S_LOCATION_ANCESTOR ON T_WC_T2S_LOCATION_ANCESTOR.ID_LOCATION = T_WC_T2S_SERIE_LOCATION.ID_LOCATION JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_LOCATION_ANCESTOR.ID_ANCESTOR WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = 'Q24639' AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_SERIE_LOCATION.LOCATION_ROLE = 'filming' ORDER BY T_WC_T2S_SERIE.POPULARITY DESC LIMIT 5)) AS U ORDER BY U.SORT_KEY DESC LIMIT 10;

SELECT COUNT(*) AS N_2504 FROM ((SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE AS ID_CONTENT, 'movie' AS CONTENT_TYPE, T_WC_T2S_MOVIE.IMDB_RATING_WEIGHTED AS SORT_KEY FROM T_WC_T2S_MOVIE JOIN T_WC_T2S_MOVIE_LOCATION ON T_WC_T2S_MOVIE_LOCATION.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE JOIN T_WC_T2S_LOCATION_ANCESTOR ON T_WC_T2S_LOCATION_ANCESTOR.ID_LOCATION = T_WC_T2S_MOVIE_LOCATION.ID_LOCATION JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_LOCATION_ANCESTOR.ID_ANCESTOR WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = 'Q2634' AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_MOVIE_LOCATION.LOCATION_ROLE = 'narrative' AND COALESCE(T_WC_T2S_MOVIE_LOCATION.DELETED, 0) = 0 AND COALESCE(T_WC_T2S_MOVIE.DELETED, 0) = 0 ORDER BY T_WC_T2S_MOVIE.IMDB_RATING_WEIGHTED DESC LIMIT 10)) AS U;

SELECT COUNT(*) AS N_2517 FROM (SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE FROM T_WC_T2S_MOVIE JOIN T_WC_T2S_MOVIE_LOCATION filming_link ON filming_link.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE JOIN T_WC_T2S_LOCATION_ANCESTOR filming_ancestor ON filming_ancestor.ID_LOCATION = filming_link.ID_LOCATION JOIN T_WC_T2S_LOCATION iceland ON iceland.ID_LOCATION = filming_ancestor.ID_ANCESTOR WHERE iceland.ID_WIKIDATA = 'Q189' AND iceland.DELETED = 0 AND filming_link.LOCATION_ROLE = 'filming' AND EXISTS (SELECT 1 FROM T_WC_T2S_MOVIE_LOCATION narrative_link WHERE narrative_link.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE AND narrative_link.LOCATION_ROLE = 'narrative') AND NOT EXISTS (SELECT 1 FROM T_WC_T2S_MOVIE_LOCATION narrative_here JOIN T_WC_T2S_LOCATION_ANCESTOR narrative_ancestor ON narrative_ancestor.ID_LOCATION = narrative_here.ID_LOCATION WHERE narrative_here.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE AND narrative_here.LOCATION_ROLE = 'narrative' AND narrative_ancestor.ID_ANCESTOR = iceland.ID_LOCATION) ORDER BY T_WC_T2S_MOVIE.IMDB_RATING_WEIGHTED DESC LIMIT 15) AS X;
