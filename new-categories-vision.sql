-- New evaluation categories for the image-input (computer vision) evaluations of FASTAPI-TEXT2SQL-277.
-- Approved by Philippe on 2026-11-10 (the eight children below), written 2026-11-10.
--
-- WHAT THIS FILE DOES
-- Adds one parent, "Vision - Image Input", under 1 (Root English evaluations), and eight children
-- under it. A vision evaluation starts from a picture (INPUT_IMAGE_PATH, added by the -277
-- migration) and is scored first on what the picture was identified as. The existing categories
-- 13, 23 and 24 ("Images queries") are text questions whose ANSWER is a poster or a portrait:
-- they stay as they are and are not reused here.
--
-- The children follow the kind of picture, because that is what makes a vision task easy or hard
-- (printed title vs bare frame vs face), and what a model comparison (gpt-6-astra vs
-- claude-fable-5-2) has to read per family:
--   Posters and Printed Media      posters, street posters, magazine covers (title printed)
--   Film and Series Frames         a frame or still, no printed title
--   Screen Photos                  a phone photo of a TV, tablet or cinema screen
--   Physical Media                 DVD and Blu-ray shelves, box sets, spines
--   Source Books and Adaptations   book covers: the work is a book, the answer its adaptations
--   Faces                          a person recognised from the face alone
--   Iconic Objects                 toys, figurines, props, emblems (HAL eye, a fawn, a charm)
--   Unidentifiable                 pictures with no reliable answer: the expected outcome is an
--                                  honest "not identified", never a guess
--
-- ROUTING: INSERT on T_WC_T2S_EVALUATION_CATEGORY only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/new-categories-vision.sql
-- Commit and push before running. Expected: 9 rows inserted on the first run, 0 on a rerun.
--
-- CONVENTIONS: auto-increment id (58 is free but is not reused); every INSERT is guarded by NOT
-- EXISTS on DESCRIPTION, so the file can be rerun; the children find their parent by its
-- DESCRIPTION; LANG NULL like every category; DISPLAY_ORDER 70 to 78, after the current maximum
-- (61); DELETED = 0; owner 1.

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO T_WC_T2S_EVALUATION_CATEGORY
  (DESCRIPTION, DESCRIPTION_FR, LANG, ID_PARENT, DELETED, DISPLAY_ORDER, ID_CREATOR, DAT_CREAT, ID_OWNER, TIM_UPDATED, ID_USER_UPDATED)
SELECT 'Vision - Image Input', 'Vision - Questions à partir d''une image', NULL, 1, 0, 70, 1, CURDATE(), 1, NOW(), 1
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY
    WHERE DESCRIPTION = 'Vision - Image Input') AS guard);

INSERT INTO T_WC_T2S_EVALUATION_CATEGORY
  (DESCRIPTION, DESCRIPTION_FR, LANG, ID_PARENT, DELETED, DISPLAY_ORDER, ID_CREATOR, DAT_CREAT, ID_OWNER, TIM_UPDATED, ID_USER_UPDATED)
SELECT c.DESCRIPTION, c.DESCRIPTION_FR, NULL, p.ID_T2S_EVALUATION_CATEGORY, 0, c.DISPLAY_ORDER, 1, CURDATE(), 1, NOW(), 1
FROM (
  SELECT 'Vision - Posters and Printed Media' AS DESCRIPTION, 'Vision - Affiches et imprimés' AS DESCRIPTION_FR, 71 AS DISPLAY_ORDER
  UNION ALL SELECT 'Vision - Film and Series Frames', 'Vision - Images de films et de séries', 72
  UNION ALL SELECT 'Vision - Screen Photos', 'Vision - Photos d''écran', 73
  UNION ALL SELECT 'Vision - Physical Media', 'Vision - Supports physiques', 74
  UNION ALL SELECT 'Vision - Source Books and Adaptations', 'Vision - Livres sources et adaptations', 75
  UNION ALL SELECT 'Vision - Faces', 'Vision - Visages', 76
  UNION ALL SELECT 'Vision - Iconic Objects', 'Vision - Objets iconiques', 77
  UNION ALL SELECT 'Vision - Unidentifiable', 'Vision - Images non identifiables', 78
) AS c
JOIN (SELECT ID_T2S_EVALUATION_CATEGORY FROM T_WC_T2S_EVALUATION_CATEGORY
      WHERE DESCRIPTION = 'Vision - Image Input' AND DELETED = 0) AS p
WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT DESCRIPTION FROM T_WC_T2S_EVALUATION_CATEGORY) AS guard
  WHERE guard.DESCRIPTION = c.DESCRIPTION);

-- The parent and its eight children, with the ids to use in the vision evaluations.
SELECT ID_T2S_EVALUATION_CATEGORY, ID_PARENT, DISPLAY_ORDER, DESCRIPTION, DESCRIPTION_FR
  FROM T_WC_T2S_EVALUATION_CATEGORY
  WHERE DESCRIPTION LIKE 'Vision - %'
  ORDER BY DISPLAY_ORDER;
