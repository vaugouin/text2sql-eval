-- update-evaluations-vision-samples.sql: every image evaluation (INPUT_KIND = 'image') becomes a
-- sample, so t2s-front lists its picture under the search box (one click runs the search on it).
-- Expected: 83 rows changed (evaluations 2732 to 2814, IS_SAMPLE 0 -> 1). IS_EVAL and IS_SHOWCASE
-- are left as they are.

UPDATE T_WC_T2S_EVALUATION
SET IS_SAMPLE = 1, TIM_UPDATED = NOW()
WHERE INPUT_KIND = 'image' AND DELETED = 0 AND IFNULL(IS_SAMPLE, 0) <> 1;

SELECT ROW_COUNT() AS ROWS_CHANGED;

-- After: image evaluations by flag
SELECT IS_SAMPLE, IS_EVAL, IS_SHOWCASE, DELETED, COUNT(*) AS N
FROM T_WC_T2S_EVALUATION
WHERE INPUT_KIND = 'image'
GROUP BY IS_SAMPLE, IS_EVAL, IS_SHOWCASE, DELETED;

-- What the search page will show on API 1.1.20: image samples with a run on that version that
-- identified the picture (ASSERTIONS_VISION_IDENTIFICATION_SCORE > 0, any vision model)
SELECT e.ID_T2S_EVALUATION_CATEGORY,
       COUNT(*) AS N_SAMPLES,
       SUM(EXISTS (SELECT 1 FROM T_WC_T2S_EVALUATION_EXECUTION x
                   WHERE x.ID_T2S_EVALUATION = e.ID_T2S_EVALUATION AND x.DELETED = 0
                     AND x.API_VERSION = '001.001.020'
                     AND x.ASSERTIONS_VISION_IDENTIFICATION_SCORE > 0)) AS N_SHOWN
FROM T_WC_T2S_EVALUATION e
WHERE e.INPUT_KIND = 'image' AND e.DELETED = 0 AND e.IS_SAMPLE = 1
GROUP BY e.ID_T2S_EVALUATION_CATEGORY WITH ROLLUP;

-- Score values met, to read the threshold
SELECT x.ASSERTIONS_VISION_IDENTIFICATION_SCORE, COUNT(*) AS N
FROM T_WC_T2S_EVALUATION_EXECUTION x
JOIN T_WC_T2S_EVALUATION e ON e.ID_T2S_EVALUATION = x.ID_T2S_EVALUATION
WHERE e.INPUT_KIND = 'image' AND x.DELETED = 0 AND x.API_VERSION = '001.001.020'
GROUP BY x.ASSERTIONS_VISION_IDENTIFICATION_SCORE
ORDER BY x.ASSERTIONS_VISION_IDENTIFICATION_SCORE;
