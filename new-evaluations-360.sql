-- New evaluations for FASTAPI-TEXT2SQL-360 (lexical title resolution instead of the ChromaDB
-- shortlist), written before the change as the rule of 2026-10-31 asks.
--
-- WHAT THIS FILE DOES
-- Adds six title lookups, English with a French twin, each asserting the one expected id. They
-- cover what the offline bench (fastapi-text2sql checks/bench-lexical-360.py, 2026-11-02) found
-- the embeddings path gets wrong or cannot reach, and that the bank did not cover yet:
--   1-2  movies with 1,000+ IMDb votes and no ID_WIKIDATA, so absent from the ChromaDB `movies`
--        collection (embedding-update.py:616-617). 2 also carries the French spaced colon.
--   3    the same for series: Doctor Who (2005) has no ID_WIKIDATA, so only the 1963 and 2024
--        series are reachable today; the year must pick 2005 among three homonyms.
--   4-5  a title with a year: the year-filtered ChromaDB query returned 'Andalusian Dance' for
--        Casablanca (1942) and 'Barefoot in the Sky' for Footloose (1984) in the 1.1.19 campaigns
--        (evaluations 2135, 2137). TMDb dates Casablanca 1943: the year must tolerate one off.
--   6    a spelled-out number: '24 Hours to Kill' is stored 'Twenty-Four Hours to Kill'.
-- Expected on 1.1.19: 1, 2, 3 and 6 fail; 4 and 5 may pass through the raw fallback (the raw
-- title equals the stored one), which is why they assert the id of the right year.
--
-- Every id was checked in the title pool exported on 2026-11-02 (check-360-export-title-pool.sql).
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1; IS_SHOWCASE = 1 where the entity has a poster-worthy card
-- (not 6, an obscure 1965 film).
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/new-evaluations-360.sql
--
-- CONVENTIONS (as new-evaluations-20261031.sql): auto-increment id; each INSERT guarded by NOT
-- EXISTS on the English QUESTION; DELETED = 0; DAT_CREAT = CURDATE(); owner 1. Category 2 =
-- movies basic queries, 6 = TV series basic queries (same pattern as evaluations 757, 942, 1000).

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Empire of Dreams: The Story of the Star Wars Trilogy', 'Film Star Wars : L''Empire des Rêves', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (76180)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Empire of Dreams: The Story of the Star Wars Trilogy') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Attack on Titan: Chronicle', 'Film L''Attaque des Titans - Chronicles', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (714194)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Attack on Titan: Chronicle') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Series Doctor Who (2005)', 'Série Doctor Who (2005)', 6, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_SERIE IN (57243)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Series Doctor Who (2005)') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Casablanca (1942)', 'Film Casablanca (1942)', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (289)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Casablanca (1942)') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie Footloose (1984)', 'Film Footloose (1984)', 2, 1, 1, 1, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (1788)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie Footloose (1984)') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Movie 24 Hours to Kill (1965)', 'Film Cinquante millions pour Johns (1965)', 2, 1, 1, 0, 0, CURDATE(), 1, 1, 'ID_MOVIE IN (146794)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Movie 24 Hours to Kill (1965)') AS guard);

SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ASSERTIONS_QUERY_RESULT
  FROM T_WC_T2S_EVALUATION
 WHERE QUESTION IN ('Movie Empire of Dreams: The Story of the Star Wars Trilogy', 'Movie Attack on Titan: Chronicle',
                    'Series Doctor Who (2005)', 'Movie Casablanca (1942)', 'Movie Footloose (1984)',
                    'Movie 24 Hours to Kill (1965)')
 ORDER BY ID_T2S_EVALUATION;
