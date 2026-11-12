-- Retire the 1.1.20 executions of the chain questions, so the evaluator re-runs them on the SAME
-- version once the API serves the chain (fastapi-text2sql 8f78e8c, phase 3 lot E). 2026-11-12.
-- Written, not run.
--
-- WHICH. The ten chain evaluations 2930 to 2939 ("Trace the chain of remakes behind A Star Is Born
-- (2018)", "What is A Fistful of Dollars based on, and what is that based on?", "Which film is
-- Scarface (1983) a remake of, and what was that film adapted from?", "Show the remake lineage of
-- The Departed", "Trace The Magnificent Seven (2016) back to its origin, remake by remake", "Trace
-- Nosferatu (2024) back to its source, adaptation by adaptation", "Trace Last Man Standing (1996)
-- back to the novel it ultimately comes from", "How did Red Harvest reach the screen, remakes
-- included?", "Which films descend from Seven Samurai, remakes of remakes included?", "The
-- Magnificent Seven (1960): what is it a remake of, and what was remade from it?"). They have no
-- execution row yet unless a campaign ran them before the API was pulled: then their rows carry
-- ranked-bars, card-grid, sequence-strip or entity-page and must go.
--
-- No other id. The census of the 1.1.20 campaigns (English and French, phase 2 lot B and lot C
-- proposals simulated) flips no question: chain needs the API's lineage walk, a second query on the
-- database the offline census cannot run, and the shape rules alone never offer it (92/98 and 90/97
-- as before). The walk would run live on 115, 2530, 2531 and 2537 (English) and 2531, 2537 (French),
-- none of them with a result-shape assertion, so no assertion proposal goes with this file. Live,
-- 2531 ("What is Scarface (1983) based on?") will open as a chain (the novel, Scarface 1932,
-- Scarface 1983); its query_result assertion reads the rows, which stay as they are.
--
-- WHY. No version bump (1.1.20 stays), and text2sql-eval.py skips any evaluation that already has a
-- live execution row for the same API_VERSION, models and LANG. The evaluator sends
-- retrieve_from_cache=false, so the cache rows are not read by the campaign. Soft delete; phase 10
-- of the next run hard-deletes them.
--
-- WHAT TO EXPECT. The assertions are `representation == chain` and query_result clauses on the rows
-- of the first query, which the walk does not change. Recomputed offline on the 1.1.20 baseline
-- answers (ten English, four French) with the walk run on the live graph around their anchors
-- (check-phase3-lot-e-lineage-20261112.txt), all fourteen give chain. The query_result failures of
-- 2933 (the SQL walked down from The Departed) and 2936 (Yojimbo dropped from the rows) are SQL
-- defects and stay: the chain itself shows Infernal Affairs upstream and keeps Yojimbo, but the
-- assertion reads the rows. Latency of the walk on the live base: 2.6 to 11.1 ms of database time
-- (check-phase3-lot-e-walk-timing-20261112.txt).
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables), once the
-- colour in service runs lot E (a pull and a restart of the API container: main.py, result_chain.py,
-- result_shape.py and result_intent.py are not hot-reloaded):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-phase3-lot-e-20261112.sql
-- Expected: section 1 shows nothing, or up to 10 evaluations per language if a campaign already ran
-- them; section 3 nothing.
--
-- THEN the campaign on the ten questions, both languages:
--   bash ~/docker/off-all.sh
--   cd ~/docker/text2sql-eval && EVAL_IDS=2930,2931,2932,2933,2934,2935,2936,2937,2938,2939 ./text2sql-eval.sh
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
  AND ID_T2S_EVALUATION IN (2930, 2931, 2932, 2933, 2934, 2935, 2936, 2937, 2938, 2939)
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
  AND ID_T2S_EVALUATION IN (2930, 2931, 2932, 2933, 2934, 2935, 2936, 2937, 2938, 2939);

-- 3. Check: nothing live is left for the set on this tuple.
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (2930, 2931, 2932, 2933, 2934, 2935, 2936, 2937, 2938, 2939)
GROUP BY LANG ORDER BY LANG;
