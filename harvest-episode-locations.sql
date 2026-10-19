-- Harvest for EVALUATIONS-025: the facts the new episode-location evaluations will assert.
--
-- Read-only (SELECT only), voie 1. Written 2026-10-19.
--
-- Since 2026-10-18, T_WC_T2S_EPISODE_LOCATION links single episodes to places. The API
-- (FASTAPI-TEXT2SQL-334, 1.1.19) answers such questions with the SERIES, never the episode,
-- so every assertion of the lot is on ID_SERIE. This file finds, from the data rather than
-- from memory:
--   1. the series with an episode filmed at Arlington National Cemetery;
--   2. the series with an episode set aboard Air Force One, and whether the series itself
--      carries the place (the point of the question is that it does not);
--   3. places cited by episodes only (no movie, no series link), to pick a third question;
--   4. the trap: series set in London at series level, and series that reach London only
--      through an episode (candidate counter-examples for "series set in London").

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 1 and 2. The two named places, every living homonym, with their counts.
-- ---------------------------------------------------------------------------
SELECT '1-2. Arlington and Air Force One' AS SECTION;

SELECT l.ID_LOCATION, l.ID_WIKIDATA, l.LOCATION_NAME, l.LOCATION_NAME_FR, l.LOCATION_TYPE,
       l.MOVIE_COUNT, l.SERIE_COUNT, l.EPISODE_COUNT
FROM T_WC_T2S_LOCATION l
WHERE l.DELETED = 0
  AND (l.LOCATION_NAME LIKE 'Arlington National Cemetery%' OR l.LOCATION_NAME LIKE 'Air Force One%');

SELECT '1-2b. Series reaching them through an episode' AS SECTION;

SELECT l.LOCATION_NAME, el.LOCATION_ROLE, s.ID_SERIE, s.SERIE_TITLE, s.IMDB_RATING_WEIGHTED,
       COUNT(DISTINCT e.ID_EPISODE) AS EPISODES,
       GROUP_CONCAT(DISTINCT CONCAT('S', e.SEASON_NUMBER, 'E', e.EPISODE_NUMBER, ' ', e.EPISODE_TITLE)
                    ORDER BY e.SEASON_NUMBER, e.EPISODE_NUMBER SEPARATOR ' | ') AS WHICH,
       (SELECT GROUP_CONCAT(DISTINCT sl.LOCATION_ROLE) FROM T_WC_T2S_SERIE_LOCATION sl
         WHERE sl.ID_SERIE = s.ID_SERIE AND sl.ID_LOCATION = l.ID_LOCATION
           AND COALESCE(sl.DELETED, 0) = 0) AS SERIE_LEVEL_ROLES
FROM T_WC_T2S_LOCATION l
JOIN T_WC_T2S_EPISODE_LOCATION el ON el.ID_LOCATION = l.ID_LOCATION AND COALESCE(el.DELETED, 0) = 0
JOIN T_WC_T2S_EPISODE e ON e.ID_EPISODE = el.ID_EPISODE AND COALESCE(e.DELETED, 0) = 0
JOIN T_WC_T2S_SERIE s ON s.ID_SERIE = e.ID_SERIE AND COALESCE(s.DELETED, 0) = 0
WHERE l.DELETED = 0
  AND (l.LOCATION_NAME LIKE 'Arlington National Cemetery%' OR l.LOCATION_NAME LIKE 'Air Force One%')
GROUP BY l.LOCATION_NAME, el.LOCATION_ROLE, s.ID_SERIE, s.SERIE_TITLE, s.IMDB_RATING_WEIGHTED, l.ID_LOCATION
ORDER BY l.LOCATION_NAME, el.LOCATION_ROLE, s.IMDB_RATING_WEIGHTED DESC;

-- ---------------------------------------------------------------------------
-- 3. Places cited by episodes only, the best known first.
-- ---------------------------------------------------------------------------
SELECT '3. Episode-only places' AS SECTION;

SELECT l.ID_LOCATION, l.ID_WIKIDATA, l.LOCATION_NAME, l.LOCATION_NAME_FR, l.LOCATION_TYPE,
       l.EPISODE_COUNT,
       COUNT(DISTINCT e.ID_SERIE) AS SERIES,
       GROUP_CONCAT(DISTINCT el.LOCATION_ROLE) AS ROLES,
       SUBSTRING(GROUP_CONCAT(DISTINCT s.SERIE_TITLE ORDER BY s.IMDB_RATING_WEIGHTED DESC SEPARATOR ' | '), 1, 200) AS TOP_SERIES
FROM T_WC_T2S_LOCATION l
JOIN T_WC_T2S_EPISODE_LOCATION el ON el.ID_LOCATION = l.ID_LOCATION AND COALESCE(el.DELETED, 0) = 0
JOIN T_WC_T2S_EPISODE e ON e.ID_EPISODE = el.ID_EPISODE AND COALESCE(e.DELETED, 0) = 0
JOIN T_WC_T2S_SERIE s ON s.ID_SERIE = e.ID_SERIE AND COALESCE(s.DELETED, 0) = 0
WHERE l.DELETED = 0
  AND COALESCE(l.MOVIE_COUNT, 0) = 0 AND COALESCE(l.SERIE_COUNT, 0) = 0
GROUP BY l.ID_LOCATION, l.ID_WIKIDATA, l.LOCATION_NAME, l.LOCATION_NAME_FR, l.LOCATION_TYPE, l.EPISODE_COUNT
HAVING SERIES >= 2
ORDER BY SERIES DESC, l.EPISODE_COUNT DESC
LIMIT 40;

-- ---------------------------------------------------------------------------
-- 4. The trap: "series set in London".
-- ---------------------------------------------------------------------------
SELECT '4a. London homonyms' AS SECTION;

SELECT l.ID_LOCATION, l.ID_WIKIDATA, l.LOCATION_NAME, l.LOCATION_TYPE, l.MOVIE_COUNT, l.SERIE_COUNT, l.EPISODE_COUNT
FROM T_WC_T2S_LOCATION l
WHERE l.DELETED = 0 AND l.LOCATION_NAME = 'London';

SELECT '4b. Series set in London (Q84) at series level, place and contained places' AS SECTION;

SELECT DISTINCT s.ID_SERIE, s.SERIE_TITLE, s.IMDB_RATING_WEIGHTED, a.DEPTH
FROM T_WC_T2S_SERIE s
JOIN T_WC_T2S_SERIE_LOCATION sl ON sl.ID_SERIE = s.ID_SERIE AND COALESCE(sl.DELETED, 0) = 0
JOIN T_WC_T2S_LOCATION_ANCESTOR a ON a.ID_LOCATION = sl.ID_LOCATION
JOIN T_WC_T2S_LOCATION l ON l.ID_LOCATION = a.ID_ANCESTOR
WHERE l.ID_WIKIDATA = 'Q84' AND l.DELETED = 0 AND sl.LOCATION_ROLE = 'narrative'
  AND COALESCE(s.DELETED, 0) = 0
ORDER BY s.IMDB_RATING_WEIGHTED DESC
LIMIT 15;

SELECT '4c. Series reaching London (or a place in it) only through an episode, narrative' AS SECTION;

SELECT s.ID_SERIE, s.SERIE_TITLE, s.IMDB_RATING_WEIGHTED, COUNT(DISTINCT e.ID_EPISODE) AS EPISODES,
       SUBSTRING(GROUP_CONCAT(DISTINCT CONCAT('S', e.SEASON_NUMBER, 'E', e.EPISODE_NUMBER, ' ', e.EPISODE_TITLE) SEPARATOR ' | '), 1, 160) AS WHICH
FROM T_WC_T2S_SERIE s
JOIN T_WC_T2S_EPISODE e ON e.ID_SERIE = s.ID_SERIE AND COALESCE(e.DELETED, 0) = 0
JOIN T_WC_T2S_EPISODE_LOCATION el ON el.ID_EPISODE = e.ID_EPISODE AND COALESCE(el.DELETED, 0) = 0
JOIN T_WC_T2S_LOCATION_ANCESTOR a ON a.ID_LOCATION = el.ID_LOCATION
JOIN T_WC_T2S_LOCATION l ON l.ID_LOCATION = a.ID_ANCESTOR
WHERE l.ID_WIKIDATA = 'Q84' AND l.DELETED = 0 AND el.LOCATION_ROLE = 'narrative'
  AND COALESCE(s.DELETED, 0) = 0
  AND NOT EXISTS (
    SELECT 1 FROM T_WC_T2S_SERIE_LOCATION sl
    JOIN T_WC_T2S_LOCATION_ANCESTOR a2 ON a2.ID_LOCATION = sl.ID_LOCATION
    WHERE sl.ID_SERIE = s.ID_SERIE AND a2.ID_ANCESTOR = l.ID_LOCATION
      AND sl.LOCATION_ROLE = 'narrative' AND COALESCE(sl.DELETED, 0) = 0)
GROUP BY s.ID_SERIE, s.SERIE_TITLE, s.IMDB_RATING_WEIGHTED
ORDER BY s.IMDB_RATING_WEIGHTED DESC
LIMIT 15;

-- ---------------------------------------------------------------------------
-- 5. The evaluations already in the bank on these questions (the guard of the INSERTs).
-- ---------------------------------------------------------------------------
SELECT '5. Existing questions' AS SECTION;

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, LEFT(QUESTION, 80) AS QUESTION
FROM T_WC_T2S_EVALUATION
WHERE DELETED = 0
  AND (QUESTION LIKE '%episode%' AND (QUESTION LIKE '%set%' OR QUESTION LIKE '%film%' OR QUESTION LIKE '%shot%')
       OR QUESTION LIKE '%London%' OR QUESTION LIKE '%Arlington%' OR QUESTION LIKE '%Air Force One%');
