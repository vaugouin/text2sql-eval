-- New evaluations for phase 2 lot B of the result representations (compare-cards, fact-card,
-- verdict), 2026-11-11.
--
-- WHAT THIS FILE DOES
-- Adds thirty questions with their French twins, ids 2840 to 2869 set explicitly:
--   2840-2849  compare-cards: two to four named films, series or persons and one or two quantities
--              side by side, the winner marked. 2847 to 2849 are comparative yes/no questions
--              ("Is Titanic longer than Avatar?"): the classifier reads compare or verdict, so only
--              the representation is asserted.
--   2850-2859  fact-card: one entity and the one quantity or date the question asks about. 2852
--              (English), 2856 and 2857 return homonyms with the same title: the fact is the first
--              row's, the order of the default sort.
--   2860-2869  verdict: a yes/no question answered by an existence query (a row is Yes, no row is
--              No) or by a one-row count (above zero is Yes). 2862, 2866, 2868 and 2869 expect No.
--
-- ASSERTIONS. query_result pins the entities (COUNT(*) == 0 for a No, CELL(0, 0) >= 1 for the
-- count of 2864); result_shape (out of score) asserts the new representation and the task. The
-- clause intent.task == verdict needs result_shape_assertions.py of 2.21.11 (verdict added to the
-- grammar in the same commit).
--
-- BASELINE on the live API 1.1.20 (cache off, 2026-11-11, 30 English and 15 French calls; the
-- responses are the lotb-* fixtures of voice-agent and t2s-front): every result_shape assertion
-- fails, as intended (value-cards, entity-page, timeline, ranked-bars, card-grid or number-card
-- served). query_result: 2864 fails (AWARD_NAME = 'Osgar', count 0, in both languages probed).
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1, IS_SHOWCASE = 0 on all thirty.
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/new-evaluations-phase2-lot-b.sql
-- Commit and push before running. Each INSERT is guarded by NOT EXISTS on its id or its English
-- question, so a re-run inserts nothing. `>` is stored as &gt; in query_result. French twins carry
-- their accents: the runner sets utf8mb4. AUTO_INCREMENT moves to 2870.

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2840
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2840, 'Which is longer, The Godfather or The Godfather Part II?', 'Lequel est le plus long, Le Parrain ou Le Parrain, 2e partie ?', 2, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (238, 240)',
       'representation == compare-cards; intent.task == compare',
       'Phase 2 lot B, compare-cards. Two named films and one quantity (runtime): side by side, the longer one marked. A 2023 short also titled The Godfather may come with them (three rows, still within the four a comparison holds).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2840 OR QUESTION = 'Which is longer, The Godfather or The Godfather Part II?') AS guard);

-- 2841
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2841, 'Compare the box office of Jaws (1975), E.T. the Extra-Terrestrial and Jurassic Park', 'Compare les recettes des Dents de la mer (1975), d''E.T. l''extra-terrestre et de Jurassic Park', 22, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (578, 601, 329)',
       'representation == compare-cards; intent.task == compare',
       'Phase 2 lot B, compare-cards. Three named films, one quantity (revenue): the highest marked.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2841 OR QUESTION = 'Compare the box office of Jaws (1975), E.T. the Extra-Terrestrial and Jurassic Park') AS guard);

-- 2842
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2842, 'Which had the bigger budget, Titanic (1997) or Waterworld?', 'Lequel a eu le plus gros budget, Titanic (1997) ou Waterworld ?', 22, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (597, 9804)',
       'representation == compare-cards; intent.task == compare',
       'Phase 2 lot B, compare-cards. Two named films, one quantity (budget).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2842 OR QUESTION = 'Which had the bigger budget, Titanic (1997) or Waterworld?') AS guard);

-- 2843
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2843, 'Who was born first, Charlie Chaplin or Buster Keaton?', 'Qui est né le premier, Charlie Chaplin ou Buster Keaton ?', 35, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (13848, 8635)',
       'representation == compare-cards; intent.task == compare',
       'Phase 2 lot B, compare-cards on a date. Two named persons, the birth year side by side; the SQL orders by birth, so the first row (Chaplin, 1889) is the one marked.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2843 OR QUESTION = 'Who was born first, Charlie Chaplin or Buster Keaton?') AS guard);

-- 2844
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2844, 'Which series has more seasons, Breaking Bad or The Wire?', 'Quelle série a le plus de saisons, Breaking Bad ou The Wire ?', 6, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_SERIE IN (1396, 1438)',
       'representation == compare-cards; intent.task == compare',
       'Phase 2 lot B, compare-cards. Two named series, one quantity (seasons, five each: a tie, no winner marked).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2844 OR QUESTION = 'Which series has more seasons, Breaking Bad or The Wire?') AS guard);

-- 2845
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2845, 'Who has acted in more films, Robert De Niro or Al Pacino?', 'Qui a joué dans le plus de films, Robert De Niro ou Al Pacino ?', 27, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (380, 1158)',
       'representation == compare-cards; intent.task == compare',
       'Phase 2 lot B, compare-cards on a computed count (FILM_COUNT per person).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2845 OR QUESTION = 'Who has acted in more films, Robert De Niro or Al Pacino?') AS guard);

-- 2846
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2846, 'Compare the budget and the revenue of Avatar (2009) and Titanic (1997)', 'Compare le budget et les recettes d''Avatar (2009) et de Titanic (1997)', 22, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (19995, 597)',
       'representation == compare-cards; intent.task == compare',
       'Phase 2 lot B, compare-cards with two focus quantities: one line per quantity under each card, the winner marked per quantity.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2846 OR QUESTION = 'Compare the budget and the revenue of Avatar (2009) and Titanic (1997)') AS guard);

-- 2847
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2847, 'Is Titanic (1997) longer than Avatar (2009)?', 'Titanic (1997) est-il plus long qu''Avatar (2009) ?', 2, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (597, 19995)',
       'representation == compare-cards',
       'Phase 2 lot B. A comparative yes/no question: the classifier reads compare or verdict, both accepted. The rows are the two films with their runtime, so the answer is compare-cards (the longer one marked); a Yes/No needs the subject and the direction of the comparison, which the rows do not carry (README, verdict limits).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2847 OR QUESTION = 'Is Titanic (1997) longer than Avatar (2009)?') AS guard);

-- 2848
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2848, 'Does Game of Thrones have more episodes than Breaking Bad?', 'Game of Thrones a-t-elle plus d''épisodes que Breaking Bad ?', 6, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_SERIE IN (1399, 1396)',
       'representation == compare-cards',
       'Phase 2 lot B. Comparative yes/no on two series (episodes): compare-cards, whatever the task read (compare or verdict). Served ranked-bars on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2848 OR QUESTION = 'Does Game of Thrones have more episodes than Breaking Bad?') AS guard);

-- 2849
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2849, 'Was Orson Welles born before Alfred Hitchcock?', 'Orson Welles est-il né avant Alfred Hitchcock ?', 35, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (40, 2636)',
       'representation == compare-cards',
       'Phase 2 lot B. Comparative yes/no on a date: compare-cards, the earlier birth (Hitchcock, 1899) first and marked. Served card-grid in French on 1.1.20 (task verdict).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2849 OR QUESTION = 'Was Orson Welles born before Alfred Hitchcock?') AS guard);

-- 2850
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2850, 'How long is Lawrence of Arabia?', 'Combien de temps dure Lawrence d''Arabie ?', 2, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (947)',
       'representation == fact-card; intent.task == value',
       'Phase 2 lot B, fact-card. One film, one quantity asked (runtime): the poster with the fact named, not the whole entity page.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2850 OR QUESTION = 'How long is Lawrence of Arabia?') AS guard);

-- 2851
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2851, 'What was the budget of Waterworld?', 'Quel a été le budget de Waterworld ?', 22, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (9804)',
       'representation == fact-card; intent.task == value',
       'Phase 2 lot B, fact-card (budget).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2851 OR QUESTION = 'What was the budget of Waterworld?') AS guard);

-- 2852
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2852, 'When was Vertigo released?', 'Quand Sueurs froides est-il sorti ?', 2, 1, 1, 0, 0, CURDATE(), 1, 1,
       'CELL(0, 0) == 426 AND ID_MOVIE IN (426)',
       'representation == fact-card; intent.task == value',
       'Phase 2 lot B, fact-card on a date. In English the title brings eleven homonyms, every row named Vertigo and ordered by the default sort: the fact is the first row''s (Hitchcock, 1958), the others are listed as other titles of the same name, never a timeline of homonyms (served timeline on 1.1.20).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2852 OR QUESTION = 'When was Vertigo released?') AS guard);

-- 2853
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2853, 'How much did Avatar (2009) gross at the box office?', 'Combien Avatar (2009) a-t-il rapporté au box-office ?', 22, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (19995)',
       'representation == fact-card; intent.task == value',
       'Phase 2 lot B, fact-card (revenue).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2853 OR QUESTION = 'How much did Avatar (2009) gross at the box office?') AS guard);

-- 2854
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2854, 'When was Akira Kurosawa born?', 'Quand Akira Kurosawa est-il né ?', 35, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (5026)',
       'representation == fact-card; intent.task == value',
       'Phase 2 lot B, fact-card on a person (birth year).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2854 OR QUESTION = 'When was Akira Kurosawa born?') AS guard);

-- 2855
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2855, 'How many seasons does Breaking Bad have?', 'Combien de saisons compte Breaking Bad ?', 6, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_SERIE IN (1396)',
       'representation == fact-card; intent.task == value',
       'Phase 2 lot B, fact-card on a series (seasons).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2855 OR QUESTION = 'How many seasons does Breaking Bad have?') AS guard);

-- 2856
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2856, 'What is the IMDb rating of Casablanca?', 'Quelle est la note IMDb de Casablanca ?', 2, 1, 1, 0, 0, CURDATE(), 1, 1,
       'CELL(0, 0) == 289 AND ID_MOVIE IN (289)',
       'representation == fact-card; intent.task == value',
       'Phase 2 lot B, fact-card with homonyms: four films named Casablanca, the 1942 one first by the default sort; served value-cards on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2856 OR QUESTION = 'What is the IMDb rating of Casablanca?') AS guard);

-- 2857
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2857, 'How many episodes does Chernobyl have?', 'Combien d''épisodes compte Chernobyl ?', 6, 1, 1, 0, 0, CURDATE(), 1, 1,
       'CELL(0, 0) == 87108 AND ID_SERIE IN (87108)',
       'representation == fact-card; intent.task == value',
       'Phase 2 lot B, fact-card with a homonym: two series named Chernobyl, the 2019 miniseries (5 episodes) first; on 1.1.20 the value cards named the other one (12 episodes) as the maximum.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2857 OR QUESTION = 'How many episodes does Chernobyl have?') AS guard);

-- 2858
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2858, 'In what year did Stanley Kubrick die?', 'En quelle année Stanley Kubrick est-il mort ?', 35, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_PERSON IN (240)',
       'representation == fact-card; intent.task == value',
       'Phase 2 lot B, fact-card on a person (death year).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2858 OR QUESTION = 'In what year did Stanley Kubrick die?') AS guard);

-- 2859
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2859, 'What is the runtime of Seven Samurai?', 'Quelle est la durée des Sept Samouraïs ?', 2, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (346)',
       'representation == fact-card; intent.task == value',
       'Phase 2 lot B, fact-card (runtime).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2859 OR QUESTION = 'What is the runtime of Seven Samurai?') AS guard);

-- 2860
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2860, 'Did Steven Spielberg direct Jaws?', 'Steven Spielberg a-t-il réalisé Les Dents de la mer ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (578)',
       'representation == verdict; intent.task == verdict',
       'Phase 2 lot B, verdict by existence: the SQL filters on both conditions, one row means Yes, with the film as evidence.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2860 OR QUESTION = 'Did Steven Spielberg direct Jaws?') AS guard);

-- 2861
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2861, 'Was Toshiro Mifune in Yojimbo?', 'Toshiro Mifune a-t-il joué dans Yojimbo ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (11878)',
       'representation == verdict; intent.task == verdict',
       'Phase 2 lot B, verdict by existence (cast).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2861 OR QUESTION = 'Was Toshiro Mifune in Yojimbo?') AS guard);

-- 2862
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2862, 'Did Alfred Hitchcock direct Casablanca?', 'Alfred Hitchcock a-t-il réalisé Casablanca ?', 52, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) == 0',
       'representation == verdict; intent.task == verdict',
       'Phase 2 lot B, verdict No: the existence query returns no row (Michael Curtiz directed it). Served an empty card grid on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2862 OR QUESTION = 'Did Alfred Hitchcock direct Casablanca?') AS guard);

-- 2863
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2863, 'Did Christopher Nolan direct Inception?', 'Est-ce que Christopher Nolan a réalisé Inception ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (27205)',
       'representation == verdict; intent.task == verdict',
       'Phase 2 lot B, verdict by existence; the French twin uses est-ce que.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2863 OR QUESTION = 'Did Christopher Nolan direct Inception?') AS guard);

-- 2864
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2864, 'Has Meryl Streep ever won an Oscar?', 'Meryl Streep a-t-elle déjà gagné un Oscar ?', 49, 1, 1, 0, 0, CURDATE(), 1, 1,
       'CELL(0, 0) &gt;= 1',
       'representation == verdict; intent.task == verdict',
       'Phase 2 lot B, verdict on a one-row count: above zero is Yes. On 1.1.20 the SQL filtered on AWARD_NAME = ''Osgar'' and counted 0, a wrong No (query_result fails).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2864 OR QUESTION = 'Has Meryl Streep ever won an Oscar?') AS guard);

-- 2865
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2865, 'Did Bryan Cranston star in Breaking Bad?', 'Bryan Cranston a-t-il joué dans Breaking Bad ?', 28, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_SERIE IN (1396)',
       'representation == verdict; intent.task == verdict',
       'Phase 2 lot B, verdict by existence on a series cast.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2865 OR QUESTION = 'Did Bryan Cranston star in Breaking Bad?') AS guard);

-- 2866
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2866, 'Did Tom Hanks act in Titanic (1997)?', 'Tom Hanks a-t-il joué dans Titanic (1997) ?', 52, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) == 0',
       'representation == verdict; intent.task == verdict',
       'Phase 2 lot B, verdict No on a cast question.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2866 OR QUESTION = 'Did Tom Hanks act in Titanic (1997)?') AS guard);

-- 2867
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2867, 'Has Stanley Kubrick directed a science fiction film?', 'Est-ce que Stanley Kubrick a réalisé un film de science-fiction ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_MOVIE IN (62)',
       'representation == verdict; intent.task == verdict',
       'Phase 2 lot B, verdict Yes with several rows of evidence (2001: A Space Odyssey, A Clockwork Orange).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2867 OR QUESTION = 'Has Stanley Kubrick directed a science fiction film?') AS guard);

-- 2868
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2868, 'Did Alfred Hitchcock ever direct a western?', 'Alfred Hitchcock a-t-il déjà réalisé un western ?', 52, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) == 0',
       'representation == verdict; intent.task == verdict',
       'Phase 2 lot B, verdict No over a genre.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2868 OR QUESTION = 'Did Alfred Hitchcock ever direct a western?') AS guard);

-- 2869
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2869, 'Has Christopher Nolan directed a TV series?', 'Christopher Nolan a-t-il réalisé une série télévisée ?', 53, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) == 0',
       'representation == verdict; intent.task == verdict',
       'Phase 2 lot B, verdict No on the series side.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2869 OR QUESTION = 'Has Christopher Nolan directed a TV series?') AS guard);

-- Read-back: the thirty rows as stored.
SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION BETWEEN 2840 AND 2869
ORDER BY ID_T2S_EVALUATION;
