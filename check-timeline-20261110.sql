-- check-timeline-20261110.sql
-- Reads back the ten timeline evaluations inserted by new-evaluations-timeline-20261110.sql
-- (phase 2 lot A, result representations), which ended without a SELECT. Voie 1.
SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_SAMPLE, IS_SHOWCASE, ASSERTIONS_QUERY_RESULT
FROM T_WC_T2S_EVALUATION
WHERE ASSERTIONS_RESULT_SHAPE = 'representation == timeline; intent.task == value' AND DELETED = 0
ORDER BY ID_T2S_EVALUATION;
