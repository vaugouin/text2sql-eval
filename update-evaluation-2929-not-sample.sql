-- ============================================================================
-- Evaluation 2929 (James Bond films grouped by the actor who played Bond):
-- kept as an evaluation, taken out of the samples (FASTAPI-TEXT2SQL-421)
-- ============================================================================
--
-- Since 2026-11-25 the text-to-SQL prompt allows no LIKE anywhere: a character is
-- matched with CAST_CHARACTER = '<extracted name>'. The extracted name is "Bond"
-- while the credits store "James Bond", and no resolver maps one to the other yet
-- (Character_name has none, FASTAPI-TEXT2SQL-340). Measured on the standby
-- instance on 2026-11-25, cache off: 0 rows in English and in French, where the
-- former LIKE form returned 32.
--
-- So the evaluation stays (it fails until the resolver lands, then passes), but
-- the front stops offering it as a sample question that answers nothing.
-- One row written, IS_SAMPLE 1 -> 0.

SELECT ID_T2S_EVALUATION, IS_SAMPLE, IS_EVAL, QUESTION
FROM T_WC_T2S_EVALUATION WHERE ID_T2S_EVALUATION = 2929;

UPDATE T_WC_T2S_EVALUATION SET IS_SAMPLE = 0 WHERE ID_T2S_EVALUATION = 2929 AND IS_SAMPLE = 1;

SELECT ID_T2S_EVALUATION, IS_SAMPLE, IS_EVAL, QUESTION
FROM T_WC_T2S_EVALUATION WHERE ID_T2S_EVALUATION = 2929;
