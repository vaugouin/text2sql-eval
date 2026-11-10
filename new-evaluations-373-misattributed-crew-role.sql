-- New evaluations for FASTAPI-TEXT2SQL-373 (to open): the question gives a person a crew role
-- they do not hold on the work meant ("the film directed by Tarantino" for a film he only wrote).
-- Asked by Philippe on 2026-11-09, written the same day, before any code. NOT YET APPLIED: a
-- campaign (gpt-6.1-terra on the text2sql task) is running; insert after it ends.
--
-- ORIGIN. Live trace of 2026-11-08, "Quel est le film que Quentin Tarantino sort en ce moment ?".
-- Philippe meant The Further Mis-Adventures of Cliff Booth (2026, TMDb 1457866), the sequel of
-- Once Upon a Time... in Hollywood (2019, 466272), which Tarantino directed; the sequel is
-- directed by David Fincher and Tarantino is credited Writing / Writer and Writing / Characters
-- only. The time qualifier "en ce moment" is deliberately left out of these questions (Philippe,
-- 2026-11-09): it ages, and it belongs to the popularity evaluations and to -370. The routing
-- defect of that trace is -367 (second shape).
--
-- THE DEFECT TO MEASURE. With a crew-department filter on the person (Directing) and another
-- constraint (a description, a sequel relation, a year), the conjunction is empty and the -221
-- gate takes the empty result as true. Expected: the role constraint is relaxed (the person's
-- other crew credits that satisfy the rest of the question), the work comes back, and the answer
-- names the actual director.
--
-- WHAT THIS FILE DOES. Seven questions with their French twins, category 4 (movies cast and crew).
-- A. Wrong role, the work pinned by another constraint:
--   1. Directed by Tarantino + sequel of Once Upon a Time... in Hollywood -> 1457866 (Fincher).
--   2. Directed by Tarantino + released in 2026 -> must contain 1457866. Not a single row: the
--      person page also shows 2026 producer credits (One Spoon of Chocolate 1290792, The
--      Projectionist 1598142) and 2026 cast credits, so no answer assertion here.
--   3. Directed by Spielberg + the girl taken through the television -> 609 Poltergeist (1982),
--      directed by Tobe Hooper; Spielberg is Writing / Screenplay, Story and Production / Producer.
--   4. Directed by Spielberg + creatures never to be fed after midnight -> 927 Gremlins (1984),
--      directed by Joe Dante; Spielberg is Executive Producer (and an uncredited cameo).
--   5. Directed by Tim Burton + the king of Halloween Town discovers Christmas -> 9479 The
--      Nightmare Before Christmas (1993), directed by Henry Selick; Burton is Producer, Writing /
--      Characters and Story.
-- B. No role given (the shape of Philippe's question, minus "en ce moment"):
--   6. "Film de Tarantino" + 2026 -> must contain 1457866. Today's rule (a work "by" a person =
--      any crew credit, data/text_to_sql.md) should already pass, once -367 keeps it routed.
-- C. Control, the role is right and must stay strict:
--   7. Directed by Tarantino + Hollywood in 1969 -> 466272, and NOT the sequel 1457866, which he
--      did not direct. Fails if the fix relaxes the role when the first pass already has rows.
--
-- ASSERTIONS. ASSERTIONS_QUERY_RESULT on the ids. ASSERTIONS_RESULT_SHAPE `answer =~ <director's
-- surname>` on 1, 3, 4, 5: the answer must name who actually directed the film, which says the
-- role was corrected without depending on the wording (scénariste, writer, produced...). The
-- `answer` clause is out of score (text2sql-eval 2.20.0), tallied apart by check-result-shape.py.
-- No assertion on today's titles beyond the ids: none of these questions ages.
--
-- IDS (read 2026-11-09 on the tmdb-front pages movie.php and person.php). Verbatim on the page:
-- 1457866, 609, 927, 9479 (titles, dates, directors, the Spielberg and Burton credits), 466272
-- (title, date, collection 4770). Read only from a summary of the page, to confirm by a SELECT
-- before applying: Tarantino's Directing credit on 466272, and his 2026 crew credits (person 138).
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1 (rule of 2026-10-31), IS_SHOWCASE = 1 on 1, 3, 4, 5, 7 (one
-- film with a poster); 0 on 2 and 6 (a short list whose size the base decides).
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1, once the campaign has ended.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-373-misattributed-crew-role.sql
--
-- CONVENTIONS (as new-evaluations-371-co-constraint-series-persons.sql): auto-increment id; each
-- INSERT is guarded by NOT EXISTS on the English QUESTION; DELETED = 0; DAT_CREAT = CURDATE();
-- owner 1. No backslash anywhere (a MariaDB string literal would eat it).

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which film directed by Quentin Tarantino is the sequel to Once Upon a Time in Hollywood?',
       'Quel film réalisé par Quentin Tarantino est la suite de Once Upon a Time in Hollywood ?',
       4, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (1457866)', 'answer =~ Fincher'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which film directed by Quentin Tarantino is the sequel to Once Upon a Time in Hollywood?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which film directed by Quentin Tarantino comes out in 2026?',
       'Quel film réalisé par Quentin Tarantino sort en 2026 ?',
       4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (1457866)', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which film directed by Quentin Tarantino comes out in 2026?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which film directed by Steven Spielberg is about a little girl taken by ghosts through the television?',
       'Quel film réalisé par Steven Spielberg raconte l''histoire d''une petite fille enlevée par des fantômes à travers la télévision ?',
       4, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (609)', 'answer =~ Hooper'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which film directed by Steven Spielberg is about a little girl taken by ghosts through the television?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which film directed by Steven Spielberg features small creatures that must never be fed after midnight?',
       'Quel film réalisé par Steven Spielberg met en scène de petites créatures qu''il ne faut jamais nourrir après minuit ?',
       4, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (927)', 'answer =~ Dante'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which film directed by Steven Spielberg features small creatures that must never be fed after midnight?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which film directed by Tim Burton tells the story of the king of Halloween Town who discovers Christmas?',
       'Quel film réalisé par Tim Burton raconte l''histoire du roi de la ville d''Halloween qui découvre Noël ?',
       4, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (9479)', 'answer =~ Selick'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which film directed by Tim Burton tells the story of the king of Halloween Town who discovers Christmas?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which Quentin Tarantino film comes out in 2026?',
       'Quel film de Quentin Tarantino sort en 2026 ?',
       4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (1457866)', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which Quentin Tarantino film comes out in 2026?') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE)
SELECT 'Which film directed by Quentin Tarantino takes place in Hollywood in 1969?',
       'Quel film réalisé par Quentin Tarantino se déroule à Hollywood en 1969 ?',
       4, 1, 1, 1, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (466272) AND ID_MOVIE NOT IN (1457866)', NULL
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE QUESTION = 'Which film directed by Quentin Tarantino takes place in Hollywood in 1969?') AS guard);

-- The new rows.
SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_SAMPLE, IS_SHOWCASE, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE
  FROM T_WC_T2S_EVALUATION
  WHERE QUESTION IN ('Which film directed by Quentin Tarantino is the sequel to Once Upon a Time in Hollywood?', 'Which film directed by Quentin Tarantino comes out in 2026?', 'Which film directed by Steven Spielberg is about a little girl taken by ghosts through the television?', 'Which film directed by Steven Spielberg features small creatures that must never be fed after midnight?', 'Which film directed by Tim Burton tells the story of the king of Halloween Town who discovers Christmas?', 'Which Quentin Tarantino film comes out in 2026?', 'Which film directed by Quentin Tarantino takes place in Hollywood in 1969?')
  ORDER BY ID_T2S_EVALUATION;
