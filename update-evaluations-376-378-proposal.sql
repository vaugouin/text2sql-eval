-- PROPOSAL, NOT RUN: assertion changes on existing evaluations, for Philippe to accept or drop (2026-11-11).
--
-- Why. FASTAPI-TEXT2SQL-376 and -378 are measured today only by the out-of-score result_shape of the
-- sequence and trend evaluations. The scored query_result of 2601 to 2609 is an IN list, which a
-- query ordered by rating passes (2601 and 2604 did, on 1.1.20, as a UNION ordered by
-- IMDB_RATING_WEIGHTED DESC); the scored side of 2611, 2613, 2617 and 2619 is a COUNT floor, which a
-- trend running to 2099 passes. This file would put the order and the current-year cap into the score:
--   Part A: 2601 to 2604 and 2606 to 2609 gain CELL(0, 0) == <the first work by date> (the id column
--           is the first column of every result contract, ID_CONTENT on a UNION). 2605 is left out:
--           Kubrick's early shorts may legitimately come before Fear and Desire. 2600 has its CELL already.
--   Part B: 2611, 2613, 2617 and 2619 gain the ASSERTIONS_SQL_QUERY regex of 2836 to 2838 (the year
--           column closed at YEAR(CURDATE())), set only where the column is empty today.
-- Measured offline on the latest 1.1.20 exports (2026-11-08): Part A turns 2604 red in both languages
-- (Red first, the rating order), and nothing else: for The Godfather the rating order and the date
-- order coincide, so 2601 stays green and its order is only checked by its result_shape. Part B turns
-- 2611, 2613, 2617 and 2619 red in both languages (no upper bound in any of their SQL).
-- Changing an assertion changes what past campaigns would have scored: Phase 20 alone rescores
-- offline, at no token cost. Each UPDATE is guarded on the exact current value, so a re-run does
-- nothing and an edit made in between withdraws it.
--
-- ROUTING if accepted: UPDATEs on T_WC_T2S_EVALUATION only: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/update-evaluations-376-378-proposal.sql

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Part A: the order of the sequences, in the score

-- 2601: The Godfather (1972) first
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_QUERY_RESULT = 'CELL(0, 0) == 238 AND ID_MOVIE IN (238, 240, 242)', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2601 AND ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (238, 240, 242)';

-- 2602: Raiders of the Lost Ark (1981) first
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_QUERY_RESULT = 'CELL(0, 0) == 85 AND ID_MOVIE IN (85, 87, 89, 217, 335977)', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2602 AND ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (85, 87, 89, 217, 335977)';

-- 2603: A Fistful of Dollars (1964) first
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_QUERY_RESULT = 'CELL(0, 0) == 391 AND ID_MOVIE IN (391, 938, 429)', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2603 AND ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (391, 938, 429)';

-- 2604: Three Colors: Blue (1993) first
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_QUERY_RESULT = 'CELL(0, 0) == 108 AND ID_MOVIE IN (108, 109, 110)', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2604 AND ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (108, 109, 110)';

-- 2606: The Matrix (1999) first
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_QUERY_RESULT = 'CELL(0, 0) == 603 AND ID_MOVIE IN (603, 604, 605, 624860)', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2606 AND ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (603, 604, 605, 624860)';

-- 2607: Before Sunrise (1995) first
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_QUERY_RESULT = 'CELL(0, 0) == 76 AND ID_MOVIE IN (76, 80, 132344)', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2607 AND ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (76, 80, 132344)';

-- 2608: Toy Story (1995) first
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_QUERY_RESULT = 'CELL(0, 0) == 862 AND ID_MOVIE IN (862, 863, 10193, 301528, 1084244)', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2608 AND ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (862, 863, 10193, 301528, 1084244)';

-- 2609: Rocky (1976) first
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_QUERY_RESULT = 'CELL(0, 0) == 1366 AND ID_MOVIE IN (1366, 1367, 1371, 1374, 1375, 1246)', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2609 AND ASSERTIONS_QUERY_RESULT = 'ID_MOVIE IN (1366, 1367, 1371, 1374, 1375, 1246)';

-- Part B: the current-year cap of the trends, in the score
UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_SQL_QUERY = '(?is)\\bRELEASE_YEAR\\s*(?:<=|<|BETWEEN\\s+\\S+\\s+AND)\\s*YEAR\\s*\\(\\s*(?:CURDATE|CURRENT_DATE|NOW)', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2611 AND (ASSERTIONS_SQL_QUERY IS NULL OR ASSERTIONS_SQL_QUERY = '');

UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_SQL_QUERY = '(?is)\\bFIRST_AIR_YEAR\\s*(?:<=|<|BETWEEN\\s+\\S+\\s+AND)\\s*YEAR\\s*\\(\\s*(?:CURDATE|CURRENT_DATE|NOW)', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2613 AND (ASSERTIONS_SQL_QUERY IS NULL OR ASSERTIONS_SQL_QUERY = '');

UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_SQL_QUERY = '(?is)\\bRELEASE_YEAR\\s*(?:<=|<|BETWEEN\\s+\\S+\\s+AND)\\s*YEAR\\s*\\(\\s*(?:CURDATE|CURRENT_DATE|NOW)', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2617 AND (ASSERTIONS_SQL_QUERY IS NULL OR ASSERTIONS_SQL_QUERY = '');

UPDATE T_WC_T2S_EVALUATION SET ASSERTIONS_SQL_QUERY = '(?is)\\bRELEASE_YEAR\\s*(?:<=|<|BETWEEN\\s+\\S+\\s+AND)\\s*YEAR\\s*\\(\\s*(?:CURDATE|CURRENT_DATE|NOW)', TIM_UPDATED = NOW(), ID_USER_UPDATED = 1
  WHERE ID_T2S_EVALUATION = 2619 AND (ASSERTIONS_SQL_QUERY IS NULL OR ASSERTIONS_SQL_QUERY = '');

-- Read-back
SELECT ID_T2S_EVALUATION, LEFT(QUESTION, 60) AS QUESTION, ASSERTIONS_QUERY_RESULT, ASSERTIONS_SQL_QUERY
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION IN (2601, 2602, 2603, 2604, 2606, 2607, 2608, 2609, 2611, 2613, 2617, 2619)
ORDER BY ID_T2S_EVALUATION;
