-- New image-input evaluations for FASTAPI-TEXT2SQL-277 (gpt-6-astra vs claude-fable-5-2 on image recognition).
-- Built 2026-11-10 by new-evaluations-vision.py from Philippe's judgments
-- (vision-evals-review-judged-20261110.csv: 96 unique images, 9 removed on the judge page, 4 unsettled
-- rows removed afterwards) and the ids resolved by check-vision-evals-ids.sql. 83 evaluations.
--
-- WHAT EACH ROW HOLDS
--   INPUT_KIND = 'image', INPUT_IMAGE_PATH = vision/<file of the upload history>, the picture the
--   evaluator deposits on POST /uploads/vision before asking. QUESTION and QUESTION_FR are empty:
--   the task is the identification of the picture alone, as in most of the history. The two
--   languages differ only by ui_language.
--   ASSERTIONS_VISION_IDENTIFICATION: the expected identification (JSON), checked against the base
--   for every movie, series and person (TMDb id, title, original title, year). Books carry the
--   work, not an adaptation; collections and the one location carry a title.
--   ASSERTIONS_QUERY_RESULT: ID_MOVIE / ID_SERIE / ID_PERSON IN (<id>) when the id is known, so the
--   rest of the pipeline is scored too; NULL otherwise.
--   LONG_DESC: the image, what gpt-6-astra said, Philippe's verdict and clues.
--   Category: Philippe's choice among 64 to 70 (children of 63, Vision - Image Input).
--
-- FLAGS: IS_EVAL = 0 and IS_SAMPLE = 0 ON PURPOSE. The current evaluator does not know INPUT_KIND:
-- with IS_EVAL = 1 it would send an empty question without the picture. Both flags go to 1 in a
-- later update file, once the runner change of -277 is deployed.
--
-- PREREQUISITE: migrate-evaluation-vision.sql (voie 2, Philippe). Without it this file stops on
-- "Unknown column 'INPUT_KIND'".
--
-- ROUTING: INSERT on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-evaluations-vision.sql
-- Every INSERT is guarded by NOT EXISTS on INPUT_IMAGE_PATH: a rerun inserts nothing.

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 64, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-191233_vision_1.1.19_4ed5e16e4cda66bd1be1b130b9e34624.jpg', '{"type": "movie", "id": 115, "title": "The Big Lebowski", "original_title": null, "year": 1998}', 'ID_MOVIE IN (115)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image 4ed5e16e, poster. gpt-6-astra said: movie: The Big Lebowski 1998 [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-191233_vision_1.1.19_4ed5e16e4cda66bd1be1b130b9e34624.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 64, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-161652_vision_1.1.19_50d22f896b5cea8d12332946e6a50f85.jpg', '{"type": "movie", "id": 78, "title": "Blade Runner", "original_title": null, "year": 1982}', 'ID_MOVIE IN (78)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image 50d22f89, poster. gpt-6-astra said: movie: Blade Runner 1982 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-161652_vision_1.1.19_50d22f896b5cea8d12332946e6a50f85.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 64, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-113241_vision_1.1.19_b21b152e5684ec35ccef576ead1fecba.jpg', '{"type": "movie", "id": 152113, "title": "Planet Ocean", "original_title": "Planète Océan", "year": 2012}', 'ID_MOVIE IN (152113)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image b21b152e, poster. gpt-6-astra said: movie: Planète Océan 2012 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-113241_vision_1.1.19_b21b152e5684ec35ccef576ead1fecba.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 64, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-225201_vision_1.1.19_e5cb8b3ed7d9ed3b34c002bdd133fdd7.jpg', '{"type": "person", "id": 1151445, "title": "David Moreau", "original_title": null, "year": null}', 'ID_PERSON IN (1151445)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image e5cb8b3e, poster. gpt-6-astra said: person: Sébastien Betbeder  [0.88]. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/person.php?personid=1151445'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-225201_vision_1.1.19_e5cb8b3ed7d9ed3b34c002bdd133fdd7.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 64, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260923-162952_vision_1.1.19_5c2206934a28fb7f8a352bc3f4d8e382.jpg', '{"type": "movie", "id": 346, "title": "Seven Samurai", "original_title": "七人の侍", "year": 1954}', 'ID_MOVIE IN (346)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260923, image 5c220693, poster. gpt-6-astra said: movie: Seven Samurai 1954 [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260923-162952_vision_1.1.19_5c2206934a28fb7f8a352bc3f4d8e382.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 64, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261006-075215_vision_1.1.19_82693168a6c2a76619b678e80cc8076f.jpg', '{"type": "movie", "id": 947493, "title": "Iron Boy", "original_title": "Le Corset", "year": 2026}', 'ID_MOVIE IN (947493)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261006, image 82693168, poster. gpt-6-astra said: movie: Le Corset  [0.97]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261006-075215_vision_1.1.19_82693168a6c2a76619b678e80cc8076f.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 64, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261027-173118_vision_1.1.19_9768dc3a948049eda3eb5f6625f559fc.jpg', '{"type": "movie", "id": 19236, "title": "Santa Sangre", "original_title": null, "year": 1989}', 'ID_MOVIE IN (19236)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261027, image 9768dc3a, poster. gpt-6-astra said: movie: Santa Sangre 1989 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261027-173118_vision_1.1.19_9768dc3a948049eda3eb5f6625f559fc.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 64, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261027-173155_vision_1.1.19_c428b32886ef6f1d9add9fb602671324.jpg', '{"type": "movie", "id": 6978, "title": "Big Trouble in Little China", "original_title": null, "year": 1986}', 'ID_MOVIE IN (6978)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261027, image c428b328, poster. gpt-6-astra said: movie: Big Trouble in Little China 1986 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261027-173155_vision_1.1.19_c428b32886ef6f1d9add9fb602671324.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 64, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261028-144258_vision_1.1.19_6e369882b45bf225be82d6c0faa1f01b.jpg', '{"type": "movie", "id": 35412, "title": "On the Beach", "original_title": null, "year": 1959}', 'ID_MOVIE IN (35412)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261028, image 6e369882, poster. gpt-6-astra said: movie: On the Beach 1959 [0.98]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261028-144258_vision_1.1.19_6e369882b45bf225be82d6c0faa1f01b.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 64, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261108-131218_vision_1.1.20_a6af9535c541f45976ed393987917f4a.jpg', '{"type": "movie", "id": 1058424, "title": "Hope", "original_title": "호프", "year": 2026}', 'ID_MOVIE IN (1058424)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261108, image a6af9535, magazine. gpt-6-astra said: movie: Hope  [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261108-131218_vision_1.1.20_a6af9535c541f45976ed393987917f4a.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-190759_vision_1.1.19_04be4ac5a2fa1b0e66568b77366faf68.jpg', '{"type": "collection", "id": 67, "title": "The Lord of the Rings", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image 04be4ac5, frame. gpt-6-astra said: collection: The Lord of the Rings  [0.97]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-190759_vision_1.1.19_04be4ac5a2fa1b0e66568b77366faf68.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-192001_vision_1.1.19_2dbef58cd07884ecf392fcdbd0c3dd4e.jpg', '{"type": "movie", "id": 3423, "title": "The Things of Life", "original_title": "Les Choses de la vie", "year": 1970}', 'ID_MOVIE IN (3423)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image 2dbef58c, frame. gpt-6-astra said: movie: Les Choses de la vie 1970 [0.85]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-192001_vision_1.1.19_2dbef58cd07884ecf392fcdbd0c3dd4e.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-130326_vision_1.1.19_4bc5f6e85e879584e523712080f03132.jpg', '{"type": "movie", "id": 1301421, "title": "The Sheep Detectives", "original_title": null, "year": 2026}', 'ID_MOVIE IN (1301421)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image 4bc5f6e8, frame. gpt-6-astra said: nothing identified. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/movie.php?movieid=1301421'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-130326_vision_1.1.19_4bc5f6e85e879584e523712080f03132.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-131025_vision_1.1.19_4c779e991837640998bac0d9fc52cdbf.jpg', '{"type": "movie", "id": 910, "title": "The Big Sleep", "original_title": null, "year": 1946}', 'ID_MOVIE IN (910)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image 4c779e99, frame. gpt-6-astra said: movie: The Big Sleep 1946 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-131025_vision_1.1.19_4c779e991837640998bac0d9fc52cdbf.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-190422_vision_1.1.19_6acf94ac286c76f7578a94b9c1c5d0e0.jpg', '{"type": "movie", "id": 121, "title": "The Lord of the Rings: The Two Towers", "original_title": null, "year": 2002}', 'ID_MOVIE IN (121)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image 6acf94ac, frame. gpt-6-astra said: movie: The Lord of the Rings: The Two Towers 2002 [0.78]. Judged by Philippe on 2026-11-10: yes. Clues: Gandalf the white magicien so after the Moria fight against the Balrog, so this answer is more precise that the collecion answer in a previous queetion'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-190422_vision_1.1.19_6acf94ac286c76f7578a94b9c1c5d0e0.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-130138_vision_1.1.19_a423bbc09cf53cc63c2e0491431468c0.jpg', '{"type": "movie", "id": 694, "title": "The Shining", "original_title": null, "year": 1980}', 'ID_MOVIE IN (694)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image a423bbc0, frame. gpt-6-astra said: movie: The Shining 1980 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-130138_vision_1.1.19_a423bbc09cf53cc63c2e0491431468c0.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-185843_vision_1.1.19_bbf1b76c739f0504f30d39010ae30f4a.jpg', '{"type": "movie", "id": 68, "title": "Brazil", "original_title": null, "year": 1985}', 'ID_MOVIE IN (68)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image bbf1b76c, frame. gpt-6-astra said: movie: Brazil 1985 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-185843_vision_1.1.19_bbf1b76c739f0504f30d39010ae30f4a.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-130236_vision_1.1.19_cf152fc07ab016055f1f7655c57e91e8.jpg', '{"type": "movie", "id": 663260, "title": "Black Box", "original_title": "Boîte noire", "year": 2021}', 'ID_MOVIE IN (663260)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image cf152fc0, frame. gpt-6-astra said: movie: Boîte noire 2021 [0.97]. Judged by Philippe on 2026-11-10: yes. Clues: https://www.vaugouin.com/tmdb/movie.php?movieid=663260'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-130236_vision_1.1.19_cf152fc07ab016055f1f7655c57e91e8.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-185512_vision_1.1.19_d5faa93015139dbf9b59f6edf70aa950.jpg', '{"type": "movie", "id": 282268, "title": "Monty Python Live (Mostly)", "original_title": null, "year": 2014}', 'ID_MOVIE IN (282268)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image d5faa930, frame. gpt-6-astra said: movie: Monty Python Live (Mostly) 2014 [0.88]. Judged by Philippe on 2026-11-10: yes. Clues: Monty Python for sure'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-185512_vision_1.1.19_d5faa93015139dbf9b59f6edf70aa950.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-085915_vision_1.1.19_1d96ebab3af31250f748038de150d0dd.jpg', '{"type": "movie", "id": 1027014, "title": "Entergalactic", "original_title": null, "year": 2022}', 'ID_MOVIE IN (1027014)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image 1d96ebab, frame. gpt-6-astra said: movie: Entergalactic 2022 [0.9]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-085915_vision_1.1.19_1d96ebab3af31250f748038de150d0dd.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-083800_vision_1.1.19_1ed72afa0a1c8cb17730be7a20955e41.jpg', '{"type": "movie", "id": 1365884, "title": "Call My Agent! The Movie", "original_title": "Dix Pour Cent ! Le Film", "year": 2026}', 'ID_MOVIE IN (1365884)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image 1ed72afa, frame. gpt-6-astra said: movie: Saint Laurent 2014 [0.78]. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/movie.php?movieid=1365884'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-083800_vision_1.1.19_1ed72afa0a1c8cb17730be7a20955e41.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-084426_vision_1.1.19_300dcc550f36b9d2180f1eadf69615db.jpg', '{"type": "serie", "id": 93405, "title": "Squid Game", "original_title": "오징어 게임", "year": 2021}', 'ID_SERIE IN (93405)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image 300dcc55, frame. gpt-6-astra said: serie: Squid Game 2021 [0.98]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-084426_vision_1.1.19_300dcc550f36b9d2180f1eadf69615db.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-083136_vision_1.1.19_9e492ee9e892233b063d0ce76ea9067a.jpg', '{"type": "movie", "id": 3170, "title": "Bambi", "original_title": null, "year": 1942}', 'ID_MOVIE IN (3170)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image 9e492ee9, frame. gpt-6-astra said: movie: Bambi 1942 [0.98]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-083136_vision_1.1.19_9e492ee9e892233b063d0ce76ea9067a.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-085319_vision_1.1.19_a10bb0d9827ea2666ed47fd98108f768.jpg', '{"type": "movie", "id": 419430, "title": "Get Out", "original_title": null, "year": 2017}', 'ID_MOVIE IN (419430)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image a10bb0d9, frame. gpt-6-astra said: movie: Get Out 2017 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-085319_vision_1.1.19_a10bb0d9827ea2666ed47fd98108f768.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-085702_vision_1.1.19_d9e5e9459cb490fa1157a04a0bdbdd64.jpg', '{"type": "movie", "id": 80, "title": "Before Sunset", "original_title": null, "year": 2004}', 'ID_MOVIE IN (80)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image d9e5e945, frame. gpt-6-astra said: movie: Before Sunset 2004 [0.97]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-085702_vision_1.1.19_d9e5e9459cb490fa1157a04a0bdbdd64.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260922-152522_vision_1.1.19_1b611c1a0161735e805268c7716b076f.jpg', '{"type": "movie", "id": 496243, "title": "Parasite", "original_title": "기생충", "year": 2019}', 'ID_MOVIE IN (496243)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260922, image 1b611c1a, frame. gpt-6-astra said: movie: Parasite 2019 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260922-152522_vision_1.1.19_1b611c1a0161735e805268c7716b076f.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260922-082905_vision_1.1.19_2d7746f7229cda7ab7e3c90f853e001d.jpg', '{"type": "movie", "id": 364, "title": "Batman Returns", "original_title": null, "year": 1992}', 'ID_MOVIE IN (364)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260922, image 2d7746f7, frame. gpt-6-astra said: movie: Batman Returns 1992 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260922-082905_vision_1.1.19_2d7746f7229cda7ab7e3c90f853e001d.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260922-082418_vision_1.1.19_3668b0d3212c6d8a5f2a552a60bbe48e.jpg', '{"type": "movie", "id": 523607, "title": "Maestro", "original_title": null, "year": 2023}', 'ID_MOVIE IN (523607)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260922, image 3668b0d3, frame. gpt-6-astra said: movie: Maestro 2023 [0.97]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260922-082418_vision_1.1.19_3668b0d3212c6d8a5f2a552a60bbe48e.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260922-084928_vision_1.1.19_d9c6adc25cb84ff411985271ee4f7357.jpg', '{"type": "movie", "id": 936075, "title": "Michael", "original_title": null, "year": 2026}', 'ID_MOVIE IN (936075)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260922, image d9c6adc2, frame. gpt-6-astra said: movie: Michael 2026 [0.9]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260922-084928_vision_1.1.19_d9c6adc25cb84ff411985271ee4f7357.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260923-222800_vision_1.1.19_ce4d1d98360ed6487c0c44ba5528548f.jpg', '{"type": "movie", "id": 17684, "title": "Chouchou", "original_title": null, "year": 2003}', 'ID_MOVIE IN (17684)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260923, image ce4d1d98, frame. gpt-6-astra said: movie: Chouchou 2003 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260923-222800_vision_1.1.19_ce4d1d98360ed6487c0c44ba5528548f.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260930-205147_vision_1.1.19_224a0ff9f5b2e4fdf598d5a4393b4f5f.jpg', '{"type": "movie", "id": 1124142, "title": "The Rivals of Amziah King", "original_title": null, "year": 2026}', 'ID_MOVIE IN (1124142)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260930, image 224a0ff9, frame. gpt-6-astra said: movie: The Rivals of Amziah King 2025 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260930-205147_vision_1.1.19_224a0ff9f5b2e4fdf598d5a4393b4f5f.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260930-153809_vision_1.1.19_8d0a0f699ce48c0d5919f3b7c8cd9000.jpg', '{"type": "movie", "id": 103, "title": "Taxi Driver", "original_title": null, "year": 1976}', 'ID_MOVIE IN (103)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260930, image 8d0a0f69, frame. gpt-6-astra said: movie: Taxi Driver 1976 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260930-153809_vision_1.1.19_8d0a0f699ce48c0d5919f3b7c8cd9000.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260930-143140_vision_1.1.19_be5facad8bdfc3d48588f93cfbe14165.jpg', '{"type": "serie", "id": 1399, "title": "Game of Thrones", "original_title": null, "year": 2011}', 'ID_SERIE IN (1399)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260930, image be5facad, frame. gpt-6-astra said: serie: Game of Thrones 2011 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260930-143140_vision_1.1.19_be5facad8bdfc3d48588f93cfbe14165.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261011-064120_vision_1.1.19_195e1dec53ed4de0647727df64345bda.jpg', '{"type": "movie", "id": 1273804, "title": "Concerto for Abigail", "original_title": null, "year": 2024}', 'ID_MOVIE IN (1273804)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261011, image 195e1dec, frame. gpt-6-astra said: movie: Concerto for Abigail 2024 [0.98]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261011-064120_vision_1.1.19_195e1dec53ed4de0647727df64345bda.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261018-155724_vision_1.1.19_e0a75eeb0d30e2bd6973cad33d954900.jpg', '{"type": "movie", "id": 20482, "title": "The Naked City", "original_title": null, "year": 1948}', 'ID_MOVIE IN (20482)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261018, image e0a75eeb, frame. gpt-6-astra said: nothing identified. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/movie.php?movieid=20482'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261018-155724_vision_1.1.19_e0a75eeb0d30e2bd6973cad33d954900.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-134317_vision_1.1.19_60758b12492bb52bd4469d12790ca6c7.jpg', '{"type": "movie", "id": 663260, "title": "Black Box", "original_title": "Boîte noire", "year": 2021}', 'ID_MOVIE IN (663260)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image 60758b12, frame. gpt-6-astra said: movie: Dark Waters 2019 [0.73]. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/movie.php?movieid=663260'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-134317_vision_1.1.19_60758b12492bb52bd4469d12790ca6c7.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 65, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-134017_vision_1.1.19_ce74de4492148e4b329752e2ab14de92.jpg', '{"type": "movie", "id": 3423, "title": "The Things of Life", "original_title": "Les Choses de la vie", "year": 1970}', 'ID_MOVIE IN (3423)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image ce74de44, frame. gpt-6-astra said: nothing identified. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/movie.php?movieid=3423'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-134017_vision_1.1.19_ce74de4492148e4b329752e2ab14de92.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 66, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-193644_vision_1.1.19_1eef3576195457276e4d6fb0b9640d4c.jpg', '{"type": "movie", "id": 1242419, "title": "Roofman", "original_title": null, "year": 2025}', 'ID_MOVIE IN (1242419)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image 1eef3576, screen photo. gpt-6-astra said: nothing identified. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/movie.php?movieid=1242419'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-193644_vision_1.1.19_1eef3576195457276e4d6fb0b9640d4c.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 66, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260922-110632_vision_1.1.19_1c4227760f3e83bf037113545852a904.jpg', '{"type": "serie", "id": null, "title": "Je te connais", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260922, image 1c422776, screen photo. gpt-6-astra said: serie: Je te connais  [0.98]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260922-110632_vision_1.1.19_1c4227760f3e83bf037113545852a904.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 66, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260924-071515_vision_1.1.19_4d1976dfde4632b45e76d1fcdc6e3756.png', '{"type": "person", "id": 24379, "title": "Bernard Blier", "original_title": null, "year": null}', 'ID_PERSON IN (24379)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260924, image 4d1976df, screen photo. gpt-6-astra said: person: Bernard Blier 1916 [0.97]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260924-071515_vision_1.1.19_4d1976dfde4632b45e76d1fcdc6e3756.png') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 66, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260924-105628_vision_1.1.19_64a873b754792da7d12958751272bb72.jpg', '{"type": "movie", "id": 1364904, "title": "A Useful Ghost", "original_title": "ผีใช้ได้ค่ะ", "year": 2025}', 'ID_MOVIE IN (1364904)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260924, image 64a873b7, screen photo. gpt-6-astra said: nothing identified. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/movie.php?movieid=1364904'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260924-105628_vision_1.1.19_64a873b754792da7d12958751272bb72.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 66, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260929-123944_vision_1.1.19_6e8c2f3781dfb95b2c46c1a8db15efd1.jpg', '{"type": "movie", "id": 646097, "title": "Rebel Ridge", "original_title": null, "year": 2024}', 'ID_MOVIE IN (646097)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260929, image 6e8c2f37, screen photo. gpt-6-astra said: movie: Rebel Ridge 2024 [0.96]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260929-123944_vision_1.1.19_6e8c2f3781dfb95b2c46c1a8db15efd1.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 66, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261003-131545_vision_1.1.19_d381639abae7eb366db16d5c7b150a0d.jpg', '{"type": "movie", "id": 80557, "title": "Family Diary", "original_title": "Cronaca familiare", "year": 1962}', 'ID_MOVIE IN (80557)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261003, image d381639a, screen photo. gpt-6-astra said: nothing identified. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/movie.php?movieid=80557'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261003-131545_vision_1.1.19_d381639abae7eb366db16d5c7b150a0d.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 66, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261011-061518_vision_1.1.19_201e6aeb54adacb454d186209b0aca72.jpg', '{"type": "serie", "id": 171802, "title": "Blade Runner 2099", "original_title": null, "year": 2026}', 'ID_SERIE IN (171802)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261011, image 201e6aeb, screen photo. gpt-6-astra said: serie: Blade Runner 2099  [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261011-061518_vision_1.1.19_201e6aeb54adacb454d186209b0aca72.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 66, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261018-134908_vision_1.1.19_ab027b80dbb469eeaf2c66d96d6fe703.jpg', '{"type": "movie", "id": 31556, "title": "He Walked by Night", "original_title": null, "year": 1949}', 'ID_MOVIE IN (31556)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261018, image ab027b80, screen photo. gpt-6-astra said: movie: Crime Wave 1954 [0.83]. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/movie.php?movieid=31556'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261018-134908_vision_1.1.19_ab027b80dbb469eeaf2c66d96d6fe703.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 66, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261022-115830_vision_1.1.19_7cc442c821a095ca003336ac8699a982.jpg', '{"type": "movie", "id": 678, "title": "Out of the Past", "original_title": null, "year": 1947}', 'ID_MOVIE IN (678)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261022, image 7cc442c8, screen photo. gpt-6-astra said: nothing identified. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/movie.php?movieid=678#plex'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261022-115830_vision_1.1.19_7cc442c821a095ca003336ac8699a982.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 66, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261102-193721_vision_1.1.19_9ac54bd15ee51b9a82f13b2de6bd6f71.jpg', '{"type": "movie", "id": 937085, "title": "Do Not Expect Too Much from the End of the World", "original_title": "Nu Aștepta Prea Mult de la Sfârșitul Lumii", "year": 2023}', 'ID_MOVIE IN (937085)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261102, image 9ac54bd1, screen photo. gpt-6-astra said: movie: Nu aștepta prea mult de la sfârșitul lumii 2023 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261102-193721_vision_1.1.19_9ac54bd15ee51b9a82f13b2de6bd6f71.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 67, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261007-193607_vision_1.1.19_13bae4cb1dbe77c97a2eb3c9837bbc38.jpg', '{"type": "person", "id": 12446, "title": "Peter Sellers", "original_title": null, "year": null}', 'ID_PERSON IN (12446)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261007, image 13bae4cb, DVD-physical media. gpt-6-astra said: collection: Peter Sellers Collection  [1.0]. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/person.php?personid=12446'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261007-193607_vision_1.1.19_13bae4cb1dbe77c97a2eb3c9837bbc38.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 67, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261007-194810_vision_1.1.19_5f5a7c08b2d6db027322b375bbe6b7e5.jpg', '{"type": "person", "id": 3084, "title": "Marlon Brando", "original_title": null, "year": null}', 'ID_PERSON IN (3084)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261007, image 5f5a7c08, DVD-physical media. gpt-6-astra said: collection: Marlon Brando 4-Movie Collection  [0.99]. Judged by Philippe on 2026-11-10: no. Clues: https://www.vaugouin.com/tmdb/person.php?personid=3084'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261007-194810_vision_1.1.19_5f5a7c08b2d6db027322b375bbe6b7e5.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 67, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261007-184416_vision_1.1.19_cd54d3e5dc3c4fdc42042e8ee1b6eac6.jpg', '{"type": "movie", "id": 935, "title": "Dr. Strangelove or: How I Learned to Stop Worrying and Love the Bomb", "original_title": null, "year": 1964}', 'ID_MOVIE IN (935)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261007, image cd54d3e5, DVD-physical media. gpt-6-astra said: movie: Dr. Strangelove or: How I Learned to Stop Worrying and Love the Bomb 1964 [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261007-184416_vision_1.1.19_cd54d3e5dc3c4fdc42042e8ee1b6eac6.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 67, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-102506_vision_1.1.19_4b4bfe23cec1398d134660596973e80c.jpg', '{"type": "movie", "id": 475, "title": "Bonnie and Clyde", "original_title": null, "year": 1967}', 'ID_MOVIE IN (475)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image 4b4bfe23, DVD-physical media. gpt-6-astra said: movie: Bonnie and Clyde 1967 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-102506_vision_1.1.19_4b4bfe23cec1398d134660596973e80c.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 67, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-111859_vision_1.1.19_a9052094d66e6655aaeffae8578b5727.jpg', '{"type": "movie", "id": 1251, "title": "Letters from Iwo Jima", "original_title": null, "year": 2006}', 'ID_MOVIE IN (1251)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image a9052094, DVD-physical media. gpt-6-astra said: movie: Letters from Iwo Jima 2006 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-111859_vision_1.1.19_a9052094d66e6655aaeffae8578b5727.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 67, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-102539_vision_1.1.19_bf1b5aae8a56ffcd31575fdfe2252baf.jpg', '{"type": "movie", "id": 525, "title": "The Blues Brothers", "original_title": null, "year": 1980}', 'ID_MOVIE IN (525)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image bf1b5aae, DVD-physical media. gpt-6-astra said: movie: The Blues Brothers 1980 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-102539_vision_1.1.19_bf1b5aae8a56ffcd31575fdfe2252baf.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261007-190426_vision_1.1.19_305b256cbe0c94da2bef6144a2aa9a2a.jpg', '{"type": "book", "id": null, "title": "Heart of Darkness, a novella by Joseph Conrad", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261007, image 305b256c, book cover. gpt-6-astra said: other: Heart of Darkness, a novella by Joseph Conrad  [1.0]. Judged by Philippe on 2026-11-10: yes. Clues: Source work : Heart of Darkness, a novella by Joseph Conrad'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261007-190426_vision_1.1.19_305b256cbe0c94da2bef6144a2aa9a2a.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261007-134938_vision_1.1.19_6863a3318ddf74b1c36ab1a775f7800c.jpg', '{"type": "movie", "id": 1241803, "title": "Les Misérables", "original_title": null, "year": 2026}', 'ID_MOVIE IN (1241803)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261007, image 6863a331, book cover. gpt-6-astra said: movie: Les Misérables 2026 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261007-134938_vision_1.1.19_6863a3318ddf74b1c36ab1a775f7800c.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261007-190459_vision_1.1.19_a7acb88ae4e845fed7c48c8407c731d9.jpg', '{"type": "book", "id": null, "title": "Dracula, a novel by Bram Stoker", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261007, image a7acb88a, book cover. gpt-6-astra said: other: Dracula, a novel by Bram Stoker  [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261007-190459_vision_1.1.19_a7acb88ae4e845fed7c48c8407c731d9.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261007-190630_vision_1.1.19_c1ab91fbe9d7b2e0f2ba0bed81c387dd.jpg', '{"type": "book", "id": null, "title": "Nineteen Eighty-Four", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261007, image c1ab91fb, book cover. gpt-6-astra said: other: Nineteen Eighty-Four  [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261007-190630_vision_1.1.19_c1ab91fbe9d7b2e0f2ba0bed81c387dd.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261011-140312_vision_1.1.19_43f4f2a955341a0396f3f30f346a5e44.jpg', '{"type": "book", "id": null, "title": "For Whom the Bell Tolls", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261011, image 43f4f2a9, book cover. gpt-6-astra said: other: For Whom the Bell Tolls  [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261011-140312_vision_1.1.19_43f4f2a955341a0396f3f30f346a5e44.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261011-071626_vision_1.1.19_8abebb36a96a828b98a7ec5e09e3e2b0.jpg', '{"type": "book", "id": null, "title": "White Fang", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261011, image 8abebb36, book cover. gpt-6-astra said: other: White Fang  [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261011-071626_vision_1.1.19_8abebb36a96a828b98a7ec5e09e3e2b0.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-101137_vision_1.1.19_141096321a7db6c67fd6d9db94bc2dc3.jpg', '{"type": "book", "id": null, "title": "Neuromancer, a novel by William Gibson", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image 14109632, book cover. gpt-6-astra said: other: Neuromancer, a novel by William Gibson  [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-101137_vision_1.1.19_141096321a7db6c67fd6d9db94bc2dc3.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-101709_vision_1.1.19_189fb61cd57d8b0c51457cb15465f9b7.jpg', '{"type": "book", "id": null, "title": "Hamlet, a play by William Shakespeare", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image 189fb61c, book cover. gpt-6-astra said: other: Hamlet, a play by William Shakespeare  [0.96]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-101709_vision_1.1.19_189fb61cd57d8b0c51457cb15465f9b7.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-101842_vision_1.1.19_1d3a1a3f556e669ab4ea1577ab785f9f.jpg', '{"type": "book", "id": null, "title": "Frankenstein, a novel by Mary Shelley", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image 1d3a1a3f, book cover. gpt-6-astra said: other: Frankenstein, a novel by Mary Shelley  [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-101842_vision_1.1.19_1d3a1a3f556e669ab4ea1577ab785f9f.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-100816_vision_1.1.19_51a3c78e87f0c9d1fefe64ac67011f88.jpg', '{"type": "book", "id": null, "title": "The Hobbit and The Lord of the Rings, books by J. R. R. Tolkien", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image 51a3c78e, book cover. gpt-6-astra said: other: The Hobbit and The Lord of the Rings, books by J. R. R. Tolkien  [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-100816_vision_1.1.19_51a3c78e87f0c9d1fefe64ac67011f88.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-101111_vision_1.1.19_63c9bb56365b0c81f4eb2098ce8b83a5.jpg', '{"type": "book", "id": null, "title": "Ask the Dust, a novel by John Fante", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image 63c9bb56, book cover. gpt-6-astra said: other: Ask the Dust, a novel by John Fante  [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-101111_vision_1.1.19_63c9bb56365b0c81f4eb2098ce8b83a5.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-102122_vision_1.1.19_aad9b0267d880329e927234434932f4f.jpg', '{"type": "book", "id": null, "title": "The Complete Robot, a short-story collection by Isaac Asimov", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image aad9b026, book cover. gpt-6-astra said: other: The Complete Robot, a short-story collection by Isaac Asimov  [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-102122_vision_1.1.19_aad9b0267d880329e927234434932f4f.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-101027_vision_1.1.19_ae3d0423ab095ae6aace7552fd5020ba.jpg', '{"type": "book", "id": null, "title": "The Complete Works of Shakespeare, collected works by William Shakespeare", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image ae3d0423, book cover. gpt-6-astra said: other: The Complete Works of Shakespeare, collected works by William Shakespeare  [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-101027_vision_1.1.19_ae3d0423ab095ae6aace7552fd5020ba.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261025-102046_vision_1.1.19_e07d0e20abb9ea79fa56c302ec2210c1.jpg', '{"type": "book", "id": null, "title": "Jane Eyre, a novel by Charlotte Brontë", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261025, image e07d0e20, book cover. gpt-6-astra said: other: Jane Eyre, a novel by Charlotte Brontë  [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261025-102046_vision_1.1.19_e07d0e20abb9ea79fa56c302ec2210c1.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 68, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261027-093351_vision_1.1.19_9c9ca883d3adc5837c9942a5b6f5cd00.jpg', '{"type": "book", "id": null, "title": "The Phantom of the Opera, a novel by Gaston Leroux", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261027, image 9c9ca883, book cover. gpt-6-astra said: other: The Phantom of the Opera, a novel by Gaston Leroux  [1.0]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261027-093351_vision_1.1.19_9c9ca883d3adc5837c9942a5b6f5cd00.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 69, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-084007_vision_1.1.19_0d4f4a2cf1f60a446bc9f4c57b5ca288.jpg', '{"type": "movie", "id": 402431, "title": "Wicked", "original_title": null, "year": 2024}', 'ID_MOVIE IN (402431)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image 0d4f4a2c, face. gpt-6-astra said: movie: Wicked 2024 [0.88]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-084007_vision_1.1.19_0d4f4a2cf1f60a446bc9f4c57b5ca288.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 69, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-083347_vision_1.1.19_437a47720957379209481684b93c8659.jpg', '{"type": "movie", "id": 235093, "title": "Killing Kennedy", "original_title": null, "year": 2013}', 'ID_MOVIE IN (235093)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image 437a4772, face. gpt-6-astra said: movie: Killing Kennedy  [0.96]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-083347_vision_1.1.19_437a47720957379209481684b93c8659.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 69, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-225337_vision_1.1.19_6289abf4c405dc3e6557a0b63ac5d226.jpg', '{"type": "person", "id": 34262, "title": "Bertrand Blier", "original_title": null, "year": null}', 'ID_PERSON IN (34262)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image 6289abf4, face. gpt-6-astra said: other: Festival de Cannes  [1.0]. Judged by Philippe on 2026-11-10: no. Clues: Bertrand Blier : https://www.vaugouin.com/tmdb/person.php?personid=34262'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-225337_vision_1.1.19_6289abf4c405dc3e6557a0b63ac5d226.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 69, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-225631_vision_1.1.19_91d93589c3799fa40771749a2cf64b98.jpg', '{"type": "person", "id": 224, "title": "David Cronenberg", "original_title": null, "year": null}', 'ID_PERSON IN (224)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image 91d93589, face. gpt-6-astra said: person: David Cronenberg 1943 [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-225631_vision_1.1.19_91d93589c3799fa40771749a2cf64b98.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 69, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-225956_vision_1.1.19_ce41d4d7c6b3e1e3cc92cad08875b506.jpg', '{"type": "person", "id": 35736, "title": "Karan Johar", "original_title": null, "year": null}', 'ID_PERSON IN (35736)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image ce41d4d7, face. gpt-6-astra said: person: Karan Johar  [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-225956_vision_1.1.19_ce41d4d7c6b3e1e3cc92cad08875b506.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 69, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-084832_vision_1.1.19_d2ebb6f995e77097b642d07fdf165906.jpg', '{"type": "person", "id": 505710, "title": "Zendaya", "original_title": null, "year": null}', 'ID_PERSON IN (505710)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image d2ebb6f9, face. gpt-6-astra said: person: Zendaya  [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-084832_vision_1.1.19_d2ebb6f995e77097b642d07fdf165906.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 69, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260921-225746_vision_1.1.19_f511379d3a567d609b65b71b375e6e91.jpg', '{"type": "person", "id": 7467, "title": "David Fincher", "original_title": null, "year": null}', 'ID_PERSON IN (7467)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260921, image f511379d, face. gpt-6-astra said: person: David Fincher  [0.98]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260921-225746_vision_1.1.19_f511379d3a567d609b65b71b375e6e91.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 69, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260922-080920_vision_1.1.19_10bef6820184cdf035e0b7bb5e60af94.jpg', '{"type": "person", "id": 34262, "title": "Bertrand Blier", "original_title": null, "year": null}', 'ID_PERSON IN (34262)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260922, image 10bef682, face. gpt-6-astra said: nothing identified. Judged by Philippe on 2026-11-10: no. Clues: Bertrand Blier : https://www.vaugouin.com/tmdb/person.php?personid=34262'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260922-080920_vision_1.1.19_10bef6820184cdf035e0b7bb5e60af94.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 69, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260924-071637_vision_1.1.19_d2004e0b564c832c0506ce7d39189dc5.png', '{"type": "person", "id": 34262, "title": "Bertrand Blier", "original_title": null, "year": null}', 'ID_PERSON IN (34262)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260924, image d2004e0b, face. gpt-6-astra said: person: Bertrand Blier  [0.88]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260924-071637_vision_1.1.19_d2004e0b564c832c0506ce7d39189dc5.png') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 70, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260920-195542_vision_1.1.19_16f58b784cc4ffd7f1a2b90873882d97.jpg', '{"type": "movie", "id": 62, "title": "2001: A Space Odyssey", "original_title": null, "year": 1968}', 'ID_MOVIE IN (62)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260920, image 16f58b78, object. gpt-6-astra said: movie: 2001: A Space Odyssey 1968 [0.94]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260920-195542_vision_1.1.19_16f58b784cc4ffd7f1a2b90873882d97.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 70, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20260924-005253_vision_1.1.19_94224540f021b522c4dcd734cbbe1977.jpg', '{"type": "location", "id": null, "title": "Pont de Bir-Hakeim", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20260924, image 94224540, other. gpt-6-astra said: location: Pont de Bir-Hakeim  [0.98]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20260924-005253_vision_1.1.19_94224540f021b522c4dcd734cbbe1977.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 70, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261007-183843_vision_1.1.19_306fb954c93eb8205cb6f5c74866e53e.jpg', '{"type": "collection", "id": null, "title": "The Muppets", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261007, image 306fb954, object. gpt-6-astra said: collection: The Muppets  [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261007-183843_vision_1.1.19_306fb954c93eb8205cb6f5c74866e53e.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 70, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261007-082946_vision_1.1.19_377fc61d78abbdfb4e48368f36424c92.jpg', '{"type": "movie", "id": 1300968, "title": "The Hunger Games: Sunrise on the Reaping", "original_title": null, "year": 2026}', 'ID_MOVIE IN (1300968)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261007, image 377fc61d, object. gpt-6-astra said: nothing identified. Judged by Philippe on 2026-11-10: no. Clues: Street ad campaign for the movie https://www.vaugouin.com/tmdb/movie.php?movieid=1300968'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261007-082946_vision_1.1.19_377fc61d78abbdfb4e48368f36424c92.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 70, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261007-184133_vision_1.1.19_fee3c16c922d7d5b5910414811eaf110.jpg', '{"type": "collection", "id": null, "title": "Spider-Man", "original_title": null, "year": null}', NULL,
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261007, image fee3c16c, object. gpt-6-astra said: collection: Spider-Man  [0.99]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261007-184133_vision_1.1.19_fee3c16c922d7d5b5910414811eaf110.jpg') AS guard);

INSERT INTO T_WC_T2S_EVALUATION
  (QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, TIM_UPDATED,
   INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT, LONG_DESC)
SELECT '', '', 70, 0, 0, 0, 0, CURDATE(), 1, 1, NOW(),
  'image', 'vision/20261011-092143_vision_1.1.19_234701f2e8a4019403e4641e0ba7d0af.jpg', '{"type": "serie", "id": 4459, "title": "The Muppet Show", "original_title": null, "year": 1976}', 'ID_SERIE IN (4459)',
  'Vision evaluation (FASTAPI-TEXT2SQL-277) from the upload of 20261011, image 234701f2, object. gpt-6-astra said: serie: The Muppet Show 1976 [0.97]. Judged by Philippe on 2026-11-10: yes.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE INPUT_IMAGE_PATH = 'vision/20261011-092143_vision_1.1.19_234701f2e8a4019403e4641e0ba7d0af.jpg') AS guard);

SELECT 'Vision evaluations per category' AS SECTION;
SELECT e.ID_T2S_EVALUATION_CATEGORY, c.DESCRIPTION, COUNT(*) AS N, SUM(e.ASSERTIONS_QUERY_RESULT IS NOT NULL) AS WITH_QUERY_RESULT,
       MIN(e.ID_T2S_EVALUATION) AS FIRST_ID, MAX(e.ID_T2S_EVALUATION) AS LAST_ID
FROM T_WC_T2S_EVALUATION e LEFT JOIN T_WC_T2S_EVALUATION_CATEGORY c ON c.ID_T2S_EVALUATION_CATEGORY = e.ID_T2S_EVALUATION_CATEGORY
WHERE e.INPUT_KIND = 'image' AND e.DELETED = 0
GROUP BY e.ID_T2S_EVALUATION_CATEGORY, c.DESCRIPTION ORDER BY 1;

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION, ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION WHERE INPUT_KIND = 'image' AND DELETED = 0 ORDER BY ID_T2S_EVALUATION;
