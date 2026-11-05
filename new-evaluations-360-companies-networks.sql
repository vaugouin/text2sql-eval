-- New evaluations for FASTAPI-TEXT2SQL-360, second wave: companies and networks, before their
-- move from ChromaDB to the RapidFuzz lexicon. 10 evaluations, English and French, category 7
-- (the category of "Company a24", "Production company Pixar", "Network Netflix"). Written 2026-11-05.
--
-- WHY
-- The offline bench (fastapi-text2sql checks/bench-lexical-360-names.py) found the bank barely asks
-- for companies and networks: 11 and 4 distinct mentions over every campaign and 28,444 API logs.
-- House rule of 2026-10-31: the questions go in before the change, the campaign on 1.1.20 is the
-- baseline. Each one targets a trap the bench showed: a legal tail left out ("Paramount" for
-- Paramount Pictures), an exact homonym with few credits (Paramount+, Columbia), several entities
-- with the same name (Gaumont, HBO, Canal+), a mention production rejects today (Warner Bros,
-- Hammer), a typo.
--
-- THE IDS ARE READ, NOT REMEMBERED
-- From the pool exported by fastapi-text2sql doc/sql/check-360-export-name-pool.sql on 2026-11-05
-- (names.tsv), credits = MOVIE_COUNT + SERIE_COUNT; section 1 prints them again live.
--
-- WHAT THE ASSERTIONS PROTECT
-- COUNT(*) > 0 (floor) AND ID_COMPANY / ID_NETWORK IN (...), as 24 (Pixar) and 25 (Netflix).
-- No ASSERTION_REFRESH_SQL. ASSERTIONS_ENTITY_EXTRACTION left NULL.
--
-- RE-RUN GUARD: INSERT ... SELECT guarded by NOT EXISTS on the English question, in a derived
-- table (MySQL error 1093). Voie 1 (T_WC_T2S_EVALUATION is writable by the agent).
-- Then phase 31 to refresh the JSON export, and phases 11 + 20 to run and score them.

-- 0. Pre-flight: must return zero rows.
SELECT ID_T2S_EVALUATION, LEFT(QUESTION, 70) AS QUESTION
FROM T_WC_T2S_EVALUATION
WHERE QUESTION IN ('Production company Paramount', 'Production company Columbia', 'Production company Warner Bros', 'Production company Universal', 'Production company Hammer', 'Production company Gaumont', 'Production company Toho', 'Production company Paramout Pictures', 'Network HBO', 'Network Canal+');

-- 1. The expected entities, live.
SELECT ID_COMPANY, COMPANY_NAME, MOVIE_COUNT, SERIE_COUNT
FROM T_WC_T2S_COMPANY WHERE ID_COMPANY IN (4, 5, 9, 33, 174, 882, 1314);
SELECT ID_NETWORK, NETWORK_NAME, SERIE_COUNT
FROM T_WC_T2S_NETWORK WHERE ID_NETWORK IN (49, 285);

-- 2. The evaluations.
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Production company Paramount',
       'Société de production Paramount',
       1, 0, 7, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_COMPANY IN (4)',
       'Paramount Pictures (TMDb company 4, 2,899 movie and series credits). Legal tail dropped, and an exact homonym trap: the company Paramount+ (314668, 3 credits) folds to the same key once the plus sign goes. Ranking by credits must pick 4 (FASTAPI-TEXT2SQL-360, second wave).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Production company Paramount') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Production company Columbia',
       'Société de production Columbia',
       1, 0, 7, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_COMPANY IN (5)',
       'Columbia Pictures (TMDb company 5, 2,980 credits). An exact homonym exists, Columbia (102846, 3 credits): a full-name-first rule would return it (FASTAPI-TEXT2SQL-360, second wave).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Production company Columbia') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Production company Warner Bros',
       'Société de production Warner Bros',
       1, 0, 7, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_COMPANY IN (174)',
       'Warner Bros. Pictures (TMDb company 174, 3,104 credits). Production rejected this mention in the logs (ChromaDB offered Warner Bros. Entertainment under the gate); the lexicon finds it once the legal tail is folded (FASTAPI-TEXT2SQL-360, second wave).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Production company Warner Bros') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Production company Universal',
       'Société de production Universal',
       1, 0, 7, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_COMPANY IN (33)',
       'Universal Pictures (TMDb company 33, 2,683 credits). Homonym traps: Universal+ (folds to the same key), Universal Television, a one-credit Universal Pictures (313310) (FASTAPI-TEXT2SQL-360, second wave).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Production company Universal') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Production company Hammer',
       'Société de production Hammer',
       1, 0, 7, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_COMPANY IN (1314)',
       'Hammer Film Productions (TMDb company 1314, 219 credits). Production rejected this mention in the logs (ChromaDB offered Good Hammer); the lexicon finds it by the stripped form (FASTAPI-TEXT2SQL-360, second wave).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Production company Hammer') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Production company Gaumont',
       'Société de production Gaumont',
       1, 0, 7, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_COMPANY IN (9)',
       'Gaumont (TMDb company 9, 665 credits). Four companies are named exactly Gaumont (206133, 130675, 202617 with 13 credits or fewer): ranking by credits must pick 9 (FASTAPI-TEXT2SQL-360, second wave).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Production company Gaumont') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Production company Toho',
       'Société de production Toho',
       1, 0, 7, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_COMPANY IN (882)',
       'TOHO (TMDb company 882, 2,079 credits), stored in capitals; Toho Pictures and Toho Studios are other companies (FASTAPI-TEXT2SQL-360, second wave).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Production company Toho') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Production company Paramout Pictures',
       'Société de production Paramout Pictures',
       1, 0, 7, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_COMPANY IN (4)',
       'Typo of Paramount Pictures (TMDb company 4): one letter missing, the approximate search must still land on 4 and not on a closer obscure name (FASTAPI-TEXT2SQL-360, second wave; the company fuzzy gate of 77.5 is under review).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Production company Paramout Pictures') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Network HBO',
       'Chaîne HBO',
       1, 0, 7, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_NETWORK IN (49)',
       'HBO (TMDb network 49, 362 series). Four networks are named exactly HBO; production returned 1590 (6 series) in the logs of 2026, the lexicon ranks 49 first by series count (FASTAPI-TEXT2SQL-360, second wave).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Network HBO') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Network Canal+',
       'Chaîne Canal+',
       1, 0, 7, 0, CURDATE(), NOW(),
       'COUNT(*) &gt; 0 AND ID_NETWORK IN (285)',
       'Canal+ (TMDb network 285, 275 series). Four networks are named exactly Canal+ (951, 3928, 7021 with 37 series or fewer), and the plus sign disappears in normalization (FASTAPI-TEXT2SQL-360, second wave).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Network Canal+') AS existing);

-- 3. Post-flight: ten rows, each with its assertion.
SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, LEFT(QUESTION, 40) AS QUESTION,
       LEFT(QUESTION_FR, 40) AS QUESTION_FR, ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION
WHERE QUESTION IN ('Production company Paramount', 'Production company Columbia', 'Production company Warner Bros', 'Production company Universal', 'Production company Hammer', 'Production company Gaumont', 'Production company Toho', 'Production company Paramout Pictures', 'Network HBO', 'Network Canal+')
ORDER BY ID_T2S_EVALUATION;
