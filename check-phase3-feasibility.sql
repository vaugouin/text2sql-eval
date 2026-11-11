-- Phase 3 of the result representations (chain, map, scatter, hierarchy): feasibility on the
-- live data, 2026-11-11. Read-only: SELECT and WITH RECURSIVE only, no write. Voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/check-phase3-feasibility.sql
-- Each block is preceded by a label row and NOW(6), so the result file shows the duration of
-- the heavier ones (the person-path probes in particular).

SELECT 'A0 server' AS block, VERSION() AS mariadb_version, NOW(6) AS t;

-- =========================== MAP ===========================
-- A1. Places by type: how many carry a Wikidata id (the only road to coordinates).
SELECT 'A1 locations by type' AS block, NOW(6) AS t;
SELECT LOCATION_TYPE, COUNT(*) AS places, SUM(ID_WIKIDATA IS NOT NULL AND ID_WIKIDATA <> '') AS with_qid,
       SUM(MOVIE_COUNT > 0) AS with_movies, SUM(SERIE_COUNT > 0) AS with_series
FROM T_WC_T2S_LOCATION WHERE DELETED = 0
GROUP BY LOCATION_TYPE ORDER BY places DESC;

-- A2. Places with a P625 coordinate in the Wikidata statement tables, by type.
SELECT 'A2 locations with P625 coordinate' AS block, NOW(6) AS t;
SELECT l.LOCATION_TYPE, COUNT(DISTINCT l.ID_LOCATION) AS places_with_coordinate
FROM T_WC_T2S_LOCATION l
JOIN T_WC_WIKIDATA_STATEMENT s ON s.ID_WIKIDATA = l.ID_WIKIDATA AND s.ID_PROPERTY = 'P625' AND COALESCE(s.DELETED, 0) = 0
JOIN T_WC_WIKIDATA_COORDINATE_VALUE c ON c.ID_STATEMENT = s.ID_STATEMENT
WHERE l.DELETED = 0 AND c.LATITUDE IS NOT NULL
GROUP BY l.LOCATION_TYPE ORDER BY places_with_coordinate DESC;

-- A3. Movie and series links by role, and how many of those links reach a coordinate.
SELECT 'A3 movie links by role and coordinate coverage' AS block, NOW(6) AS t;
SELECT ml.LOCATION_ROLE, COUNT(*) AS links, COUNT(DISTINCT ml.ID_MOVIE) AS movies,
       SUM(EXISTS (SELECT 1 FROM T_WC_WIKIDATA_STATEMENT s
                   JOIN T_WC_WIKIDATA_COORDINATE_VALUE c ON c.ID_STATEMENT = s.ID_STATEMENT
                   WHERE s.ID_WIKIDATA = l.ID_WIKIDATA AND s.ID_PROPERTY = 'P625' AND COALESCE(s.DELETED, 0) = 0)) AS links_with_coordinate
FROM T_WC_T2S_MOVIE_LOCATION ml
JOIN T_WC_T2S_LOCATION l ON l.ID_LOCATION = ml.ID_LOCATION AND l.DELETED = 0
WHERE COALESCE(ml.DELETED, 0) = 0
GROUP BY ml.LOCATION_ROLE;

SELECT 'A3b series links by role' AS block, NOW(6) AS t;
SELECT sl.LOCATION_ROLE, COUNT(*) AS links, COUNT(DISTINCT sl.ID_SERIE) AS series
FROM T_WC_T2S_SERIE_LOCATION sl WHERE COALESCE(sl.DELETED, 0) = 0 GROUP BY sl.LOCATION_ROLE;

-- A4. Three probe films: their places, type, role and coordinate (what a pin map would draw).
SELECT 'A4 probe films places with coordinates' AS block, NOW(6) AS t;
SELECT m.ID_MOVIE, m.MOVIE_TITLE, m.RELEASE_YEAR, ml.LOCATION_ROLE, l.ID_LOCATION, l.LOCATION_NAME, l.LOCATION_TYPE,
       ROUND(c.LATITUDE, 3) AS lat, ROUND(c.LONGITUDE, 3) AS lon
FROM T_WC_T2S_MOVIE m
JOIN T_WC_T2S_MOVIE_LOCATION ml ON ml.ID_MOVIE = m.ID_MOVIE AND COALESCE(ml.DELETED, 0) = 0
JOIN T_WC_T2S_LOCATION l ON l.ID_LOCATION = ml.ID_LOCATION AND l.DELETED = 0
LEFT JOIN T_WC_WIKIDATA_STATEMENT s ON s.ID_WIKIDATA = l.ID_WIKIDATA AND s.ID_PROPERTY = 'P625' AND COALESCE(s.DELETED, 0) = 0
LEFT JOIN T_WC_WIKIDATA_COORDINATE_VALUE c ON c.ID_STATEMENT = s.ID_STATEMENT
WHERE (m.MOVIE_TITLE = 'Lawrence of Arabia' AND m.RELEASE_YEAR = 1962)
   OR (m.MOVIE_TITLE = 'Inception' AND m.RELEASE_YEAR = 2010)
   OR (m.MOVIE_TITLE = 'The Third Man' AND m.RELEASE_YEAR = 1949)
   OR (m.MOVIE_TITLE = 'Lost in Translation' AND m.RELEASE_YEAR = 2003)
ORDER BY m.ID_MOVIE, ml.LOCATION_ROLE, l.LOCATION_NAME;

-- A5. Production countries: distinct codes, movies covered (a choropleth needs codes only).
SELECT 'A5 production countries' AS block, NOW(6) AS t;
SELECT COUNT(*) AS links, COUNT(DISTINCT ID_MOVIE) AS movies, COUNT(DISTINCT COUNTRY_CODE) AS codes
FROM T_WC_T2S_MOVIE_PRODUCTION_COUNTRY;
SELECT COUNT(*) AS persons, SUM(COUNTRY_OF_BIRTH IS NOT NULL AND COUNTRY_OF_BIRTH <> '') AS with_country_of_birth
FROM T_WC_T2S_PERSON;

-- =========================== HIERARCHY ===========================
-- B1. Companies and their parents (T_WC_T2S_COMPANY.ID_PARENT, in the prompt's schema).
SELECT 'B1 companies with a parent' AS block, NOW(6) AS t;
SELECT COUNT(*) AS companies, SUM(ID_PARENT IS NOT NULL AND ID_PARENT <> 0) AS with_parent,
       SUM(ID_PARENT IS NOT NULL AND ID_PARENT <> 0 AND EXISTS (SELECT 1 FROM T_WC_T2S_COMPANY p WHERE p.ID_COMPANY = c.ID_PARENT)) AS parent_in_table
FROM T_WC_T2S_COMPANY c;

-- B2. Depth of the company trees (WITH RECURSIVE: also tests that the account and the server
-- run a recursive CTE). Root = no parent; depth counted from the root.
SELECT 'B2 company tree depth (recursive CTE)' AS block, NOW(6) AS t;
WITH RECURSIVE tree AS (
  SELECT c.ID_COMPANY, c.ID_COMPANY AS ID_ROOT, 0 AS DEPTH
  FROM T_WC_T2S_COMPANY c
  WHERE (c.ID_PARENT IS NULL OR c.ID_PARENT = 0)
    AND EXISTS (SELECT 1 FROM T_WC_T2S_COMPANY k WHERE k.ID_PARENT = c.ID_COMPANY)
  UNION ALL
  SELECT k.ID_COMPANY, t.ID_ROOT, t.DEPTH + 1
  FROM T_WC_T2S_COMPANY k JOIN tree t ON k.ID_PARENT = t.ID_COMPANY
  WHERE t.DEPTH < 8
)
SELECT DEPTH, COUNT(*) AS companies FROM tree GROUP BY DEPTH ORDER BY DEPTH;

-- B3. The largest company trees (root, descendants, films of the whole tree).
SELECT 'B3 largest company trees' AS block, NOW(6) AS t;
WITH RECURSIVE tree AS (
  SELECT c.ID_COMPANY, c.ID_COMPANY AS ID_ROOT, 0 AS DEPTH
  FROM T_WC_T2S_COMPANY c
  WHERE (c.ID_PARENT IS NULL OR c.ID_PARENT = 0)
    AND EXISTS (SELECT 1 FROM T_WC_T2S_COMPANY k WHERE k.ID_PARENT = c.ID_COMPANY)
  UNION ALL
  SELECT k.ID_COMPANY, t.ID_ROOT, t.DEPTH + 1
  FROM T_WC_T2S_COMPANY k JOIN tree t ON k.ID_PARENT = t.ID_COMPANY
  WHERE t.DEPTH < 8
)
SELECT r.ID_COMPANY, r.COMPANY_NAME, COUNT(*) - 1 AS descendants, MAX(t.DEPTH) AS max_depth,
       SUM(COALESCE(k.MOVIE_COUNT, 0)) AS movies_in_tree
FROM tree t JOIN T_WC_T2S_COMPANY r ON r.ID_COMPANY = t.ID_ROOT
JOIN T_WC_T2S_COMPANY k ON k.ID_COMPANY = t.ID_COMPANY
GROUP BY r.ID_COMPANY, r.COMPANY_NAME ORDER BY descendants DESC LIMIT 15;

-- B4. Children of three probe parents.
SELECT 'B4 probe company children' AS block, NOW(6) AS t;
SELECT p.COMPANY_NAME AS parent, k.ID_COMPANY, k.COMPANY_NAME, k.ORIGIN_COUNTRY, k.MOVIE_COUNT
FROM T_WC_T2S_COMPANY p JOIN T_WC_T2S_COMPANY k ON k.ID_PARENT = p.ID_COMPANY
WHERE p.COMPANY_NAME IN ('Walt Disney Pictures', 'The Walt Disney Company', 'Warner Bros. Pictures', 'Warner Bros. Discovery', 'Universal Pictures', 'Comcast', 'Sony Pictures')
ORDER BY p.COMPANY_NAME, k.MOVIE_COUNT DESC;

-- B5. Place containment (T_WC_T2S_LOCATION_ANCESTOR): depth spread and the chain of one place.
SELECT 'B5 location ancestor depth' AS block, NOW(6) AS t;
SELECT DEPTH, COUNT(*) AS pairs FROM T_WC_T2S_LOCATION_ANCESTOR GROUP BY DEPTH ORDER BY DEPTH;
SELECT 'B5b ancestors of probe places' AS block, NOW(6) AS t;
SELECT l.LOCATION_NAME AS place, a.DEPTH, p.LOCATION_NAME AS ancestor, p.LOCATION_TYPE
FROM T_WC_T2S_LOCATION l
JOIN T_WC_T2S_LOCATION_ANCESTOR a ON a.ID_LOCATION = l.ID_LOCATION
JOIN T_WC_T2S_LOCATION p ON p.ID_LOCATION = a.ID_ANCESTOR
WHERE l.DELETED = 0 AND l.LOCATION_NAME IN ('Eiffel Tower', 'Monument Valley', 'Wadi Rum')
ORDER BY l.LOCATION_NAME, a.DEPTH;

-- B6. Collections: types, sources, and collections nested in a larger one (every movie of A is
-- also in B, B larger): the universe / sub-saga tree the question "the MCU and its phases" wants.
SELECT 'B6 collections by type and source' AS block, NOW(6) AS t;
SELECT COLLECTION_TYPE, COLLECTION_SOURCE, COUNT(*) AS collections, SUM(MOVIE_COUNT) AS movie_links, SUM(SERIE_COUNT) AS serie_links
FROM T_WC_T2S_COLLECTION WHERE COALESCE(DELETED, 0) = 0
GROUP BY COLLECTION_TYPE, COLLECTION_SOURCE ORDER BY collections DESC;

SELECT 'B6b nested collections (A inside B)' AS block, NOW(6) AS t;
SELECT COUNT(*) AS nested_pairs, COUNT(DISTINCT x.ID_INNER) AS inner_collections, COUNT(DISTINCT x.ID_OUTER) AS outer_collections
FROM (
  SELECT a.ID_T2S_COLLECTION AS ID_INNER, b.ID_T2S_COLLECTION AS ID_OUTER, COUNT(*) AS shared, ca.N AS n_inner, cb.N AS n_outer
  FROM T_WC_T2S_MOVIE_COLLECTION a
  JOIN T_WC_T2S_MOVIE_COLLECTION b ON b.ID_MOVIE = a.ID_MOVIE AND b.ID_T2S_COLLECTION <> a.ID_T2S_COLLECTION AND COALESCE(b.DELETED, 0) = 0
  JOIN (SELECT ID_T2S_COLLECTION, COUNT(*) AS N FROM T_WC_T2S_MOVIE_COLLECTION WHERE COALESCE(DELETED, 0) = 0 GROUP BY ID_T2S_COLLECTION) ca ON ca.ID_T2S_COLLECTION = a.ID_T2S_COLLECTION
  JOIN (SELECT ID_T2S_COLLECTION, COUNT(*) AS N FROM T_WC_T2S_MOVIE_COLLECTION WHERE COALESCE(DELETED, 0) = 0 GROUP BY ID_T2S_COLLECTION) cb ON cb.ID_T2S_COLLECTION = b.ID_T2S_COLLECTION
  WHERE COALESCE(a.DELETED, 0) = 0 AND ca.N >= 2
  GROUP BY a.ID_T2S_COLLECTION, b.ID_T2S_COLLECTION, ca.N, cb.N
  HAVING shared = n_inner AND n_outer > n_inner
) x;

SELECT 'B6c collections nested in probe universes' AS block, NOW(6) AS t;
SELECT o.COLLECTION_NAME AS outer_collection, i.ID_T2S_COLLECTION, i.COLLECTION_NAME AS inner_collection, x.n_inner, x.n_outer
FROM (
  SELECT a.ID_T2S_COLLECTION AS ID_INNER, b.ID_T2S_COLLECTION AS ID_OUTER, COUNT(*) AS shared, ca.N AS n_inner, cb.N AS n_outer
  FROM T_WC_T2S_MOVIE_COLLECTION a
  JOIN T_WC_T2S_MOVIE_COLLECTION b ON b.ID_MOVIE = a.ID_MOVIE AND b.ID_T2S_COLLECTION <> a.ID_T2S_COLLECTION AND COALESCE(b.DELETED, 0) = 0
  JOIN (SELECT ID_T2S_COLLECTION, COUNT(*) AS N FROM T_WC_T2S_MOVIE_COLLECTION WHERE COALESCE(DELETED, 0) = 0 GROUP BY ID_T2S_COLLECTION) ca ON ca.ID_T2S_COLLECTION = a.ID_T2S_COLLECTION
  JOIN (SELECT ID_T2S_COLLECTION, COUNT(*) AS N FROM T_WC_T2S_MOVIE_COLLECTION WHERE COALESCE(DELETED, 0) = 0 GROUP BY ID_T2S_COLLECTION) cb ON cb.ID_T2S_COLLECTION = b.ID_T2S_COLLECTION
  WHERE COALESCE(a.DELETED, 0) = 0 AND ca.N >= 2
  GROUP BY a.ID_T2S_COLLECTION, b.ID_T2S_COLLECTION, ca.N, cb.N
  HAVING shared = n_inner AND n_outer > n_inner
) x
JOIN T_WC_T2S_COLLECTION o ON o.ID_T2S_COLLECTION = x.ID_OUTER
JOIN T_WC_T2S_COLLECTION i ON i.ID_T2S_COLLECTION = x.ID_INNER
WHERE o.COLLECTION_NAME IN ('Marvel Cinematic Universe', 'Star Wars', 'Middle-earth', 'Middle-Earth', 'DC Extended Universe', 'Wizarding World', 'James Bond films', 'Batman universe', 'MonsterVerse', 'Alien')
ORDER BY o.COLLECTION_NAME, x.n_inner DESC;

-- B7. Series, seasons and episodes (the "seasons and episodes" hierarchy).
SELECT 'B7 seasons and episodes' AS block, NOW(6) AS t;
SELECT (SELECT COUNT(*) FROM T_WC_T2S_SEASON WHERE COALESCE(DELETED, 0) = 0) AS seasons,
       (SELECT COUNT(*) FROM T_WC_T2S_EPISODE WHERE COALESCE(DELETED, 0) = 0) AS episodes,
       (SELECT COUNT(DISTINCT ID_SERIE) FROM T_WC_T2S_EPISODE WHERE COALESCE(DELETED, 0) = 0) AS series_with_episodes;

-- B8. Wikidata subclass graph (genres and classes), loaded but not in the prompt.
SELECT 'B8 wikidata subclass rows' AS block, NOW(6) AS t;
SELECT COUNT(*) AS subclass_edges, COUNT(DISTINCT ID_CHILD) AS children, COUNT(DISTINCT ID_PARENT) AS parents
FROM T_WC_WIKIDATA_SUBCLASS WHERE COALESCE(DELETED, 0) = 0;
SELECT 'B8b tmdb genres (flat)' AS block, NOW(6) AS t;
SELECT COUNT(*) AS genres FROM T_WC_T2S_GENRE;

-- =========================== CHAIN ===========================
-- C1. Source works: by type, and how many point back to a movie or a series of the base
-- (the remake edge: movie -> source work that is itself a movie).
SELECT 'C1 source works by type' AS block, NOW(6) AS t;
SELECT SOURCE_WORK_TYPE, COUNT(*) AS works, SUM(ID_MOVIE IS NOT NULL) AS is_a_movie, SUM(ID_SERIE IS NOT NULL) AS is_a_serie,
       SUM(COALESCE(MOVIE_COUNT, 0)) AS adaptations_movies
FROM T_WC_T2S_SOURCE_WORK WHERE COALESCE(DELETED, 0) = 0
GROUP BY SOURCE_WORK_TYPE ORDER BY works DESC;

-- C2. Remake chains: depth of movie -> movie (via a source work with ID_MOVIE), recursive.
SELECT 'C2 remake chain depth (recursive CTE)' AS block, NOW(6) AS t;
WITH RECURSIVE edge AS (
  SELECT msw.ID_MOVIE AS ID_CHILD, sw.ID_MOVIE AS ID_PARENT
  FROM T_WC_T2S_MOVIE_SOURCE_WORK msw
  JOIN T_WC_T2S_SOURCE_WORK sw ON sw.ID_SOURCE_WORK = msw.ID_SOURCE_WORK AND COALESCE(sw.DELETED, 0) = 0
  WHERE COALESCE(msw.DELETED, 0) = 0 AND sw.ID_MOVIE IS NOT NULL AND sw.ID_MOVIE <> msw.ID_MOVIE
),
chain AS (
  SELECT e.ID_CHILD AS ID_START, e.ID_PARENT AS ID_AT, 1 AS HOPS FROM edge e
  UNION ALL
  SELECT c.ID_START, e.ID_PARENT, c.HOPS + 1 FROM chain c JOIN edge e ON e.ID_CHILD = c.ID_AT WHERE c.HOPS < 6
)
SELECT HOPS, COUNT(*) AS paths FROM chain GROUP BY HOPS ORDER BY HOPS;

-- C3. The longest remake chains, start and end (the probes for the chain evaluations).
SELECT 'C3 longest remake chains' AS block, NOW(6) AS t;
WITH RECURSIVE edge AS (
  SELECT msw.ID_MOVIE AS ID_CHILD, sw.ID_MOVIE AS ID_PARENT
  FROM T_WC_T2S_MOVIE_SOURCE_WORK msw
  JOIN T_WC_T2S_SOURCE_WORK sw ON sw.ID_SOURCE_WORK = msw.ID_SOURCE_WORK AND COALESCE(sw.DELETED, 0) = 0
  WHERE COALESCE(msw.DELETED, 0) = 0 AND sw.ID_MOVIE IS NOT NULL AND sw.ID_MOVIE <> msw.ID_MOVIE
),
chain AS (
  SELECT e.ID_CHILD AS ID_START, e.ID_PARENT AS ID_AT, 1 AS HOPS FROM edge e
  UNION ALL
  SELECT c.ID_START, e.ID_PARENT, c.HOPS + 1 FROM chain c JOIN edge e ON e.ID_CHILD = c.ID_AT WHERE c.HOPS < 6
)
SELECT c.HOPS, s.ID_MOVIE AS id_start, s.MOVIE_TITLE AS start_title, s.RELEASE_YEAR AS start_year,
       a.ID_MOVIE AS id_end, a.MOVIE_TITLE AS end_title, a.RELEASE_YEAR AS end_year, s.IMDB_VOTES
FROM chain c JOIN T_WC_T2S_MOVIE s ON s.ID_MOVIE = c.ID_START JOIN T_WC_T2S_MOVIE a ON a.ID_MOVIE = c.ID_AT
WHERE c.HOPS >= 2
ORDER BY c.HOPS DESC, s.IMDB_VOTES DESC LIMIT 25;

-- C4. Probe remakes and their full source lists (movie, its sources, the source's own sources).
SELECT 'C4 probe adaptation chains' AS block, NOW(6) AS t;
SELECT m.ID_MOVIE, m.MOVIE_TITLE, m.RELEASE_YEAR, sw.ID_SOURCE_WORK, sw.SOURCE_WORK_NAME, sw.SOURCE_WORK_TYPE, sw.SOURCE_WORK_YEAR, sw.ID_MOVIE AS source_is_movie
FROM T_WC_T2S_MOVIE m
JOIN T_WC_T2S_MOVIE_SOURCE_WORK msw ON msw.ID_MOVIE = m.ID_MOVIE AND COALESCE(msw.DELETED, 0) = 0
JOIN T_WC_T2S_SOURCE_WORK sw ON sw.ID_SOURCE_WORK = msw.ID_SOURCE_WORK AND COALESCE(sw.DELETED, 0) = 0
WHERE (m.MOVIE_TITLE = 'A Star Is Born' )
   OR (m.MOVIE_TITLE = 'Scarface' AND m.RELEASE_YEAR IN (1932, 1983))
   OR (m.MOVIE_TITLE = 'A Fistful of Dollars')
   OR (m.MOVIE_TITLE = 'Yojimbo')
   OR (m.MOVIE_TITLE = 'The Magnificent Seven' )
   OR (m.MOVIE_TITLE = 'Last Man Standing' AND m.RELEASE_YEAR = 1996)
   OR (m.MOVIE_TITLE = 'Infernal Affairs')
   OR (m.MOVIE_TITLE = 'The Departed')
   OR (m.MOVIE_TITLE = 'Nosferatu')
ORDER BY m.MOVIE_TITLE, m.RELEASE_YEAR;

-- C5. Wikidata properties a chain or a hierarchy would need, as loaded in the statement table:
-- P144 based on, P155 follows, P156 followed by, P737 influenced by, P4969 derivative work,
-- P749 parent organization, P355 subsidiary, P361 part of, P527 has part, P179 part of the series,
-- P625 coordinate, P915 filming location, P840 narrative location.
SELECT 'C5 wikidata properties loaded' AS block, NOW(6) AS t;
SELECT ID_PROPERTY, COUNT(*) AS statements
FROM T_WC_WIKIDATA_STATEMENT
WHERE ID_PROPERTY IN ('P144', 'P155', 'P156', 'P737', 'P4969', 'P749', 'P355', 'P361', 'P527', 'P179', 'P625', 'P915', 'P840')
  AND COALESCE(DELETED, 0) = 0
GROUP BY ID_PROPERTY ORDER BY ID_PROPERTY;

-- C6. Sequels in Wikidata between two movies of the base (P156 followed by).
SELECT 'C6 P155 and P156 between movies of the base' AS block, NOW(6) AS t;
SELECT s.ID_PROPERTY, COUNT(*) AS edges
FROM T_WC_T2S_MOVIE m
JOIN T_WC_WIKIDATA_STATEMENT s ON s.ID_WIKIDATA = m.ID_WIKIDATA AND s.ID_PROPERTY IN ('P155', 'P156') AND COALESCE(s.DELETED, 0) = 0
JOIN T_WC_WIKIDATA_ITEM_VALUE v ON v.ID_STATEMENT = s.ID_STATEMENT
JOIN T_WC_T2S_MOVIE m2 ON m2.ID_WIKIDATA = v.ID_ITEM
GROUP BY s.ID_PROPERTY;

-- C7. Person paths. Credits volume, then a degree-1 and a degree-2 probe with their timing.
SELECT 'C7 person credits volume' AS block, NOW(6) AS t;
SELECT COUNT(*) AS movie_credits, COUNT(DISTINCT ID_PERSON) AS persons, COUNT(DISTINCT ID_MOVIE) AS movies FROM T_WC_T2S_PERSON_MOVIE;

SELECT 'C7b degree 1: films shared by Toshiro Mifune and Takashi Shimura' AS block, NOW(6) AS t;
SELECT m.ID_MOVIE, m.MOVIE_TITLE, m.RELEASE_YEAR
FROM T_WC_T2S_PERSON a JOIN T_WC_T2S_PERSON_MOVIE pa ON pa.ID_PERSON = a.ID_PERSON
JOIN T_WC_T2S_PERSON_MOVIE pb ON pb.ID_MOVIE = pa.ID_MOVIE
JOIN T_WC_T2S_PERSON b ON b.ID_PERSON = pb.ID_PERSON
JOIN T_WC_T2S_MOVIE m ON m.ID_MOVIE = pa.ID_MOVIE
WHERE a.PERSON_NAME = 'Toshiro Mifune' AND b.PERSON_NAME = 'Takashi Shimura' AND pa.CREDIT_TYPE = 'cast' AND pb.CREDIT_TYPE = 'cast'
GROUP BY m.ID_MOVIE, m.MOVIE_TITLE, m.RELEASE_YEAR ORDER BY m.RELEASE_YEAR LIMIT 30;

SELECT 'C7c degree 2: Kevin Bacon to Toshiro Mifune through one co-star, cast only' AS block, NOW(6) AS t;
SELECT x.ID_PERSON, x.PERSON_NAME, MIN(m1.MOVIE_TITLE) AS film_with_bacon, MIN(m2.MOVIE_TITLE) AS film_with_mifune
FROM T_WC_T2S_PERSON a
JOIN T_WC_T2S_PERSON_MOVIE p1 ON p1.ID_PERSON = a.ID_PERSON AND p1.CREDIT_TYPE = 'cast'
JOIN T_WC_T2S_PERSON_MOVIE px1 ON px1.ID_MOVIE = p1.ID_MOVIE AND px1.CREDIT_TYPE = 'cast' AND px1.ID_PERSON <> a.ID_PERSON
JOIN T_WC_T2S_PERSON_MOVIE px2 ON px2.ID_PERSON = px1.ID_PERSON AND px2.CREDIT_TYPE = 'cast' AND px2.ID_MOVIE <> px1.ID_MOVIE
JOIN T_WC_T2S_PERSON_MOVIE p2 ON p2.ID_MOVIE = px2.ID_MOVIE AND p2.CREDIT_TYPE = 'cast'
JOIN T_WC_T2S_PERSON b ON b.ID_PERSON = p2.ID_PERSON
JOIN T_WC_T2S_PERSON x ON x.ID_PERSON = px1.ID_PERSON
JOIN T_WC_T2S_MOVIE m1 ON m1.ID_MOVIE = p1.ID_MOVIE
JOIN T_WC_T2S_MOVIE m2 ON m2.ID_MOVIE = p2.ID_MOVIE
WHERE a.PERSON_NAME = 'Kevin Bacon' AND b.PERSON_NAME = 'Toshiro Mifune'
GROUP BY x.ID_PERSON, x.PERSON_NAME ORDER BY x.PERSON_NAME LIMIT 20;
SELECT 'C7c end' AS block, NOW(6) AS t;

-- =========================== SCATTER ===========================
-- D1. Coverage of the quantities a scatter pairs, on all movies and on films with 1,000 votes.
SELECT 'D1 scatter coverage' AS block, NOW(6) AS t;
SELECT 'all movies' AS scope, COUNT(*) AS movies,
       SUM(BUDGET > 0) AS budget, SUM(REVENUE > 0) AS revenue, SUM(BUDGET > 0 AND REVENUE > 0) AS budget_and_revenue,
       SUM(IMDB_RATING IS NOT NULL) AS imdb_rating, SUM(RUNTIME > 0) AS runtime, SUM(RELEASE_YEAR IS NOT NULL) AS year,
       SUM(BUDGET > 0 AND IMDB_RATING IS NOT NULL) AS budget_and_rating
FROM T_WC_T2S_MOVIE WHERE COALESCE(DELETED, 0) = 0
UNION ALL
SELECT 'IMDB_VOTES >= 1000', COUNT(*),
       SUM(BUDGET > 0), SUM(REVENUE > 0), SUM(BUDGET > 0 AND REVENUE > 0),
       SUM(IMDB_RATING IS NOT NULL), SUM(RUNTIME > 0), SUM(RELEASE_YEAR IS NOT NULL),
       SUM(BUDGET > 0 AND IMDB_RATING IS NOT NULL)
FROM T_WC_T2S_MOVIE WHERE COALESCE(DELETED, 0) = 0 AND IMDB_VOTES >= 1000;

-- D2. Probe directors: how many of their films carry budget and revenue (a scatter of 3 points
-- is not worth a chart).
SELECT 'D2 probe directors budget and revenue coverage' AS block, NOW(6) AS t;
SELECT p.PERSON_NAME, COUNT(DISTINCT m.ID_MOVIE) AS films,
       COUNT(DISTINCT CASE WHEN m.BUDGET > 0 AND m.REVENUE > 0 THEN m.ID_MOVIE END) AS with_budget_and_revenue,
       COUNT(DISTINCT CASE WHEN m.RUNTIME > 0 AND m.IMDB_RATING IS NOT NULL THEN m.ID_MOVIE END) AS with_runtime_and_rating
FROM T_WC_T2S_PERSON p
JOIN T_WC_T2S_PERSON_MOVIE pm ON pm.ID_PERSON = p.ID_PERSON AND pm.CREDIT_TYPE = 'crew' AND pm.CREW_JOB = 'Director'
JOIN T_WC_T2S_MOVIE m ON m.ID_MOVIE = pm.ID_MOVIE AND COALESCE(m.DELETED, 0) = 0 AND m.IS_MOVIE = 1
WHERE p.PERSON_NAME IN ('Christopher Nolan', 'Steven Spielberg', 'James Cameron', 'Alfred Hitchcock', 'Stanley Kubrick', 'Quentin Tarantino', 'Ridley Scott', 'Hayao Miyazaki', 'Martin Scorsese', 'Akira Kurosawa')
GROUP BY p.PERSON_NAME ORDER BY p.PERSON_NAME;

SELECT 'END' AS block, NOW(6) AS t;
