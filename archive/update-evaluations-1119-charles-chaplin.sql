-- Evaluation 1119 "Charles Chaplin": give it a category and an assertion so it runs and scores.
-- FASTAPI-TEXT2SQL-365. Written 2026-11-05.
--
-- WHY
-- "Charles Chaplin" is the case voie 1 of FASTAPI-TEXT2SQL-365 was written for: on the main names
-- it is a fuzzy hit on Charles Champlin (TMDb 552213), while "Charles Chaplin" is an exact TMDb
-- alias of Charlie Chaplin (13848, check-exact-alias-over-fuzzy-name-20261105.txt line 22); the
-- popularity guard lets it win only if Chaplin is at least as popular as Champlin, which section 1
-- prints. The live campaign of 2026-11-05 did not
-- exercise it: 2262 is asked in Japanese and the complex model rewrote it "Charlie Chaplin".
-- 1119 already holds the question, typed 2025-12-30, but with no category and no assertion, so the
-- evaluator never executed it (no execution in the 1.1.20 exports). Filling it beats a duplicate.
--
-- WHAT THE ASSERTION PROTECTS
-- COUNT(*) > 0 (floor) AND ID_PERSON IN (13848), as for 1120 "Charlie Chaplin". Category 30
-- (Persons - Person name queries). ASSERTIONS_ENTITY_EXTRACTION left NULL: the extraction may keep
-- "Charles Chaplin" or correct it, both are fine, the resolver is what is tested.
--
-- GUARD: the UPDATE only touches 1119 while it still has the question and no assertion.
-- Voie 1 (T_WC_T2S_EVALUATION is writable by the agent). Then phase 31 to refresh the JSON export.

-- 0. Pre-flight: one row, category NULL, assertion NULL.
SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, QUESTION, QUESTION_FR, IS_EVAL, DELETED,
       ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION = 1119;

-- 1. The two persons at stake, as the resolver sees them.
SELECT ID_PERSON, PERSON_NAME, POPULARITY
FROM T_WC_T2S_PERSON
WHERE ID_PERSON IN (13848, 552213);

SELECT ID_PERSON, PERSON_NAME, ALIAS_SOURCE
FROM T_WC_T2S_PERSON_ALSO_KNOWN_AS
WHERE PERSON_NAME = 'Charles Chaplin';

-- 2. Fill the evaluation.
UPDATE T_WC_T2S_EVALUATION
SET ID_T2S_EVALUATION_CATEGORY = 30,
    ASSERTIONS_QUERY_RESULT = 'COUNT(*) &gt; 0 AND ID_PERSON IN (13848)',
    LONG_DESC = 'Exact TMDb alias of Charlie Chaplin (13848) and a fuzzy hit on the main name of Charles Champlin (552213). Before FASTAPI-TEXT2SQL-365 the fuzzy hit ended the search and Champlin came back; since, the exact alias of the more popular person wins. Twin of 1120 (Charlie Chaplin) and 2262 (Japanese).',
    TIM_UPDATED = NOW()
WHERE ID_T2S_EVALUATION = 1119
  AND QUESTION = 'Charles Chaplin'
  AND (ASSERTIONS_QUERY_RESULT IS NULL OR ASSERTIONS_QUERY_RESULT = '');

-- 3. Post-flight: category 30 and the assertion.
SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, QUESTION, ASSERTIONS_QUERY_RESULT,
       LEFT(LONG_DESC, 60) AS LONG_DESC
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION = 1119;
