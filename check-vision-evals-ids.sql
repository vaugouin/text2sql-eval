-- Resolve the expected entities of the vision evaluation candidates (FASTAPI-TEXT2SQL-277).
-- Input: vision-evals-review-judged-20261110.csv, judged by Philippe on 2026-11-10 (87 rows kept, 4 more removed on 2026-11-10: 13c5c715, 9d8f999c, 00c8a453, 904544ed; 83 rows).
-- Each row gives either a TMDb id (from Philippe's vaugouin.com link, or from the result rows of an
-- accepted gpt-6-astra run) or, failing that, the title and year to look up. The output gives the
-- title, year and kind of each id, and the candidate ids of each title, so the expected answers of
-- new-evaluations-vision.sql are checked against the base before they are written.
-- SELECT only: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/check-vision-evals-ids.sql

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TEMPORARY TABLE tmp_vision_expect (
  PREFIX varchar(8), VERDICT varchar(3), KIND varchar(10), ID_ENTITY int, TITLE varchar(250), YEAR_HINT int
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO tmp_vision_expect VALUES
('4ed5e16e', 'yes', 'movie', 115, '', NULL),
('50d22f89', 'yes', 'movie', 78, '', NULL),
('b21b152e', 'yes', 'movie', 152113, '', NULL),
('e5cb8b3e', 'no', 'person', 1151445, '', NULL),
('5c220693', 'yes', 'movie', 346, '', NULL),
('82693168', 'yes', 'movie', 947493, '', NULL),
('9768dc3a', 'yes', 'movie', 19236, '', NULL),
('c428b328', 'yes', 'movie', 6978, '', NULL),
('6e369882', 'yes', 'movie', 35412, '', NULL),
('a6af9535', 'yes', 'movie', 1058424, '', NULL),
('04be4ac5', 'yes', '', NULL, 'The Lord of the Rings', NULL),
('2dbef58c', 'yes', 'movie', 3423, '', NULL),
('4bc5f6e8', 'no', 'movie', 1301421, '', NULL),
('4c779e99', 'yes', 'movie', 910, '', NULL),
('6acf94ac', 'yes', 'movie', 121, '', NULL),
('a423bbc0', 'yes', 'movie', 694, '', NULL),
('bbf1b76c', 'yes', 'movie', NULL, 'Brazil', 1985),
('cf152fc0', 'yes', 'movie', 663260, '', NULL),
('d5faa930', 'yes', 'movie', NULL, 'Monty Python Live (Mostly)', 2014),
('1d96ebab', 'yes', 'movie', 1027014, '', NULL),
('1ed72afa', 'no', 'movie', 1365884, '', NULL),
('300dcc55', 'yes', 'serie', 93405, '', NULL),
('9e492ee9', 'yes', 'movie', 3170, '', NULL),
('a10bb0d9', 'yes', 'movie', 419430, '', NULL),
('d9e5e945', 'yes', 'movie', 80, '', NULL),
('1b611c1a', 'yes', 'movie', 496243, '', NULL),
('2d7746f7', 'yes', 'movie', 364, '', NULL),
('3668b0d3', 'yes', 'movie', NULL, 'Maestro', 2023),
('d9c6adc2', 'yes', 'movie', 936075, '', NULL),
('ce4d1d98', 'yes', 'movie', 17684, '', NULL),
('224a0ff9', 'yes', 'movie', NULL, 'The Rivals of Amziah King', 2025),
('8d0a0f69', 'yes', 'movie', 103, '', NULL),
('be5facad', 'yes', 'serie', 1399, '', NULL),
('195e1dec', 'yes', 'movie', 1273804, '', NULL),
('e0a75eeb', 'no', 'movie', 20482, '', NULL),
('60758b12', 'no', 'movie', 663260, '', NULL),
('ce74de44', 'no', 'movie', 3423, '', NULL),
('1eef3576', 'no', 'movie', 1242419, '', NULL),
('1c422776', 'yes', 'serie', NULL, 'Je te connais', NULL),
('4d1976df', 'yes', 'person', 24379, '', NULL),
('64a873b7', 'no', 'movie', 1364904, '', NULL),
('6e8c2f37', 'yes', 'movie', 646097, '', NULL),
('d381639a', 'no', 'movie', 80557, '', NULL),
('201e6aeb', 'yes', 'serie', 171802, '', NULL),
('ab027b80', 'no', 'movie', 31556, '', NULL),
('7cc442c8', 'no', 'movie', 678, '', NULL),
('9ac54bd1', 'yes', 'movie', 937085, '', NULL),
('13bae4cb', 'no', 'person', 12446, '', NULL),
('5f5a7c08', 'no', 'person', 3084, '', NULL),
('cd54d3e5', 'yes', 'movie', 935, '', NULL),
('4b4bfe23', 'yes', 'movie', 475, '', NULL),
('a9052094', 'yes', 'movie', 1251, '', NULL),
('bf1b5aae', 'yes', 'movie', 525, '', NULL),
('305b256c', 'yes', '', NULL, 'Heart of Darkness, a novella by Joseph Conrad', NULL),
('6863a331', 'yes', 'movie', 1241803, '', NULL),
('a7acb88a', 'yes', '', NULL, 'Dracula, a novel by Bram Stoker', NULL),
('c1ab91fb', 'yes', '', NULL, 'Nineteen Eighty-Four', NULL),
('43f4f2a9', 'yes', '', NULL, 'For Whom the Bell Tolls', NULL),
('8abebb36', 'yes', '', NULL, 'White Fang', NULL),
('14109632', 'yes', '', NULL, 'Neuromancer, a novel by William Gibson', NULL),
('189fb61c', 'yes', '', NULL, 'Hamlet, a play by William Shakespeare', NULL),
('1d3a1a3f', 'yes', '', NULL, 'Frankenstein, a novel by Mary Shelley', NULL),
('51a3c78e', 'yes', '', NULL, 'The Hobbit and The Lord of the Rings, books by J. R. R. Tolkien', NULL),
('63c9bb56', 'yes', '', NULL, 'Ask the Dust, a novel by John Fante', NULL),
('aad9b026', 'yes', '', NULL, 'The Complete Robot, a short-story collection by Isaac Asimov', NULL),
('ae3d0423', 'yes', '', NULL, 'The Complete Works of Shakespeare, collected works by William Shakespeare', NULL),
('e07d0e20', 'yes', '', NULL, 'Jane Eyre, a novel by Charlotte Brontë', NULL),
('9c9ca883', 'yes', '', NULL, 'The Phantom of the Opera, a novel by Gaston Leroux', NULL),
('0d4f4a2c', 'yes', 'movie', 402431, '', NULL),
('437a4772', 'yes', 'movie', 235093, '', NULL),
('6289abf4', 'no', 'person', 34262, '', NULL),
('91d93589', 'yes', 'person', 224, '', NULL),
('ce41d4d7', 'yes', 'person', 35736, '', NULL),
('d2ebb6f9', 'yes', 'person', 505710, '', NULL),
('f511379d', 'yes', 'person', 7467, '', NULL),
('10bef682', 'no', 'person', 34262, '', NULL),
('d2004e0b', 'yes', 'person', 34262, '', NULL),
('16f58b78', 'yes', 'movie', 62, '', NULL),
('94224540', 'yes', '', NULL, 'Pont de Bir-Hakeim', NULL),
('306fb954', 'yes', '', NULL, 'The Muppets', NULL),
('377fc61d', 'no', 'movie', 1300968, '', NULL),
('fee3c16c', 'yes', '', NULL, 'Spider-Man', NULL),
('234701f2', 'yes', 'serie', 4459, '', NULL);

SELECT '1. Ids: title and year in the base' AS SECTION;
SELECT e.PREFIX, e.VERDICT, e.KIND, e.ID_ENTITY,
       COALESCE(m.MOVIE_TITLE, s.SERIE_TITLE, p.PERSON_NAME, '(NOT FOUND)') AS NAME_IN_BASE,
       COALESCE(m.ORIGINAL_TITLE, s.ORIGINAL_TITLE) AS ORIGINAL_TITLE,
       COALESCE(m.RELEASE_YEAR, s.FIRST_AIR_YEAR, p.BIRTH_YEAR) AS YEAR_IN_BASE,
       COALESCE(m.ID_IMDB, s.ID_IMDB, p.ID_IMDB) AS ID_IMDB
FROM tmp_vision_expect e
LEFT JOIN T_WC_T2S_MOVIE m ON e.KIND = 'movie' AND m.ID_MOVIE = e.ID_ENTITY
LEFT JOIN T_WC_T2S_SERIE s ON e.KIND = 'serie' AND s.ID_SERIE = e.ID_ENTITY
LEFT JOIN T_WC_T2S_PERSON p ON e.KIND = 'person' AND p.ID_PERSON = e.ID_ENTITY
WHERE e.ID_ENTITY IS NOT NULL
ORDER BY e.VERDICT, e.PREFIX;

SELECT '2. Titles without id: candidates by title (and year when known)' AS SECTION;
SELECT e.PREFIX, e.KIND, e.TITLE, e.YEAR_HINT, m.ID_MOVIE AS ID_ENTITY, m.MOVIE_TITLE AS NAME_IN_BASE, m.RELEASE_YEAR AS YEAR_IN_BASE
FROM tmp_vision_expect e JOIN T_WC_T2S_MOVIE m
  ON e.KIND = 'movie' AND (m.MOVIE_TITLE = e.TITLE OR m.ORIGINAL_TITLE = e.TITLE)
 AND (e.YEAR_HINT IS NULL OR m.RELEASE_YEAR BETWEEN e.YEAR_HINT - 1 AND e.YEAR_HINT + 1)
WHERE e.ID_ENTITY IS NULL
UNION ALL
SELECT e.PREFIX, e.KIND, e.TITLE, e.YEAR_HINT, s.ID_SERIE, s.SERIE_TITLE, s.FIRST_AIR_YEAR
FROM tmp_vision_expect e JOIN T_WC_T2S_SERIE s
  ON e.KIND = 'serie' AND (s.SERIE_TITLE = e.TITLE OR s.ORIGINAL_TITLE = e.TITLE)
WHERE e.ID_ENTITY IS NULL
UNION ALL
SELECT e.PREFIX, e.KIND, e.TITLE, e.YEAR_HINT, p.ID_PERSON, p.PERSON_NAME, p.BIRTH_YEAR
FROM tmp_vision_expect e JOIN T_WC_T2S_PERSON p
  ON e.KIND = 'person' AND p.PERSON_NAME = e.TITLE
WHERE e.ID_ENTITY IS NULL
ORDER BY 1, 5;

SELECT '3. Rows with neither id nor entity kind (books, collections, locations, none)' AS SECTION;
SELECT PREFIX, VERDICT, KIND, TITLE FROM tmp_vision_expect WHERE ID_ENTITY IS NULL AND KIND = '' ORDER BY PREFIX;
