-- Control (read-only): under which (API version + the five model labels + language)
-- tuples do the prior evaluation executions live? The pre-flight counts an eval as
-- "already done" only when a non-deleted execution matches the WHOLE tuple
-- (text2sql-eval.sh, phase-2 "done" subquery). So this reveals why a 1.1.19 /
-- result_entity=gpt-6-luna run sees ~900 evals "to run" though the bank was already
-- played: the mass of executions sits under a different API version and/or model.
-- TEXT2SQL-EVAL diagnostic, 2026-10-26.
SELECT
    API_VERSION,
    ENTITY_EXTRACTION_MODEL,
    TEXT2SQL_MODEL,
    COMPLEX_MODEL,
    RESULT_ENTITY_MODEL,
    ANSWER_SINGLE_VALUE_MODEL,
    LANG,
    COUNT(*)                          AS executions,
    COUNT(DISTINCT ID_T2S_EVALUATION) AS distinct_evals
FROM T_WC_T2S_EVALUATION_EXECUTION
WHERE DELETED = 0
GROUP BY
    API_VERSION,
    ENTITY_EXTRACTION_MODEL,
    TEXT2SQL_MODEL,
    COMPLEX_MODEL,
    RESULT_ENTITY_MODEL,
    ANSWER_SINGLE_VALUE_MODEL,
    LANG
ORDER BY executions DESC;
