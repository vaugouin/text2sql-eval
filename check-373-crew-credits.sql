-- Check before new-evaluations-373-misattributed-crew-role.sql (FASTAPI-TEXT2SQL-373): confirm in
-- the T2S tables the credits the evaluations rely on. Written 2026-11-10. SELECTs only: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/check-373-crew-credits.sql
-- T_WC_T2S_PERSON_MOVIE carries CREW_DEPARTMENT but no CREW_JOB on movies (FASTAPI-TEXT2SQL-165).

-- 1. The persons, by name (expected: Tarantino 138, Spielberg 488, Burton 510, Fincher, Hooper,
--    Dante, Selick; homonyms show up here).
SELECT ID_PERSON, PERSON_NAME, POPULARITY
  FROM T_WC_T2S_PERSON
  WHERE PERSON_NAME IN ('Quentin Tarantino', 'Steven Spielberg', 'Tim Burton', 'David Fincher', 'Tobe Hooper', 'Joe Dante', 'Henry Selick')
  ORDER BY PERSON_NAME, POPULARITY DESC;

-- 2. The six films and every crew credit of the named persons on them.
SELECT m.ID_MOVIE, m.MOVIE_TITLE, m.MOVIE_TITLE_FR, m.RELEASE_YEAR, m.STATUS, p.PERSON_NAME, c.CREDIT_TYPE, c.CREW_DEPARTMENT
  FROM T_WC_T2S_MOVIE m
  JOIN T_WC_T2S_PERSON_MOVIE c ON c.ID_MOVIE = m.ID_MOVIE
  JOIN T_WC_T2S_PERSON p ON p.ID_PERSON = c.ID_PERSON
  WHERE m.ID_MOVIE IN (1457866, 466272, 609, 927, 9479)
    AND p.PERSON_NAME IN ('Quentin Tarantino', 'Steven Spielberg', 'Tim Burton', 'David Fincher', 'Tobe Hooper', 'Joe Dante', 'Henry Selick')
  ORDER BY m.ID_MOVIE, p.PERSON_NAME, c.CREDIT_TYPE, c.CREW_DEPARTMENT;

-- 3. Every credit of Quentin Tarantino on a 2026 film (questions 2 and 6 of the evaluation file).
SELECT m.ID_MOVIE, m.MOVIE_TITLE, m.RELEASE_YEAR, m.STATUS, m.DAT_RELEASE, c.CREDIT_TYPE, c.CREW_DEPARTMENT
  FROM T_WC_T2S_MOVIE m
  JOIN T_WC_T2S_PERSON_MOVIE c ON c.ID_MOVIE = m.ID_MOVIE
  JOIN T_WC_T2S_PERSON p ON p.ID_PERSON = c.ID_PERSON
  WHERE p.PERSON_NAME = 'Quentin Tarantino' AND m.RELEASE_YEAR = 2026
  ORDER BY c.CREDIT_TYPE, m.ID_MOVIE;

-- 4. The control: films Tarantino directed (expected 466272 among them, never 1457866).
SELECT m.ID_MOVIE, m.MOVIE_TITLE, m.RELEASE_YEAR
  FROM T_WC_T2S_MOVIE m
  JOIN T_WC_T2S_PERSON_MOVIE c ON c.ID_MOVIE = m.ID_MOVIE
  JOIN T_WC_T2S_PERSON p ON p.ID_PERSON = c.ID_PERSON
  WHERE p.PERSON_NAME = 'Quentin Tarantino' AND c.CREDIT_TYPE = 'crew' AND c.CREW_DEPARTMENT = 'Directing'
  ORDER BY m.RELEASE_YEAR;
