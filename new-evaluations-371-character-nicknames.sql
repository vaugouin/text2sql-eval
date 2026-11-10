-- New evaluations for FASTAPI-TEXT2SQL-371 step 4: a character named by a nickname or a title.
-- Asked by Philippe on 2026-11-10, written before any code (rule of 2026-10-31).
--
-- WHY
-- Character_name has no resolver in entity_resolution.json: its raw value is substituted
-- ("generic"), the SQL compares it to CAST_CHARACTER, finds nothing, and the -221 gate reads
-- the empty result as authoritative because every placeholder counts as resolved. Scan of the
-- 7,136 logs of 1.1.20: 82 carry a raw Character_name; 77 return rows on the first pass (the
-- literal name works: Sherlock Holmes, Rocky Balboa); the other 5 are authoritative empties,
-- all wrong (2220 "Six Million Dollar Man" EN twice and FR once; 2666 FR "Astérix" read as a
-- character, twice). The fix measured next: a raw substitution meeting 0 rows opens the
-- complex retry instead of closing the question.
--
-- WHAT THIS FILE DOES
-- Eight questions with their French twins, each nickname absent LITERALLY from every movie and
-- series credit (folded key, measured in fastapi-text2sql/doc/sql/check-371-character-nicknames-20261110.txt
-- and check-371-character-nicknames-2-20261110.txt), so the first pass can only come back empty.
-- Anchors already in the bank, not re-inserted: 2220 (Six Million Dollar Man, Lee Majors 18589)
-- and 2666 (Astérix with Dany Boon).
--   1. the Bionic Woman      -> Lindsay Wagner 57905 (Jaime Sommers), category 42
--   2. the Bionic Man        -> Lee Majors 18589 (Steve Austin), category 42
--   3. the Little Tramp      -> Charlie Chaplin 13848, category 32 (FR "Charlot", which IS literal
--                               in 19 movie credits: the French side may pass on the first pass)
--   4. the Caped Crusader    -> Michael Keaton 2232 and Christian Bale 3894, category 32
--   5. the Man of Steel      -> Christopher Reeve 20006 and Henry Cavill 73968, category 32
--                               ("Man of Steel" is also a film title: a reading as a title is
--                               possible and is part of what is measured)
--   6. the Merc with a Mouth -> Ryan Reynolds 10859 (Deadpool), category 32
--   7. the Web-Slinger       -> Tobey Maguire 2219, Andrew Garfield 37625, Tom Holland 1136406, category 32
--   8. Hannibal the Cannibal -> Anthony Hopkins 4173, category 32 (Mads Mikkelsen allowed, not required)
-- Measured and left out: the Dude, Dirty Harry, the Fresh Prince, Mad Max, Indy, the Man with No
-- Name, Fonz, Boy Wonder, the Gipper (the nickname is literal in at least one credit, so the
-- first pass can return a wrong row instead of an empty one: another defect, not this gate).
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1, IS_SHOWCASE = 1 (person ids with a portrait).
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-371-character-nicknames.sql
--
-- CONVENTIONS (as new-evaluations-371-co-constraint-series-persons.sql): auto-increment id; each
-- INSERT is guarded by NOT EXISTS on the English QUESTION; DELETED = 0; DAT_CREAT = CURDATE(); owner 1.

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Who starred as the Bionic Woman?', 'Qui a joué Super Jaimie ?', 42, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (57905)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Who starred as the Bionic Woman?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Who played the Bionic Man?', 'Qui a joué l''Homme bionique ?', 42, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (18589)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Who played the Bionic Man?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Who played the Little Tramp?', 'Qui a joué Charlot ?', 32, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (13848)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Who played the Little Tramp?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Who played the Caped Crusader in the movies?', 'Qui a joué le Croisé masqué au cinéma ?', 32, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (2232, 3894)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Who played the Caped Crusader in the movies?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Which actors played the Man of Steel?', 'Quels acteurs ont joué l''Homme d''acier ?', 32, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (20006, 73968)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which actors played the Man of Steel?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Who played the Merc with a Mouth?', 'Qui a joué le Mercenaire à grande gueule ?', 32, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (10859)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Who played the Merc with a Mouth?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Which actors have played the Web-Slinger in the movies?', 'Quels acteurs ont joué le Tisseur au cinéma ?', 32, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (2219, 37625, 1136406)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which actors have played the Web-Slinger in the movies?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT)
SELECT 'Who played Hannibal the Cannibal in the movies?', 'Qui a joué Hannibal le Cannibale au cinéma ?', 32, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (4173)'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Who played Hannibal the Cannibal in the movies?') AS guard);

-- Check: the eight rows and their ids.
SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, QUESTION, QUESTION_FR, ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION
WHERE QUESTION IN ('Who starred as the Bionic Woman?', 'Who played the Bionic Man?', 'Who played the Little Tramp?',
                   'Who played the Caped Crusader in the movies?', 'Which actors played the Man of Steel?',
                   'Who played the Merc with a Mouth?', 'Which actors have played the Web-Slinger in the movies?',
                   'Who played Hannibal the Cannibal in the movies?')
ORDER BY ID_T2S_EVALUATION;
