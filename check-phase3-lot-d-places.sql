SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
-- Phase 3 lot D (map of places): the coordinates of every place the phase 3 baseline answers
-- returned (evaluations 2910 to 2915, map; 2919, 2922, 2923, 2926, 2928, hierarchy), 2026-11-14.
-- Read-only, voie 1:
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/check-phase3-lot-d-places.sql
--
-- Purpose: the API reads LATITUDE and LONGITUDE by ID_LOCATION after the query (fastapi-text2sql
-- result_places.py, the columns written by tmdb-movie-preprocess process 72 step 4d since
-- migration-075 of 2026-11-14). It cannot run offline: this file returns, for the places of the
-- baselines, the very columns the API's statement reads, so the session recomputes the answers
-- with the new module and writes the fixtures of both fronts. Then the coverage by type.

SELECT 'places of the baselines' AS SECTION;
SELECT ID_LOCATION, LOCATION_NAME, LOCATION_NAME_FR, LOCATION_TYPE, LATITUDE, LONGITUDE
FROM T_WC_T2S_LOCATION
WHERE ID_LOCATION IN (
  2, 3, 4, 5, 7, 9, 10, 15, 16, 21, 22, 23, 24, 25, 29, 30, 32, 34, 38, 41, 45, 51, 54, 55, 56,
  58, 59, 63, 65, 66, 70, 76, 80, 85, 88, 89, 90, 92, 95, 103, 104, 105, 106, 111, 112, 114, 122,
  123, 126, 135, 136, 146, 148, 150, 154, 158, 159, 162, 163, 174, 176, 177, 190, 194, 202, 211,
  222, 224, 228, 230, 239, 250, 254, 258, 269, 271, 275, 290, 295, 299, 302, 311, 313, 316, 323,
  327, 346, 348, 363, 368, 370, 394, 404, 406, 416, 448, 451, 459, 467, 493, 532, 589, 609, 661,
  677, 810, 879, 1022, 1029, 1064, 1144, 1486, 1505, 1606, 1770, 2205, 2790, 2838, 3130, 3286,
  3359, 3551, 3602, 4558, 4577, 4613, 4637, 4699, 4726, 4752, 4936, 4945, 4971, 5012, 5160, 5237,
  5399, 5433, 5463, 5715, 5935, 5967, 6020, 6177, 6207, 6322, 6404, 6514, 6623, 6704, 6790, 6851,
  6897, 7055, 7400, 7402, 7551, 7645, 7687, 7724, 8300, 8307, 8326, 8390, 8688, 9037, 9267, 9343,
  9516, 9592, 9741, 9844, 10106, 10136, 10317, 10343, 10744, 10759, 11284, 11505, 11537, 11552,
  11617, 11853, 11866, 11879, 11992, 12042, 12174, 12233, 12260, 12313, 13031
)
ORDER BY ID_LOCATION;

SELECT 'coverage of the living places by type' AS SECTION;
SELECT COALESCE(LOCATION_TYPE, '(NULL)') AS LOCATION_TYPE, COUNT(*) AS PLACES,
       SUM(LATITUDE IS NOT NULL AND LONGITUDE IS NOT NULL) AS WITH_COORDINATES
FROM T_WC_T2S_LOCATION WHERE COALESCE(DELETED, 0) = 0
GROUP BY LOCATION_TYPE ORDER BY PLACES DESC;
