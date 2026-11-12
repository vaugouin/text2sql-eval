-- Retire the 1.1.20 executions of the hierarchy questions, so the evaluator re-runs them on the SAME
-- version once the API serves the hierarchy (fastapi-text2sql b02d792, phase 3 lot C). 2026-11-12.
-- Written, not run.
--
-- WHICH. The eight grouping evaluations 2920 to 2923 and 2926 to 2929 ("Which collections make up the
-- Marvel Cinematic Universe, with the films of each?", "Show the Star Wars films grouped by trilogy",
-- "Which cities of Italy appear as filming locations, grouped by region?", "Which places of France
-- were Woody Allen's films shot in, grouped by the region they are in?", "In which places of the
-- United States were John Ford's films shot, grouped by state?", "Show the Middle-earth films grouped
-- by trilogy", "In which places of the United Kingdom were the Harry Potter films shot, grouped by
-- nation?", "List the James Bond films grouped by the actor who played Bond"). They have no execution
-- row yet unless a campaign ran them before the API was pulled: then their rows carry card-grid or
-- entity-page and must go. The company trees 2924 and 2925 are out of lot C (decision 7 of
-- 2026-11-12: company trees wait for their data); their shape assertion keeps failing and their
-- rows, if any, stay. No asserted question of the bank flips under lot C (census of the 1.1.20
-- campaigns, English and French, with the phase 2 lot B and lot C proposals simulated: no flip, no
-- regression, 92/98 and 90/97 as before; the hierarchy joins the options of no bank question), so
-- no other id is retired and no assertion proposal goes with this file.
--
-- WHY. No version bump (1.1.20 stays), and text2sql-eval.py skips any evaluation that already has a
-- live execution row for the same API_VERSION, models and LANG. The evaluator sends
-- retrieve_from_cache=false, so the cache rows are not read by the campaign. Soft delete; phase 10
-- of the next run hard-deletes them.
--
-- WHAT TO EXPECT. Recomputed on the 1.1.20 baseline answers, the new module gives hierarchy for 2920
-- French, 2922 (both languages), 2926 and 2927 English. The others depend on the prompt rule of lot C
-- (data/text_to_sql.md, "A grouping: one row per entity, its group in a column"), untested live: 2920
-- English answered with the collections and a GROUP_CONCAT of their films, 2923 and 2928 joined
-- every ancestor of each place (refused as a graph: most places under two regions or nations), 2921
-- kept only collections of exactly three works (one row), 2927 French returned no row, 2929 read the
-- series credits with CAST_CHARACTER = 'Bond' (no row).
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables), once the
-- colour in service runs lot C (a pull and a restart of the API container: result_shape.py and
-- result_intent.py are not hot-reloaded; the prompt is):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-phase3-lot-c-20261112.sql
-- Expected: section 1 shows nothing, or up to 8 evaluations per language if a campaign already ran
-- them; section 3 nothing.
--
-- THEN the campaign on the eight questions, both languages:
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && EVAL_IDS=2920,2921,2922,2923,2926,2927,2928,2929 ./text2sql-eval.sh
--   bash ~/docker/on-all.sh
-- (EVAL_IDS takes explicit ids, no ranges.) Then the sync to the PC and check-result-shape.py.

-- 1. What is there.
SELECT LANG, COUNT(*) AS executions, COUNT(DISTINCT ID_T2S_EVALUATION) AS evaluations
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (2920, 2921, 2922, 2923, 2926, 2927, 2928, 2929)
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
  AND ID_T2S_EVALUATION IN (2920, 2921, 2922, 2923, 2926, 2927, 2928, 2929);

-- 3. Check: nothing live is left for the set on this tuple.
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (2920, 2921, 2922, 2923, 2926, 2927, 2928, 2929)
GROUP BY LANG ORDER BY LANG;
