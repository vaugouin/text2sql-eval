-- Retire the 1.1.20 executions of the map questions of countries, so the evaluator re-runs them on
-- the SAME version once the API serves the map (fastapi-text2sql ce2b85f, phase 3 lot B). 2026-11-12.
-- Written, not run.
--
-- WHICH. The four country evaluations 2916 to 2919 only ("Show on a world map the countries that
-- produced the most films in 2020", "World map of the number of Netflix series produced per
-- country", "On a world map, how many films has each country co-produced with France?", "Show on a
-- map the countries of birth of the directors of Palme d'Or winners"). They have no execution row
-- yet unless a campaign ran them before the API was pulled: then their rows carry flag-list and
-- must go. The place questions 2910 to 2915 are out of lot B: the API still serves them card-grid,
-- their shape assertion keeps failing until the lot of places (coordinates first), and their rows,
-- if any, stay. No asserted question of the bank flips under lot B (census of the 1.1.20
-- campaigns, English and French, with the phase 2 lot B and lot C proposals simulated: no flip, no
-- regression, 92/98 and 90/97 as before; the map only joins the options of the flag-list
-- answers), so no other id is retired and no assertion proposal goes with this file.
--
-- WHY. No version bump (1.1.20 stays), and text2sql-eval.py skips any evaluation that already has a
-- live execution row for the same API_VERSION, models and LANG. The evaluator sends
-- retrieve_from_cache=false, so the cache rows are not read by the campaign. Soft delete; phase 10
-- of the next run hard-deletes them.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables), once the
-- colour in service runs lot B (a pull and a restart of the API container: result_shape.py,
-- result_intent.py and result_countries.py are not hot-reloaded):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-phase3-lot-b-20261112.sql
-- Expected: section 1 shows nothing, or 4 evaluations per language if a campaign already ran them;
-- section 3 nothing.
--
-- THEN the campaign on the four questions, both languages:
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && EVAL_IDS=2916,2917,2918,2919 ./text2sql-eval.sh
--   bash ~/docker/on-all.sh
-- (EVAL_IDS takes explicit ids, no ranges.) Then the sync to the PC and check-result-shape.py.
-- 2919 keeps failing its query_result on 1.1.20 (the SQL lists the country locations of the base,
-- not the countries of birth of the directors); its shape assertion passes once the map is served.

-- 1. What is there.
SELECT LANG, COUNT(*) AS executions, COUNT(DISTINCT ID_T2S_EVALUATION) AS evaluations
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION BETWEEN 2916 AND 2919
GROUP BY LANG ORDER BY LANG;

-- 2. Retire them (soft delete).
UPDATE T_WC_T2S_EVALUATION_EXECUTION
SET DELETED = 1
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION BETWEEN 2916 AND 2919;

-- 3. Check: nothing live is left for the set on this tuple.
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION BETWEEN 2916 AND 2919
GROUP BY LANG ORDER BY LANG;
