-- Evaluation for FASTAPI-TEXT2SQL-368: the answer sentence of a description must not name the
-- database identifier the API found. Written 2026-11-08, after the fix (`d692ad3`, Blue 1.1.20),
-- to close the ticket by an evaluation (backlog rule of 2026-08-02).
--
-- THE DEFECT. After the identity check of -355, the complex retry re-enters through the
-- bare-identifier fast path, whose answer is the generic "Here is the movie matching identifier
-- tt0075314." / "Voici l'entité (movie) correspondant à l'identifiant tt0075314.". The user typed a
-- tagline or a description, never the id; on the voice app it is the banner above the card.
--
-- WHAT THIS FILE DOES
-- Sets ASSERTIONS_RESULT_SHAPE = 'answer !~ (tt|nm)[0-9]{7}|matching identifier|identifiant' on the thirteen
-- questions of -355 (2630 to 2641, a description of a work that shares its title and year with
-- other rows; 2642, the bare title "Movie Taxi Driver (1976)", which types no id either). The
-- assertion is on what went wrong, not on the observed wording: no IMDb id (tt, nm) and no
-- generic "matching identifier" / "identifiant" line in `answer`, whatever sentence the API
-- writes instead. Not the bare word "identifier": in French it is also the verb (2457, 2512).
-- The same clause runs bank-wide in check-result-shape.py (every question that types no id);
-- these thirteen rows are the explicit trace of the ticket.
-- The `answer` clause is new in the result-shape grammar (text2sql-eval 2.20.0,
-- result_shape_assertions.py): OUT OF SCORE like the whole column, and tallied on its own line by
-- check-result-shape.py, so the shape figures do not move (1.1.20: 82 checked, 60 PASS, 22 FAIL).
-- The regex has no backslash on purpose: a MariaDB string literal would eat it.
--
-- BASELINE, the 1.1.20 campaign of 2026-11-06 (before the fix), checked offline on the exports
-- with this assertion: EN 13 asserted, 2 PASS, 11 FAIL (2630 to 2640 all "matching identifier
-- tt..."; 2641 passes on an empty answer, 2642 on "Here's the movie Taxi Driver from around 1976.");
-- FR 13 asserted, 1 PASS, 12 FAIL (2630 to 2641 "correspondant à l'identifiant tt...", 2642 passes).
-- Expected after a re-run on Blue with `d692ad3`: 13 PASS per language.
--
-- ROUTING: UPDATE on T_WC_T2S_EVALUATION only: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run -e text2sql-eval/archive/update-evaluations-368-answer-identifier.sql
-- Guarded: only a row with no result-shape assertion is written, so a re-run does nothing.
-- Expected: 13 rows changed, then the SELECT shows the thirteen assertions.

UPDATE T_WC_T2S_EVALUATION
SET ASSERTIONS_RESULT_SHAPE = 'answer !~ (tt|nm)[0-9]{7}|matching identifier|identifiant'
WHERE ID_T2S_EVALUATION BETWEEN 2630 AND 2642
  AND (ASSERTIONS_RESULT_SHAPE IS NULL OR ASSERTIONS_RESULT_SHAPE = '');

SELECT ROW_COUNT() AS ROWS_CHANGED;

SELECT ID_T2S_EVALUATION, ID_T2S_EVALUATION_CATEGORY, LEFT(QUESTION, 70) AS QUESTION, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE
  FROM T_WC_T2S_EVALUATION
  WHERE ID_T2S_EVALUATION BETWEEN 2630 AND 2642
  ORDER BY ID_T2S_EVALUATION;
