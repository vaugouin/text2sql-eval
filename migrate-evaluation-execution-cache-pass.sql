-- TEXT2SQL-EVAL-007 (FASTAPI-TEXT2SQL-389): the cache-pass namespace of the evaluator.
-- A row written by `text2sql-eval.py --cache-pass` (CACHE_PASS=1 with text2sql-eval.sh) carries 1:
-- its JSON_RESULT is the answer served from the cache after a warm call. NULL or 0 = a normal run.
-- DDL: voie 2 (Philippe), then relaunch structurevaugouindb.sh so the dumps follow.

ALTER TABLE T_WC_T2S_EVALUATION_EXECUTION
  ADD COLUMN IF NOT EXISTS CACHE_PASS tinyint(1) DEFAULT NULL
  COMMENT 'TEXT2SQL-EVAL-007 : 1 = reponse servie par le cache apres un appel de chauffe (--cache-pass). NULL ou 0 = passage normal.'
  AFTER VISION_MODEL;

SHOW COLUMNS FROM T_WC_T2S_EVALUATION_EXECUTION LIKE 'CACHE_PASS';
