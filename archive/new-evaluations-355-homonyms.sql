-- New evaluations for FASTAPI-TEXT2SQL-355: homonyms (same title, same year) on the complex retry.
--
-- Written 2026-11-05, BEFORE the code, per the rule of Philippe of 2026-10-31 (evaluations first,
-- baseline on the current version, implement, run again). 13 evaluations, EN with FR twins.
--
-- WHY. A description resolved by the complex model is rewritten as `Movie <title> (<year>)`. When
-- the base holds two works with that title and year, both come back (Taxi Driver 1976: Scorsese and
-- the Turkish Taksi Şoförü, GUESS-277). -355 reuses the identity check of -307 (vision) on the
-- complex retry: the complex model also returns `known_credits`, the candidates are read in base
-- (title, year +/-1), a deterministic score picks one, and the winner is queried by its IMDb id.
--
-- THE ASSERTIONS. `COUNT(*) == 1 AND ID_MOVIE IN (<id>)`: the defect returns the right film PLUS
-- the homonyms, so "contains" would pass today; only the count catches it. Ids read in
-- harvest-title-year-homonyms-20260930.txt and harvest-title-year-homonyms-series-20260930.txt.
-- Two reverse cases (612176, 1075794) guard against any popularity shortcut. The last question is
-- the control: a bare title + year must keep returning both films.
--
-- Expected baseline on 1.1.20: the 12 descriptive questions red (two or more rows), the control green.
--
-- IS_SAMPLE = 1 and IS_SHOWCASE = 1 (assertions list entity ids with a poster), except the control.
-- No ASSERTION_REFRESH_SQL: these are fixed identities, and a refresh would drop the COUNT(*) == 1.
-- RE-RUN GUARD: INSERT ... SELECT ... WHERE NOT EXISTS on the English question.
--
-- HOW TO RUN: ssh vps-agent run text2sql-eval/new-evaluations-355-homonyms.sql
-- then phase 31 (export), phases 11 + 20 on these ids.

SELECT ID_T2S_EVALUATION, LEFT(QUESTION, 70) AS QUESTION FROM T_WC_T2S_EVALUATION
WHERE LONG_DESC LIKE '%FASTAPI-TEXT2SQL-355%';

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '"On every street in every city, there''s a nobody who dreams of being a somebody." Name the film.',
       '« Dans chaque rue de chaque ville, il y a un moins que rien qui rêve d''être quelqu''un. » Quel est ce film ?',
       1, 1, 1, 60, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_MOVIE IN (103)',
       'Tagline of Taxi Driver (Scorsese, TMDb 103). Title + year shared with the Turkish Taksi Şoförü (612176, 1976): the complex retry looks up "Taxi Driver (1976)" and returns both. GUESS-277, Short episode 51. Red until FASTAPI-TEXT2SQL-355.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = '"On every street in every city, there''s a nobody who dreams of being a somebody." Name the film.') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which 1976 Turkish film directed by Şerif Gören, starring Kadir İnanır, shares its English title with a famous American film of the same year?',
       'Quel film turc de 1976 réalisé par Şerif Gören, avec Kadir İnanır, porte le même titre anglais qu''un célèbre film américain de la même année ?',
       1, 1, 1, 60, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_MOVIE IN (612176)',
       'Reverse case of the Taxi Driver pair: the obscure film (154 IMDb votes) must win on its director and cast, never lose to popularity (FASTAPI-TEXT2SQL-355, -307 anti-popularity rule).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which 1976 Turkish film directed by Şerif Gören, starring Kadir İnanır, shares its English title with a famous American film of the same year?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which film that won the Best Picture Oscar weaves together the lives of strangers in Los Angeles over two days of racial tension?',
       'Quel film oscarisé du meilleur film entremêle la vie d''inconnus à Los Angeles pendant deux jours de tensions raciales ?',
       1, 1, 1, 60, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_MOVIE IN (1640)',
       'Crash (Paul Haggis, TMDb 1640), title + year shared with the Turkish Çarpışma (468180, 2005). FASTAPI-TEXT2SQL-355.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which film that won the Best Picture Oscar weaves together the lives of strangers in Los Angeles over two days of racial tension?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'In which 1992 animated film does Robin Williams voice a genie freed from a lamp by a street thief?',
       'Dans quel film d''animation de 1992 Robin Williams prête-t-il sa voix à un génie libéré de sa lampe par un voleur des rues ?',
       1, 1, 1, 60, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_MOVIE IN (812)',
       'Aladdin (Musker and Clements, TMDb 812), three films share title and year (343693, 357528). FASTAPI-TEXT2SQL-355.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'In which 1992 animated film does Robin Williams voice a genie freed from a lamp by a street thief?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which 1997 Disney animated film follows the son of Zeus proving himself a true hero, narrated by gospel-singing Muses?',
       'Quel film d''animation Disney de 1997 suit le fils de Zeus qui doit prouver qu''il est un vrai héros, raconté par des Muses qui chantent du gospel ?',
       1, 1, 1, 60, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_MOVIE IN (11970)',
       'Hercules (Musker and Clements, TMDb 11970), four films share title and year (378135, 299466, 347266). FASTAPI-TEXT2SQL-355.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which 1997 Disney animated film follows the son of Zeus proving himself a true hero, narrated by gospel-singing Muses?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'In which film does a linguist played by Amy Adams learn the language of heptapods who have landed on Earth?',
       'Dans quel film une linguiste jouée par Amy Adams apprend-elle la langue des heptapodes venus sur Terre ?',
       1, 1, 1, 60, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_MOVIE IN (329865)',
       'Arrival (Villeneuve, TMDb 329865), title + year shared with 472349 (2016), which has no credits in the base: a candidate scoring 0 must lose to the one that matches (FASTAPI-TEXT2SQL-355).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'In which film does a linguist played by Amy Adams learn the language of heptapods who have landed on Earth?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which Ridley Scott film sends a spaceship crew to find the creators of humanity, as a prequel to Alien?',
       'Quel film de Ridley Scott envoie l''équipage d''un vaisseau à la recherche des créateurs de l''humanité, en préquelle d''Alien ?',
       1, 1, 1, 60, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_MOVIE IN (70981)',
       'Prometheus (TMDb 70981), title + year shared with the Spanish Prometeo (1399075, 2012). FASTAPI-TEXT2SQL-355.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which Ridley Scott film sends a spaceship crew to find the creators of humanity, as a prequel to Alien?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which 1996 horror film features a masked killer who quizzes his victims on horror movie trivia over the phone?',
       'Quel film d''horreur de 1996 met en scène un tueur masqué qui interroge ses victimes au téléphone sur les films d''horreur ?',
       1, 1, 1, 60, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_MOVIE IN (4232)',
       'Scream (Wes Craven, TMDb 4232), title + year shared with the Ukrainian Крик (1629684). FASTAPI-TEXT2SQL-355.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which 1996 horror film features a masked killer who quizzes his victims on horror movie trivia over the phone?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which 2023 Tamil action film by Lokesh Kanagaraj stars Vijay as a café owner in Himachal Pradesh hiding a violent past?',
       'Quel film d''action tamoul de 2023 de Lokesh Kanagaraj montre Vijay en patron de café dans l''Himachal Pradesh qui cache un passé violent ?',
       1, 1, 1, 60, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_MOVIE IN (949229)',
       'Leo (Tamil, TMDb 949229) against the Netflix Leo (1075794) and a third (1169632), all 2023, both known films close in votes (75 K and 47 K): director, cast and language decide, not popularity. FASTAPI-TEXT2SQL-355.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which 2023 Tamil action film by Lokesh Kanagaraj stars Vijay as a café owner in Himachal Pradesh hiding a violent past?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'In which 2023 animated musical does Adam Sandler voice a 74-year-old lizard who is a classroom pet?',
       'Dans quelle comédie musicale d''animation de 2023 Adam Sandler prête-t-il sa voix à un lézard de 74 ans, animal de compagnie d''une classe ?',
       1, 1, 1, 60, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_MOVIE IN (1075794)',
       'Leo (Netflix, TMDb 1075794), the less voted of the two known Leo films of 2023: twin of the Tamil case (FASTAPI-TEXT2SQL-355).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'In which 2023 animated musical does Adam Sandler voice a 74-year-old lizard who is a classroom pet?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which 1976 Arabic-language film by Moustapha Akkad tells the birth of Islam, shot alongside its English-language version?',
       'Quel film en langue arabe de 1976 de Moustapha Akkad raconte la naissance de l''islam, tourné en même temps que sa version anglaise ?',
       1, 1, 1, 60, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_MOVIE IN (881210)',
       'The Message, Arabic version (Al-risâlah, TMDb 881210) against the English one (26842): same title, year and director, no cast in base for the Arabic one. Only the original language can decide (FASTAPI-TEXT2SQL-355, the -307 "shared director" case).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which 1976 Arabic-language film by Moustapha Akkad tells the birth of Islam, shot alongside its English-language version?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'In which 2023 series does Keri Russell play a career diplomat suddenly named US ambassador to the United Kingdom?',
       'Dans quelle série de 2023 Keri Russell joue-t-elle une diplomate de carrière nommée soudain ambassadrice des États-Unis au Royaume-Uni ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (203857)',
       'The Diplomat (Debora Cahn, TMDb 203857), title + first-air year shared with the British The Diplomat (203762, Ben Richards). Series side of FASTAPI-TEXT2SQL-355.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'In which 2023 series does Keri Russell play a career diplomat suddenly named US ambassador to the United Kingdom?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Movie Taxi Driver (1976)',
       'Film Taxi Driver (1976)',
       1, 0, 0, 29, 0, CURDATE(), NOW(),
       'COUNT(*) == 2 AND ID_MOVIE IN (103, 612176)',
       'Control of FASTAPI-TEXT2SQL-355: a bare title + year typed by the user carries nothing to choose with, so both homonyms stay (the identity check runs only on the complex retry). Green today, must stay green.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Movie Taxi Driver (1976)') AS existing);

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, IS_SAMPLE, IS_SHOWCASE,
       LEFT(QUESTION, 50) AS QUESTION, ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION
WHERE LONG_DESC LIKE '%FASTAPI-TEXT2SQL-355%'
ORDER BY ID_T2S_EVALUATION;
