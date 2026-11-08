-- Retire the 1.1.20 executions of the 60 evaluations whose person name the main-name strategy
-- accepted on a FUZZY match, so the evaluator re-runs them on the SAME version once
-- FASTAPI-TEXT2SQL-365 (an exact person alias beats a fuzzy main-name match, with a popularity
-- guard) is live on Blue. 2026-11-05. They are every question voie 1 can change, read from the
-- 2,131 executions of the 1.1.20 campaigns (check-exact-alias-over-fuzzy-name-20261105.txt):
-- expected fixes 2262 (Charles Chaplin), 2629 (Chu Kong), 849 (elisabeth ii, subject to the
-- popularity guard); 565 (john voigt) must stay on Jon Voight; every other one must not move.
--
-- WHY. text2sql-eval.py skips any evaluation that already has a live execution row for the
-- same API_VERSION, models and LANG, and Philippe keeps 1.1.20. Soft delete; phase 10 of the
-- next run hard-deletes them. Exports kept on the PC under
-- shared_data/text2sql-eval/evaluation_execution_archive/001.001.020_baseline-365_20261105/.
--
-- HOW (voie 2: T_WC_T2S_EVALUATION_EXECUTION is not one of the agent-writable tables):
--   cd ~/docker/text2sql-eval && git pull --ff-only
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/retire-executions-365-20261105.sql
-- Expected: section 1 shows about 60 rows per language, section 3 shows 0.

-- 0. The popularity guard on the four cases with an exact alias of another person.
SELECT p.ID_PERSON, p.PERSON_NAME, p.POPULARITY
FROM T_WC_T2S_PERSON p
WHERE p.ID_PERSON IN (552213, 13848, 1409553, 67047, 78477, 558240, 10127, 29124)
ORDER BY FIELD(p.ID_PERSON, 552213, 13848, 1409553, 67047, 78477, 558240, 10127, 29124);

-- 1. What is there.
SELECT LANG, COUNT(*) AS executions, COUNT(DISTINCT ID_T2S_EVALUATION) AS evaluations
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (64, 67, 274, 305, 485, 490, 506, 508, 510, 514, 524, 525, 539, 565, 593, 640, 691, 708, 728, 731, 829, 830, 831, 849, 852, 853, 863, 871, 878, 879, 905, 980, 982, 985, 992, 999, 1016, 1045, 1060, 1074, 1077, 1097, 1105, 1108, 1110, 1111, 1121, 1122, 2136, 2140, 2141, 2227, 2262, 2278, 2328, 2329, 2330, 2478, 2604, 2629)
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
  AND ID_T2S_EVALUATION IN (64, 67, 274, 305, 485, 490, 506, 508, 510, 514, 524, 525, 539, 565, 593, 640, 691, 708, 728, 731, 829, 830, 831, 849, 852, 853, 863, 871, 878, 879, 905, 980, 982, 985, 992, 999, 1016, 1045, 1060, 1074, 1077, 1097, 1105, 1108, 1110, 1111, 1121, 1122, 2136, 2140, 2141, 2227, 2262, 2278, 2328, 2329, 2330, 2478, 2604, 2629);

-- 3. Check: nothing live is left for these ids on this tuple.
SELECT LANG, COUNT(*) AS still_live
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
  AND API_VERSION = '001.001.020'
  AND ENTITY_EXTRACTION_MODEL = 'gpt-6-sol'
  AND TEXT2SQL_MODEL = 'gpt-6-sol'
  AND COMPLEX_MODEL = 'gpt-6.1-sol'
  AND RESULT_ENTITY_MODEL = 'gpt-6-luna'
  AND ID_T2S_EVALUATION IN (64, 67, 274, 305, 485, 490, 506, 508, 510, 514, 524, 525, 539, 565, 593, 640, 691, 708, 728, 731, 829, 830, 831, 849, 852, 853, 863, 871, 878, 879, 905, 980, 982, 985, 992, 999, 1016, 1045, 1060, 1074, 1077, 1097, 1105, 1108, 1110, 1111, 1121, 1122, 2136, 2140, 2141, 2227, 2262, 2278, 2328, 2329, 2330, 2478, 2604, 2629)
GROUP BY LANG;
