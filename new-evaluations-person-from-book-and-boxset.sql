-- New evaluations for FASTAPI-TEXT2SQL-341 and -342: a photographed book or box set that
-- names no single work must fall back to the PERSON it is built around.
--
-- Written 2026-10-25. 4 evaluations, English and French, category 16 (persons, basic queries).
-- Voie 1: four INSERT on T_WC_T2S_EVALUATION, nothing else. Ids are AUTO_INCREMENT, never
-- hand-picked: that is exactly what collided for the -339 book eval (hand-numbered 2540, a
-- value episode-locations already held) and is being unwound. An INSERT takes the next free id.
--
-- WHY THIS FILE EXISTS
-- Philippe's photo tests of 2026-10-25 (client-20261025.log):
--   * "The Complete Works of Shakespeare" (10:10:55) and "The Complete Robot by Isaac Asimov"
--     (10:22:00) returned empty_result. A collected-works / omnibus volume names no single
--     source work, so there is nothing to resolve against, and the author was not reached.
--     FASTAPI-TEXT2SQL-341 makes the vision fall back to the author as a person.
--   * "Marlon Brando 4-Movie Collection" (10:26:36, n=5) and "The Peter Sellers Collection"
--     (10:28:20) returned the franchise collections the actor is merely credited in, because
--     the word "Collection" was read as a TMDb collection. FASTAPI-TEXT2SQL-342 makes the
--     vision read a person-named box set as the person.
-- In every case the fix composes `Person <name>`, which must resolve to that person's fiche.
--
-- WHAT THE ASSERTIONS PROTECT
-- The harness is text-only and cannot upload an image, so these evaluations do not exercise
-- the vision prompt. They guard the DOWNSTREAM resolution the vision pre-stage composes to:
-- `Person <name>` must land on the right person. The anchor is ID_PERSON, a TMDb id that does
-- not drift (PERSON_NAME has homonyms, see FASTAPI-TEXT2SQL-258), never the name.
--   Shakespeare 6210, Asimov 21087, Brando 3084, Sellers 12446 (TMDb = ID_PERSON, verified).
--
-- ASSERTIONS_SQL_QUERY IS LEFT NULL, like the other category-16 person probes (e.g. 1003-1005):
-- a person lookup has no single mandatory table to assert on; the id in the result is the proof.
--
-- ASSERTIONS_ENTITY_EXTRACTION IS LEFT NULL: the house method is three passes per language,
-- not run here.
--
-- PRE-FLIGHT (section 0) CONFIRMS THE FOUR AUTHORS/ACTORS ARE IN THE PERSON CATALOGUE. If any
-- row is missing, -341's author fall back has no person to land on and the ticket needs a
-- different target for that name; do not mark the eval green until section 0 shows all four.
--
-- RE-RUN GUARD: each INSERT ... SELECT is guarded by NOT EXISTS on the English question, in a
-- derived table (MySQL error 1093). Re-running the file is a no-op.
--
-- AFTER: phase 31 to refresh the JSON export, then phases 11 + 20 to run and score them.


SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- 0. Pre-flight. The four persons must exist in the catalogue. Then the four
--    questions: zero rows before the INSERTs, four after.
-- ---------------------------------------------------------------------------
SELECT '0. Asserted persons (all four must be present)' AS SECTION;

SELECT p.ID_PERSON, p.PERSON_NAME, p.DELETED
FROM T_WC_T2S_PERSON p
WHERE p.ID_PERSON IN (6210, 21087, 3084, 12446)
ORDER BY p.ID_PERSON;

SELECT '0b. Before' AS SECTION;

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, LEFT(QUESTION, 60) AS QUESTION
FROM T_WC_T2S_EVALUATION
WHERE QUESTION IN (
  'Person William Shakespeare',
  'Person Isaac Asimov',
  'Person Marlon Brando',
  'Person Peter Sellers'
);


-- ---------------------------------------------------------------------------
-- 1. The new evaluations, category 16: persons, basic queries.
-- ---------------------------------------------------------------------------

-- 1. FASTAPI-TEXT2SQL-341: omnibus book -> author (The Complete Works of Shakespeare).
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Person William Shakespeare', 'William Shakespeare',
       1, 0, 16, 0, CURDATE(), NOW(),
       'ID_PERSON IN (6210)',
       'FASTAPI-TEXT2SQL-341. A photo of a collected-works / omnibus volume names no single source work (The Complete Works of Shakespeare returned empty on 2026-10-25). The vision fix falls back to the author as a person; the composed Person William Shakespeare must resolve to ID_PERSON 6210 (TMDb id, stable; PERSON_NAME has homonyms).'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Person William Shakespeare') AS existing);

-- 2. FASTAPI-TEXT2SQL-341: omnibus book -> author (The Complete Robot by Isaac Asimov).
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Person Isaac Asimov', 'Isaac Asimov',
       1, 0, 16, 0, CURDATE(), NOW(),
       'ID_PERSON IN (21087)',
       'FASTAPI-TEXT2SQL-341. A photo of a short-story collection / omnibus names no single source work (The Complete Robot returned empty on 2026-10-25, not even a fall back to the author). The vision fix falls back to the author as a person; the composed Person Isaac Asimov must resolve to ID_PERSON 21087 (TMDb id, stable).'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Person Isaac Asimov') AS existing);

-- 3. FASTAPI-TEXT2SQL-342: actor box set -> the actor (Marlon Brando 4-Movie Collection).
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Person Marlon Brando', 'Marlon Brando',
       1, 0, 16, 0, CURDATE(), NOW(),
       'ID_PERSON IN (3084)',
       'FASTAPI-TEXT2SQL-342. A DVD box set built around an actor (Marlon Brando 4-Movie Collection) was read as a TMDb collection, returning franchise collections the actor is merely credited in (n=5 on 2026-10-25). The vision fix reads a person-named box set as the person; the composed Person Marlon Brando must resolve to ID_PERSON 3084.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Person Marlon Brando') AS existing);

-- 4. FASTAPI-TEXT2SQL-342: actor box set -> the actor (The Peter Sellers Collection).
INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Person Peter Sellers', 'Peter Sellers',
       1, 0, 16, 0, CURDATE(), NOW(),
       'ID_PERSON IN (12446)',
       'FASTAPI-TEXT2SQL-342. A DVD box set built around an actor (The Peter Sellers Collection) was read as a TMDb collection rather than the actor. The vision fix reads a person-named box set as the person; the composed Person Peter Sellers must resolve to ID_PERSON 12446.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
  WHERE QUESTION = 'Person Peter Sellers') AS existing);


-- ---------------------------------------------------------------------------
-- 2. After. Four rows, with their stored assertions.
-- ---------------------------------------------------------------------------
SELECT '2. After' AS SECTION;

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE,
       LEFT(QUESTION, 40) AS QUESTION, LEFT(QUESTION_FR, 40) AS QUESTION_FR,
       ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION
WHERE QUESTION IN (
  'Person William Shakespeare',
  'Person Isaac Asimov',
  'Person Marlon Brando',
  'Person Peter Sellers'
);
