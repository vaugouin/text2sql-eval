-- ============================================================================
-- Samples 2428, 2429, 2435: move the refresh SQL off the Wikidata V1 tables onto
-- the locations read-model (follow-up of EVALUATIONS-012)
-- ============================================================================
--
-- THE PROBLEM. EVALUATIONS-012 rewrote four evaluations for the locations
-- read-model (T_WC_T2S_LOCATION, T_WC_T2S_MOVIE_LOCATION / T_WC_T2S_SERIE_LOCATION
-- with LOCATION_ROLE 'narrative' or 'filming'). Three showcase samples were left on
-- the old shape, and process 70 (tmdb-movie-preprocess) still re-runs their refresh
-- SQL every night against it:
--
--   2428  List popular movies happening in Paris   P840 + T_WC_T2S_ITEM.ITEM_LABEL = 'Paris'
--   2429  List movies shot in Tokyo                P915 + T_WC_T2S_ITEM.ITEM_LABEL = 'Tokyo'
--   2435  List TV series happening in London       P840 + T_WC_T2S_ITEM.ITEM_LABEL = 'London'
--
-- The roles are right (P840 = narrative for "happening in", P915 = filming for
-- "shot in"). What is wrong is the source: T_WC_WIKIDATA_ITEM_PROPERTY is the V1
-- table being decommissioned (WIKIDATA-CRAWLER-015/-022) and mixes statement and
-- qualifier values (WIKIDATA-CRAWLER-014), and T_WC_T2S_ITEM disappears with
-- TMDB-MOVIE-PREPROCESS-047. The day either goes, the three samples stop refreshing.
-- The label match also takes every homonym: ITEM_LABEL = 'Paris' includes
-- Paris, Texas.
--
-- THE NEW REFRESH SQL reads the T2S tables the API itself queries, keeps each
-- sample's sort and LIMIT 8, and names the place by its QID (Q90 Paris, Q1490
-- and Q7473516 Tokyo, Q84 London) rather than its label, so that no homonym slips in. The QID
-- is the business key of T_WC_T2S_LOCATION; ID_LOCATION would work too but is
-- less readable in a stored query. Section 1 checks the three QIDs against the data.
--
-- SQL ASSERTION. Each sample also gets the LOCATION_ROLE regex EVALUATIONS-012
-- gave its four evaluations, so a query that confuses setting and shooting fails
-- even when the films happen to be right.
--
-- ASSERTIONS_QUERY_RESULT is not written here: process 70 rewrites it from the new
-- refresh SQL on its next nightly run. Section 3 previews what it will write.
--
-- ESCAPING. Quotes are stored as &#039; and &quot;, as in the rest of the column;
-- process 70 and the evaluator unescape first. Backslashes are doubled for MariaDB.
--
-- GUARDS. Every UPDATE withdraws itself if the value changed since the export of
-- 2026-10-12: refresh SQL guarded on still naming T_WC_WIKIDATA_ITEM_PROPERTY, SQL
-- assertions on being empty. Re-running the file is a no-op.
--
-- WRITES. Seven UPDATE statements on T_WC_T2S_EVALUATION, three rows, nothing else.
--
-- APPLIED 2026-10-17 18:14 on vaugouindb, result in
-- update-evaluations-locations-v1-samples-20261017.txt: the six UPDATE of the first
-- version applied. Section 1 then showed a second living "Tokyo", Q7473516 (the
-- special wards, ID_LOCATION 731, 7 filming links) beside Q1490 (ID_LOCATION 202,
-- 10 filming links). Section 2b, added the same evening, takes both into 2429,
-- guarded on the Q1490-only value. Re-run the whole file with -f: only 2b applies.
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 0. BEFORE.
-- ---------------------------------------------------------------------------
SELECT '0. Before' AS SECTION;

SELECT ID_T2S_EVALUATION,
       LEFT(QUESTION, 45)             AS QUESTION,
       IS_EVAL, IS_SAMPLE,
       ASSERTIONS_QUERY_RESULT,
       ASSERTIONS_SQL_QUERY,
       ASSERTION_REFRESH_LAST,
       ASSERTION_REFRESH_SQL
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION IN (2428, 2429, 2435);

-- ---------------------------------------------------------------------------
-- 1. CHECK THE QIDS. Every living place named Paris, Tokyo or London, with its
--    counts per role. Q90, Q1490 and Q84 must be the rows with by far the most
--    links in the role the sample asks for.
-- ---------------------------------------------------------------------------
SELECT '1. Places named Paris, Tokyo, London' AS SECTION;

SELECT l.ID_LOCATION, l.ID_WIKIDATA, l.LOCATION_NAME, l.LOCATION_TYPE,
       (SELECT COUNT(*) FROM T_WC_T2S_MOVIE_LOCATION ml
         WHERE ml.ID_LOCATION = l.ID_LOCATION AND ml.LOCATION_ROLE = 'narrative') AS MOVIE_NARRATIVE,
       (SELECT COUNT(*) FROM T_WC_T2S_MOVIE_LOCATION ml
         WHERE ml.ID_LOCATION = l.ID_LOCATION AND ml.LOCATION_ROLE = 'filming')   AS MOVIE_FILMING,
       (SELECT COUNT(*) FROM T_WC_T2S_SERIE_LOCATION sl
         WHERE sl.ID_LOCATION = l.ID_LOCATION AND sl.LOCATION_ROLE = 'narrative') AS SERIE_NARRATIVE,
       (SELECT COUNT(*) FROM T_WC_T2S_SERIE_LOCATION sl
         WHERE sl.ID_LOCATION = l.ID_LOCATION AND sl.LOCATION_ROLE = 'filming')   AS SERIE_FILMING
FROM T_WC_T2S_LOCATION l
WHERE l.DELETED = 0
  AND (l.LOCATION_NAME IN ('Paris', 'Tokyo', 'London')
       OR l.ID_WIKIDATA IN ('Q90', 'Q1490', 'Q84'))
ORDER BY l.LOCATION_NAME, l.ID_LOCATION;

-- ---------------------------------------------------------------------------
-- 2. THE CORRECTION.
-- ---------------------------------------------------------------------------

-- 2428 · List popular movies happening in Paris (narrative, by popularity)
UPDATE T_WC_T2S_EVALUATION
SET ASSERTION_REFRESH_SQL = 'SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE FROM T_WC_T2S_MOVIE JOIN T_WC_T2S_MOVIE_LOCATION ON T_WC_T2S_MOVIE_LOCATION.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_MOVIE_LOCATION.ID_LOCATION WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = &#039;Q90&#039; AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_MOVIE_LOCATION.LOCATION_ROLE = &#039;narrative&#039; ORDER BY T_WC_T2S_MOVIE.POPULARITY DESC LIMIT 8',
    LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-17: refresh SQL moved from the Wikidata V1 tables (T_WC_WIKIDATA_ITEM_PROPERTY P840, T_WC_T2S_ITEM label) to the locations read-model, Paris named by its QID Q90, role narrative.'),
    TIM_UPDATED = NOW()
WHERE ID_T2S_EVALUATION = 2428
  AND ASSERTION_REFRESH_SQL LIKE '%T_WC_WIKIDATA_ITEM_PROPERTY%';

UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_SQL_QUERY = '(?is)\\bLOCATION_ROLE\\s*=\\s*[&#039;&quot;]narrative[&#039;&quot;]',
    TIM_UPDATED = NOW()
WHERE ID_T2S_EVALUATION = 2428
  AND (ASSERTIONS_SQL_QUERY IS NULL OR ASSERTIONS_SQL_QUERY = '');

-- 2429 · List movies shot in Tokyo (filming, by weighted rating)
UPDATE T_WC_T2S_EVALUATION
SET ASSERTION_REFRESH_SQL = 'SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE FROM T_WC_T2S_MOVIE JOIN T_WC_T2S_MOVIE_LOCATION ON T_WC_T2S_MOVIE_LOCATION.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_MOVIE_LOCATION.ID_LOCATION WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = &#039;Q1490&#039; AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_MOVIE_LOCATION.LOCATION_ROLE = &#039;filming&#039; ORDER BY T_WC_T2S_MOVIE.IMDB_RATING_WEIGHTED DESC LIMIT 8',
    LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-17: refresh SQL moved from the Wikidata V1 tables (T_WC_WIKIDATA_ITEM_PROPERTY P915, T_WC_T2S_ITEM label) to the locations read-model, Tokyo named by its QID Q1490, role filming.'),
    TIM_UPDATED = NOW()
WHERE ID_T2S_EVALUATION = 2429
  AND ASSERTION_REFRESH_SQL LIKE '%T_WC_WIKIDATA_ITEM_PROPERTY%';

UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_SQL_QUERY = '(?is)\\bLOCATION_ROLE\\s*=\\s*[&#039;&quot;]filming[&#039;&quot;]',
    TIM_UPDATED = NOW()
WHERE ID_T2S_EVALUATION = 2429
  AND (ASSERTIONS_SQL_QUERY IS NULL OR ASSERTIONS_SQL_QUERY = '');

-- 2435 · List TV series happening in London (narrative, by weighted rating)
UPDATE T_WC_T2S_EVALUATION
SET ASSERTION_REFRESH_SQL = 'SELECT DISTINCT T_WC_T2S_SERIE.ID_SERIE FROM T_WC_T2S_SERIE JOIN T_WC_T2S_SERIE_LOCATION ON T_WC_T2S_SERIE_LOCATION.ID_SERIE = T_WC_T2S_SERIE.ID_SERIE JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_SERIE_LOCATION.ID_LOCATION WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = &#039;Q84&#039; AND T_WC_T2S_LOCATION.DELETED = 0 AND T_WC_T2S_SERIE_LOCATION.LOCATION_ROLE = &#039;narrative&#039; ORDER BY T_WC_T2S_SERIE.IMDB_RATING_WEIGHTED DESC LIMIT 8',
    LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-17: refresh SQL moved from the Wikidata V1 tables (T_WC_WIKIDATA_ITEM_PROPERTY P840, T_WC_T2S_ITEM label) to the locations read-model, London named by its QID Q84, role narrative.'),
    TIM_UPDATED = NOW()
WHERE ID_T2S_EVALUATION = 2435
  AND ASSERTION_REFRESH_SQL LIKE '%T_WC_WIKIDATA_ITEM_PROPERTY%';

UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_SQL_QUERY = '(?is)\\bLOCATION_ROLE\\s*=\\s*[&#039;&quot;]narrative[&#039;&quot;]',
    TIM_UPDATED = NOW()
WHERE ID_T2S_EVALUATION = 2435
  AND (ASSERTIONS_SQL_QUERY IS NULL OR ASSERTIONS_SQL_QUERY = '');

-- 2b · 2429, correction of 2026-10-17: Tokyo is cited under two QIDs, the
--   metropolis Q1490 and the special wards Q7473516, and a film shot in Shinjuku
--   or Shibuya sits under the second. Guarded on the Q1490-only value written above.
UPDATE T_WC_T2S_EVALUATION
SET ASSERTION_REFRESH_SQL = REPLACE(ASSERTION_REFRESH_SQL,
        'T_WC_T2S_LOCATION.ID_WIKIDATA = &#039;Q1490&#039;',
        'T_WC_T2S_LOCATION.ID_WIKIDATA IN (&#039;Q1490&#039;, &#039;Q7473516&#039;)'),
    LONG_DESC = CONCAT(COALESCE(LONG_DESC, ''), ' 2026-10-17, correction: Tokyo is cited under two QIDs, Q1490 (metropolis) and Q7473516 (special wards); the refresh SQL takes both.'),
    TIM_UPDATED = NOW()
WHERE ID_T2S_EVALUATION = 2429
  AND ASSERTION_REFRESH_SQL LIKE '%ID_WIKIDATA = &#039;Q1490&#039;%';

-- ---------------------------------------------------------------------------
-- 3. AFTER. Every ASSERTION_REFRESH_SQL on T_WC_T2S_*_LOCATION, every
--    ASSERTIONS_SQL_QUERY on LOCATION_ROLE. If one still names
--    T_WC_WIKIDATA_ITEM_PROPERTY, its guard withdrew: compare with section 0.
--    Then the ids process 70 will write tonight, to compare with the current
--    ASSERTIONS_QUERY_RESULT of section 0.
-- ---------------------------------------------------------------------------
SELECT '3. After' AS SECTION;

SELECT ID_T2S_EVALUATION,
       ASSERTIONS_SQL_QUERY,
       ASSERTION_REFRESH_SQL
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION IN (2428, 2429, 2435);

SELECT '3a. Preview 2428, Paris narrative' AS SECTION;

SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE, T_WC_T2S_MOVIE.MOVIE_TITLE, T_WC_T2S_MOVIE.POPULARITY
FROM T_WC_T2S_MOVIE
JOIN T_WC_T2S_MOVIE_LOCATION ON T_WC_T2S_MOVIE_LOCATION.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE
JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_MOVIE_LOCATION.ID_LOCATION
WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = 'Q90' AND T_WC_T2S_LOCATION.DELETED = 0
  AND T_WC_T2S_MOVIE_LOCATION.LOCATION_ROLE = 'narrative'
ORDER BY T_WC_T2S_MOVIE.POPULARITY DESC LIMIT 8;

SELECT '3b. Preview 2429, Tokyo filming' AS SECTION;

SELECT DISTINCT T_WC_T2S_MOVIE.ID_MOVIE, T_WC_T2S_MOVIE.MOVIE_TITLE, T_WC_T2S_MOVIE.IMDB_RATING_WEIGHTED
FROM T_WC_T2S_MOVIE
JOIN T_WC_T2S_MOVIE_LOCATION ON T_WC_T2S_MOVIE_LOCATION.ID_MOVIE = T_WC_T2S_MOVIE.ID_MOVIE
JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_MOVIE_LOCATION.ID_LOCATION
WHERE T_WC_T2S_LOCATION.ID_WIKIDATA IN ('Q1490', 'Q7473516') AND T_WC_T2S_LOCATION.DELETED = 0
  AND T_WC_T2S_MOVIE_LOCATION.LOCATION_ROLE = 'filming'
ORDER BY T_WC_T2S_MOVIE.IMDB_RATING_WEIGHTED DESC LIMIT 8;

SELECT '3c. Preview 2435, London narrative' AS SECTION;

SELECT DISTINCT T_WC_T2S_SERIE.ID_SERIE, T_WC_T2S_SERIE.SERIE_TITLE, T_WC_T2S_SERIE.IMDB_RATING_WEIGHTED
FROM T_WC_T2S_SERIE
JOIN T_WC_T2S_SERIE_LOCATION ON T_WC_T2S_SERIE_LOCATION.ID_SERIE = T_WC_T2S_SERIE.ID_SERIE
JOIN T_WC_T2S_LOCATION ON T_WC_T2S_LOCATION.ID_LOCATION = T_WC_T2S_SERIE_LOCATION.ID_LOCATION
WHERE T_WC_T2S_LOCATION.ID_WIKIDATA = 'Q84' AND T_WC_T2S_LOCATION.DELETED = 0
  AND T_WC_T2S_SERIE_LOCATION.LOCATION_ROLE = 'narrative'
ORDER BY T_WC_T2S_SERIE.IMDB_RATING_WEIGHTED DESC LIMIT 8;

-- ---------------------------------------------------------------------------
-- 4. NEXT. Process 70 rewrites the three ASSERTIONS_QUERY_RESULT on its next
--    nightly run (or run the assertion-refresh scope by hand). Then export
--    (phase 31) so data/evaluation/ carries the new refresh SQL.
-- ---------------------------------------------------------------------------
