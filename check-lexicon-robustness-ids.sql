-- Ids and titles behind new-evaluations-lexicon-robustness.sql (FASTAPI-TEXT2SQL-360, -363,
-- -366), checked before the insert. Read-only. 2026-11-05.
-- The ids come from direct calls to Blue 1.1.20 (cache off) on the tricky title wordings.

SELECT NOW() AS NOW_;

SELECT ID_MOVIE, MOVIE_TITLE, MOVIE_TITLE_FR, ORIGINAL_TITLE, RELEASE_YEAR, IMDB_VOTES
  FROM T_WC_T2S_MOVIE
 WHERE ID_MOVIE IN (11, 238, 424, 680, 807, 1891, 10681, 14160, 346364)
 ORDER BY ID_MOVIE;

SELECT ID_SERIE, SERIE_TITLE, SERIE_TITLE_FR, ORIGINAL_TITLE, FIRST_AIR_YEAR
  FROM T_WC_T2S_SERIE
 WHERE ID_SERIE IN (2316, 126308)
 ORDER BY ID_SERIE;

-- Les Visiteurs and its sequels: the sequel the wording means, and the 1993 film and the
-- 1972 'The Visitors' the ChromaDB fallback served instead.
SELECT ID_MOVIE, MOVIE_TITLE, MOVIE_TITLE_FR, ORIGINAL_TITLE, RELEASE_YEAR, IMDB_VOTES
  FROM T_WC_T2S_MOVIE
 WHERE (MOVIE_TITLE_FR LIKE '%Visiteurs%' OR ORIGINAL_TITLE LIKE '%Visiteurs%' OR MOVIE_TITLE = 'The Visitors')
   AND IMDB_VOTES >= 500
 ORDER BY RELEASE_YEAR;

-- Title aliases of Star Wars (11) and The Empire Strikes Back (1891): which form the alias
-- tier matched, and whether any carries "episode IV" or "épisode 4".
SELECT ID_MOVIE, TITLE, LANG_CODE, ALIAS_SOURCE
  FROM T_WC_T2S_MOVIE_TITLE_ALIAS
 WHERE ID_MOVIE IN (11, 1891)
 ORDER BY ID_MOVIE, LANG_CODE, TITLE;
