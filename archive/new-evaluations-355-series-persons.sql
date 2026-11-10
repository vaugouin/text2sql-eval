-- New evaluations extending FASTAPI-TEXT2SQL-355 to series and persons (tag 355-EXT in LONG_DESC).
--
-- Written 2026-11-08 at Philippe's request, BEFORE any code (evaluations first, baseline, then code).
-- -355 tells apart homonyms that share a title AND a year when the complex model rewrites a
-- description as `Movie|Serie <title> (<year>)`: `known_credits` plus the -307 identity check pick
-- the row, queried by its IMDb id. The bank covered it with eleven movie descriptions and ONE
-- series (2641). Persons are NOT covered by the code: the rewrite `Person <name> born in <year>`
-- has no `known_credits` and no identity check (`_COMPLEX_IDENTITY_PATTERN` is Movie|Serie only).
--
-- WHAT. 26 evaluations, EN with FR twins, the same volume as the movie side (12 + 1 control each):
--   series, category 62: eleven descriptions and one reverse case (Heartland TNT, 289 votes against
--     23 K), control `Serie Heartland (2007)` (category 6) keeps both;
--   persons, category 61: twelve descriptions, three where the namesake is MORE popular (Alan
--     Parker, Michael Gordon, David Grossman) and one reverse case (Michael Jackson the television
--     executive), control `Person John Hughes born in 1950` (category 16) keeps both.
-- Collisions read in check-355-homonyms-series-persons-20261108.txt (283 series groups sharing
-- title and first air year, 93 person groups sharing name and birth year).
--
-- THE ASSERTIONS. `COUNT(*) == 1 AND ID_<TYPE> IN (<id>)`: the defect returns the right row PLUS
-- the namesake, so only the count catches it.
-- Expected baseline on Blue 1.1.20: series descriptions mostly green (the -355 code covers series),
-- person descriptions red wherever the complex model rewrites to `Person <name> born in <year>`;
-- both controls green.
--
-- IS_SAMPLE = 1 and IS_SHOWCASE = 1, except the controls. No ASSERTION_REFRESH_SQL (fixed identities).
-- RE-RUN GUARD: INSERT ... SELECT ... WHERE NOT EXISTS on the English question.
-- No backslash anywhere (MariaDB would eat it).
--
-- HOW TO RUN (voie 1): ssh vps-agent pull text2sql-eval
--                      ssh vps-agent run -e text2sql-eval/archive/new-evaluations-355-series-persons.sql

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT ID_T2S_EVALUATION_CATEGORY, ID_PARENT, DESCRIPTION FROM T_WC_T2S_EVALUATION_CATEGORY
WHERE ID_T2S_EVALUATION_CATEGORY IN (6, 16, 59, 60, 61, 62) ORDER BY 1;

SELECT ID_T2S_EVALUATION, LEFT(QUESTION, 70) AS QUESTION FROM T_WC_T2S_EVALUATION
WHERE LONG_DESC LIKE '%355-EXT%';

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'In which 2011 ABC series do fairy-tale characters live cursed, without their memories, in the Maine town of Storybrooke?',
       'Dans quelle série d''ABC de 2011 des personnages de contes de fées vivent-ils maudits, sans souvenirs, dans la ville de Storybrooke, dans le Maine ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (39272)',
       'Once Upon a Time (TMDb 39272), title + first air year shared with 287570 (2011). Series side of FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'In which 2011 ABC series do fairy-tale characters live cursed, without their memories, in the Maine town of Storybrooke?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'In which 2011 series does Emily VanCamp return to the Hamptons under a false name to destroy the family that framed her father?',
       'Dans quelle série de 2011 Emily VanCamp revient-elle dans les Hamptons sous un faux nom pour détruire la famille qui a piégé son père ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (39358)',
       'Revenge (TMDb 39358), title + first air year shared with the Russian Mest (130552, 2011). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'In which 2011 series does Emily VanCamp return to the Hamptons under a false name to destroy the family that framed her father?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which 2020 Netflix series adapted from Harlan Coben starts when a mysterious woman tells Richard Armitage''s character a devastating secret about his wife?',
       'Quelle série Netflix de 2020 adaptée de Harlan Coben commence quand une inconnue révèle au personnage de Richard Armitage un terrible secret sur sa femme ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (96608)',
       'The Stranger (TMDb 96608), title + first air year shared with 99282 (2020). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which 2020 Netflix series adapted from Harlan Coben starts when a mysterious woman tells Richard Armitage''s character a devastating secret about his wife?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'In which 2012 Canadian series does Rachel Nichols play a police officer from 2077 stranded in present-day Vancouver?',
       'Dans quelle série canadienne de 2012 Rachel Nichols joue-t-elle une policière de 2077 bloquée dans le Vancouver d''aujourd''hui ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (43020)',
       'Continuum (TMDb 43020), title + first air year shared with 56045 (2012). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'In which 2012 Canadian series does Rachel Nichols play a police officer from 2077 stranded in present-day Vancouver?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'In which 2007 NBC series does Damian Lewis play a detective back on the force after twelve years in prison for a murder he did not commit?',
       'Dans quelle série de NBC de 2007 Damian Lewis joue-t-il un inspecteur réintégré après douze ans de prison pour un meurtre qu''il n''a pas commis ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (3797)',
       'Life (TMDb 3797), title + first air year shared with a Japanese Life (9670, 2007). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'In which 2007 NBC series does Damian Lewis play a detective back on the force after twelve years in prison for a murder he did not commit?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which 2021 horror anthology series follows a Black family who move into an all-white Compton neighbourhood in 1953?',
       'Quelle série d''horreur anthologique de 2021 suit une famille noire qui s''installe en 1953 dans un quartier entièrement blanc de Compton ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (120462)',
       'Them (Little Marvin, TMDb 120462), title + first air year shared with an Iranian series (129709, 2021). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which 2021 horror anthology series follows a Black family who move into an all-white Compton neighbourhood in 1953?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which 2021 anime series follows a popular high-school girl and a gloomy classmate who discover each other''s hidden sides?',
       'Quelle série d''animation japonaise de 2021 suit une lycéenne populaire et un camarade taciturne qui découvrent chacun la face cachée de l''autre ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (110070)',
       'Horimiya anime (TMDb 110070), title + first air year shared with 113980 (2021), both with the Japanese original title: credits and cast decide. FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which 2021 anime series follows a popular high-school girl and a gloomy classmate who discover each other''s hidden sides?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which 2017 CW reboot follows the feud between Fallon Carrington and her billionaire father''s new wife Cristal?',
       'Quel remake de 2017 diffusé sur The CW suit la guerre entre Fallon Carrington et Cristal, la nouvelle épouse de son père milliardaire ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (72002)',
       'Dynasty (TMDb 72002), title + first air year shared with the Mexican Los Morales (73267, 2017). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which 2017 CW reboot follows the feud between Fallon Carrington and her billionaire father''s new wife Cristal?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'In which 2019 Netflix series does a Canadian teenager search for his girlfriend in a post-apocalyptic Glendale, with Matthew Broderick as his principal?',
       'Dans quelle série Netflix de 2019 un adolescent canadien cherche-t-il sa petite amie dans un Glendale post-apocalyptique, avec Matthew Broderick en proviseur ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (83478)',
       'Daybreak (TMDb 83478), title + first air year shared with a Chinese series (110690, 2019). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'In which 2019 Netflix series does a Canadian teenager search for his girlfriend in a post-apocalyptic Glendale, with Matthew Broderick as his principal?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which 2007 Canadian family drama follows Amy Fleming, who inherited her late mother''s gift for healing horses, on a ranch in Alberta?',
       'Quelle série familiale canadienne de 2007 suit Amy Fleming, qui a hérité du don de sa mère disparue pour soigner les chevaux, dans un ranch de l''Alberta ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (14929)',
       'Heartland (CBC, TMDb 14929), title + first air year shared with the American Heartland (2756, 2007). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which 2007 Canadian family drama follows Amy Fleming, who inherited her late mother''s gift for healing horses, on a ranch in Alberta?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which 2007 TNT medical drama stars Treat Williams as a transplant surgeon?',
       'Quelle série médicale de TNT de 2007 met en scène Treat Williams en chirurgien spécialiste des greffes ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (2756)',
       'Reverse case of the Heartland pair: the American Heartland (TMDb 2756, 289 IMDb votes) must win on its cast against the Canadian one (14929, 23 K votes), never lose to popularity. FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which 2007 TNT medical drama stars Treat Williams as a transplant surgeon?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'In which 2025 German Netflix series does a family move into a 1970s smart house whose AI housekeeper becomes possessive?',
       'Dans quelle série allemande Netflix de 2025 une famille emménage-t-elle dans une maison connectée des années 1970 dont l''intendante virtuelle devient possessive ?',
       1, 1, 1, 62, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_SERIE IN (248982)',
       'Cassandra (TMDb 248982), title + first air year shared with 288042 (2025). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'In which 2025 German Netflix series does a family move into a 1970s smart house whose AI housekeeper becomes possessive?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Serie Heartland (2007)',
       'Série Heartland (2007)',
       1, 0, 0, 6, 0, CURDATE(), NOW(),
       'COUNT(*) == 2 AND ID_SERIE IN (14929, 2756)',
       'Control of the series side of FASTAPI-TEXT2SQL-355 (355-EXT): a bare title + year typed by the user carries nothing to choose with, so both homonyms stay.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Serie Heartland (2007)') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Who is the singer nicknamed the King of Pop, who made the moonwalk famous?',
       'Qui est le chanteur surnommé le roi de la pop, qui a rendu célèbre le moonwalk ?',
       1, 1, 1, 61, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_PERSON IN (82702)',
       'Michael Jackson (TMDb 82702), name + birth year shared with a British television executive (1997098, 1958): the rewrite Person Michael Jackson born in 1958 returns both. Person side of FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Who is the singer nicknamed the King of Pop, who made the moonwalk famous?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which British television executive ran Channel 4 and BBC Two before moving to American television?',
       'Quel dirigeant de télévision britannique a dirigé Channel 4 et BBC Two avant de partir pour la télévision américaine ?',
       1, 1, 1, 61, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_PERSON IN (1997098)',
       'Reverse case of the Michael Jackson pair (TMDb 1997098, popularity 0.12 against 4.40): must win on what the model knows, never lose to popularity. FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which British television executive ran Channel 4 and BBC Two before moving to American television?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which British director, who began in advertising, made the film about an American student jailed in a Turkish prison?',
       'Quel réalisateur britannique, venu de la publicité, a tourné le film sur un étudiant américain emprisonné en Turquie ?',
       1, 1, 1, 61, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_PERSON IN (9168)',
       'Alan Parker the director (TMDb 9168), name + birth year 1944 shared with a sound technician (1714546) who is MORE popular (2.05 against 1.41): a popularity pick fails. FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which British director, who began in advertising, made the film about an American student jailed in a Turkish prison?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which English actor plays Ron Weasley''s father in the Harry Potter films and a crime-solving Catholic priest on BBC television?',
       'Quel acteur anglais joue le père de Ron Weasley dans les films Harry Potter et un prêtre catholique détective à la télévision de la BBC ?',
       1, 1, 1, 61, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_PERSON IN (20999)',
       'Mark Williams the actor (TMDb 20999), name + birth year 1959 shared with an American producer (206574). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which English actor plays Ron Weasley''s father in the Harry Potter films and a crime-solving Catholic priest on BBC television?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which Disney animation director co-directed the films about a dog who believes he has superpowers and about a Polynesian girl who sails across the ocean?',
       'Quel réalisateur de Disney a coréalisé les films sur un chien persuadé d''avoir des superpouvoirs et sur une jeune Polynésienne qui traverse l''océan ?',
       1, 1, 1, 61, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_PERSON IN (70238)',
       'Chris Williams the director (TMDb 70238, Bolt, Moana), name + birth year 1967 shared with an actor (1214427). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which Disney animation director co-directed the films about a dog who believes he has superpowers and about a Polynesian girl who sails across the ocean?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which English actor played the South African villain of the third Lethal Weapon film and the corrupt governor in The Mask of Zorro?',
       'Quel acteur anglais a joué le méchant sud-africain du troisième L''Arme fatale et le gouverneur corrompu du Masque de Zorro ?',
       1, 1, 1, 61, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_PERSON IN (14344)',
       'Stuart Wilson the actor (TMDb 14344), name + birth year 1946 shared with a sound technician (1568519). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which English actor played the South African villain of the third Lethal Weapon film and the corrupt governor in The Mask of Zorro?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which American director, blacklisted in the 1950s, directed Doris Day and Rock Hudson in a comedy about a shared telephone line?',
       'Quel réalisateur américain, inscrit sur la liste noire dans les années 1950, a dirigé Doris Day et Rock Hudson dans une comédie sur une ligne téléphonique partagée ?',
       1, 1, 1, 61, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_PERSON IN (123401)',
       'Michael Gordon the director (TMDb 123401, Pillow Talk), name + birth year 1909 shared with a British editor (1196027) who is MORE popular (1.54 against 0.61). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which American director, blacklisted in the 1950s, directed Doris Day and Rock Hudson in a comedy about a shared telephone line?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which American screenwriter was nominated for an Oscar for the black-and-white road film about an old man convinced he has won a sweepstakes prize in Nebraska?',
       'Quel scénariste américain a été nommé à l''Oscar pour le road movie en noir et blanc sur un vieil homme persuadé d''avoir gagné un concours au Nebraska ?',
       1, 1, 1, 61, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_PERSON IN (1538366)',
       'Bob Nelson the screenwriter (TMDb 1538366, Nebraska), name + birth year 1958 shared with an actor (104414). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which American screenwriter was nominated for an Oscar for the black-and-white road film about an old man convinced he has won a sweepstakes prize in Nebraska?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which Indian director made a Bollywood heist film inspired by Reservoir Dogs, with Amitabh Bachchan and Sanjay Dutt?',
       'Quel réalisateur indien a tourné un film de casse de Bollywood inspiré de Reservoir Dogs, avec Amitabh Bachchan et Sanjay Dutt ?',
       1, 1, 1, 61, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_PERSON IN (1770592)',
       'Sanjay Gupta the director (TMDb 1770592, Kaante), name + birth year 1969 shared with 1230057 (US). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which Indian director made a Bollywood heist film inspired by Reservoir Dogs, with Amitabh Bachchan and Sanjay Dutt?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which Israeli novelist won the International Booker Prize for a novel about a stand-up comedian''s last show?',
       'Quel romancier israélien a reçu l''International Booker Prize pour un roman sur le dernier spectacle d''un humoriste ?',
       1, 1, 1, 61, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_PERSON IN (2107858)',
       'David Grossman the novelist (TMDb 2107858), name + birth year 1954 shared with an American television director (43954) who is MORE popular (0.78 against 0.24). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which Israeli novelist won the International Booker Prize for a novel about a stand-up comedian''s last show?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which Canadian actor and director made a film about the rise and fall of the BlackBerry smartphone?',
       'Quel acteur et réalisateur canadien a tourné un film sur l''ascension et la chute du smartphone BlackBerry ?',
       1, 1, 1, 61, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_PERSON IN (1144092)',
       'Matt Johnson (TMDb 1144092, BlackBerry), name + birth year 1985 shared with a writer (66824). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which Canadian actor and director made a film about the rise and fall of the BlackBerry smartphone?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Which American writer-director of 1980s teen comedies set a film in a high-school library during a Saturday detention?',
       'Quel scénariste et réalisateur américain des comédies adolescentes des années 1980 a situé un film dans la bibliothèque d''un lycée pendant une retenue du samedi ?',
       1, 1, 1, 61, 0, CURDATE(), NOW(),
       'COUNT(*) == 1 AND ID_PERSON IN (11505)',
       'John Hughes the director (TMDb 11505), name + birth year 1950 shared with an actor (1599220). FASTAPI-TEXT2SQL-355, 355-EXT.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Which American writer-director of 1980s teen comedies set a film in a high-school library during a Saturday detention?') AS existing);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ID_T2S_EVALUATION_CATEGORY, DELETED,
   DAT_CREAT, TIM_UPDATED, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT 'Person John Hughes born in 1950',
       'Personne John Hughes née en 1950',
       1, 0, 0, 16, 0, CURDATE(), NOW(),
       'COUNT(*) == 2 AND ID_PERSON IN (11505, 1599220)',
       'Control of the person side of FASTAPI-TEXT2SQL-355 (355-EXT): a bare name + birth year typed by the user carries nothing to choose with, so both homonyms stay.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
                 WHERE QUESTION = 'Person John Hughes born in 1950') AS existing);

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, IS_SAMPLE, IS_SHOWCASE,
       LEFT(QUESTION, 50) AS QUESTION, ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION
WHERE LONG_DESC LIKE '%355-EXT%'
ORDER BY ID_T2S_EVALUATION;
