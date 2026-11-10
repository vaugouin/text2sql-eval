-- ============================================================================
-- Back-office screens t2seval.php and t2sevalexec.php: show the columns added to
-- T_WC_T2S_EVALUATION and T_WC_T2S_EVALUATION_EXECUTION (record view and list)
-- ============================================================================
--
-- Written 2026-11-10. NOT YET APPLIED.
--
-- WHY. Both screens are configured by one row of T_WC_FORM each: FORM_FIELDS drives the record
-- view, SEARCH_RESULT the list. Each is a string of segments separated by "|", a segment being
-- 61 positions (record view) or 36 positions (list) separated by ":". The tables gained columns
-- (vision -277, resolution mode -257, tokens -296, Flex TEXT2SQL-EVAL-002, models -234, costs,
-- timings) that no segment declares, so the back-office neither shows nor edits them.
--
-- WHAT IT WRITES. Two rows of T_WC_FORM, nothing else:
--   t2seval.php (ID_FORM 1483), record view and list, 4 columns:
--     INPUT_KIND, INPUT_IMAGE_PATH, ASSERTIONS_VISION_IDENTIFICATION   editable (right U)
--     ASSERTION_REFRESH_LAST                                           read-only (the refresh job writes it)
--   t2sevalexec.php (ID_FORM 1515), record view and list, 28 columns, all read-only like every
--     other field of that screen (the evaluator writes the executions).
--
-- HOW. REPLACE on anchors: the new segments are inserted next to an existing segment, the rest
-- of the string is left as it is in the database (the screens are edited by hand through
-- form.php, so the dump of 09:13 is not a safe source to overwrite from). A screen is updated
-- only if every anchor is found in both strings and the new columns are not there yet: a rerun
-- changes nothing, and a missing anchor leaves the screen untouched (section 2 shows it).
--
-- NOTE. An evaluation saved through the record view stores '' and not NULL in an empty
-- INPUT_KIND or INPUT_IMAGE_PATH. The evaluator treats both the same
-- (INPUT_KIND IS NULL OR INPUT_KIND <> 'image'; INPUT_IMAGE_PATH <> '').
--
-- ROLLBACK. Section 0 prints both strings of both screens before the change: paste them back
-- with UPDATE T_WC_FORM SET FORM_FIELDS = '...', SEARCH_RESULT = '...' WHERE ID_FORM = ....
--
-- AFTER. The CSV of io/screens/{work,work-list,work-search} for these two screens are older
-- than the database: rebuild them by export with formsload.php, never import them.
--
-- Run (voie 2, write on T_WC_FORM):
--   cd ~/docker/text2sql-eval && git pull
--   ~/docker/tools/runsqlvaugouindb.sh ~/docker/text2sql-eval/migrate-screens-evaluation-fields.sql
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Segment tails. Positions are counted from 0.
-- Record view, editable text field: [12] = U is in the head, then background [42], index [51].
SET @t_ed := CONCAT(REPEAT(':', 30), '#FFFFFF', REPEAT(':', 9), '8', REPEAT(':', 9), '|');
-- Record view, read-only text box: field type C [7], entry type T [8], updatable 0 [12].
SET @t_ro := CONCAT(':::C:T::::0', REPEAT(':', 48), '|');
-- List, text column: sortable [3], width 60 [4], 60 characters [5], display type C [6].
SET @t_l := CONCAT(':1:60:60:C', REPEAT(':', 29), '|');

SELECT '0. Before: full strings (rollback source)' AS SECTION;
SELECT ID_FORM, SCRIPT, TIM_UPDATED, FORM_FIELDS FROM T_WC_FORM WHERE ID_FORM IN (1483, 1515);
SELECT ID_FORM, SCRIPT, SEARCH_RESULT FROM T_WC_FORM WHERE ID_FORM IN (1483, 1515);

-- ----------------------------------------------------------------------------
-- t2seval.php
-- ----------------------------------------------------------------------------
-- Anchors, record view: the RESOLUTION_MODE segment (insert after), the start of the
-- ASSERTIONS_QUERY_RESULT segment (insert before, so right after ASSERTION_REFRESH_SQL).
SET @a1 := CONCAT('S:Resolution mode (standard, complex, any):RESOLUTION_MODE:strresolutionmode:resolutionmode:standard:10:C:T:12:::U', @t_ed);
SET @a2 := '|S:Assertions on result set :ASSERTIONS_QUERY_RESULT:';
SET @n1 := CONCAT(
  'S:Input kind (image or empty for a text question):INPUT_KIND:strinputkind:inputkind::10:C:T:12:::U', @t_ed,
  'S:Input image path (relative to the evaluator fixtures root):INPUT_IMAGE_PATH:strinputimagepath:inputimagepath::255:C:T:80:::U', @t_ed,
  'S:Assertions on vision identification (JSON):ASSERTIONS_VISION_IDENTIFICATION:strassertionsvisionidentification:assertionsvisionidentification::30000:C:E:80:5:1:U', @t_ed);
-- Read-only datetime, modelled on TIM_UPDATED: field type S [7], entry type S [8], updatable 0 [12].
SET @n2 := CONCAT('|S:Assertions refresh last run:ASSERTION_REFRESH_LAST:strassertionrefreshlast:assertionrefreshlast:::S:S::::0',
  REPEAT(':', 30), '#FFFFFF', REPEAT(':', 18));

-- Anchors, list: same two places.
SET @b1 := CONCAT('L:Resolution mode:RESOLUTION_MODE', @t_l);
SET @b2 := '|L:Assertions on result set:ASSERTIONS_QUERY_RESULT:';
SET @m1 := CONCAT(
  'L:Input kind:INPUT_KIND', @t_l,
  'L:Input image path:INPUT_IMAGE_PATH', @t_l,
  'L:Assertions on vision identification:ASSERTIONS_VISION_IDENTIFICATION', @t_l);
-- Datetime column, modelled on TIM_UPDATED: display type S [6], index [23].
SET @m2 := CONCAT('|L:Assertions refresh last run:ASSERTION_REFRESH_LAST:1:60::S', REPEAT(':', 17), '3', REPEAT(':', 12));

UPDATE T_WC_FORM SET
  FORM_FIELDS   = REPLACE(REPLACE(FORM_FIELDS,   @a1, CONCAT(@a1, @n1)), @a2, CONCAT(@n2, @a2)),
  SEARCH_RESULT = REPLACE(REPLACE(SEARCH_RESULT, @b1, CONCAT(@b1, @m1)), @b2, CONCAT(@m2, @b2)),
  TIM_UPDATED   = NOW()
WHERE ID_FORM = 1483 AND SCRIPT = 't2seval.php'
  AND LOCATE(@a1, FORM_FIELDS) > 0 AND LOCATE(@a2, FORM_FIELDS) > 0
  AND LOCATE(@b1, SEARCH_RESULT) > 0 AND LOCATE(@b2, SEARCH_RESULT) > 0
  AND LOCATE(':INPUT_KIND:', FORM_FIELDS) = 0 AND LOCATE(':ASSERTION_REFRESH_LAST:', FORM_FIELDS) = 0
  AND LOCATE(':INPUT_KIND:', SEARCH_RESULT) = 0 AND LOCATE(':ASSERTION_REFRESH_LAST:', SEARCH_RESULT) = 0;
SELECT '1a. t2seval.php: rows updated (1 expected, 0 on a rerun or a missing anchor)' AS SECTION, ROW_COUNT() AS ROWS_UPDATED;

-- ----------------------------------------------------------------------------
-- t2sevalexec.php
-- ----------------------------------------------------------------------------
-- Anchors, record view: the COMPLEX_MODEL, ASSERTIONS_TOTAL_SCORE and TOTAL_PROCESSING_TIME
-- segments (insert after each).
SET @c1 := CONCAT('S:Complex model:COMPLEX_MODEL:strcomplexmodel:complexmodel', @t_ro);
SET @c2 := CONCAT('S:Total score:ASSERTIONS_TOTAL_SCORE:strtotalscore:totalscore', @t_ro);
SET @c3 := CONCAT('S:Total processing time:TOTAL_PROCESSING_TIME:strtotalprocessingtime:totalprocessingtime', @t_ro);
SET @p1 := CONCAT(
  'S:Result entity model:RESULT_ENTITY_MODEL:strresultentitymodel:resultentitymodel', @t_ro,
  'S:Answer single value model:ANSWER_SINGLE_VALUE_MODEL:stranswersinglevaluemodel:answersinglevaluemodel', @t_ro,
  'S:Vision model:VISION_MODEL:strvisionmodel:visionmodel', @t_ro,
  'S:Complex model used (1 or 0):COMPLEX_MODEL_USED:strcomplexmodelused:complexmodelused', @t_ro,
  'S:Resolution mode declared:RESOLUTION_MODE:strresolutionmode:resolutionmode', @t_ro,
  'S:Resolution mode respected (1 or 0):RESOLUTION_MODE_RESPECTED:strresolutionmoderespected:resolutionmoderespected', @t_ro,
  'S:Query mode:QUERY_MODE:strquerymode:querymode', @t_ro,
  'S:First pass failure code:FIRST_PASS_FAILURE_CODE:strfirstpassfailurecode:firstpassfailurecode', @t_ro,
  'S:Flex processing (1 or 0):FLEX_PROCESSING:strflexprocessing:flexprocessing', @t_ro,
  'S:Flex fallback count:FLEX_FALLBACK_COUNT:strflexfallbackcount:flexfallbackcount', @t_ro);
SET @p2 := CONCAT(
  'S:Vision identification score:ASSERTIONS_VISION_IDENTIFICATION_SCORE:strvisionidentificationscore:visionidentificationscore', @t_ro);
SET @p3 := CONCAT(
  'S:Result entity processing time:RESULT_ENTITY_PROCESSING_TIME:strresultentityprocessingtime:resultentityprocessingtime', @t_ro,
  'S:Embeddings cache search time:EMBEDDINGS_CACHE_SEARCH_TIME:strembeddingscachesearchtime:embeddingscachesearchtime', @t_ro,
  'S:Entity resolution planning time:ENTITY_RESOLUTION_PLANNING_TIME:strentityresolutionplanningtime:entityresolutionplanningtime', @t_ro,
  'S:Complex question processing time:COMPLEX_QUESTION_PROCESSING_TIME:strcomplexquestionprocessingtime:complexquestionprocessingtime', @t_ro,
  'S:Answer single value processing time:ANSWER_SINGLE_VALUE_PROCESSING_TIME:stranswersinglevalueprocessingtime:answersinglevalueprocessingtime', @t_ro,
  'S:Vision identification processing time:VISION_IDENTIFICATION_PROCESSING_TIME:strvisionidentificationprocessingtime:visionidentificationprocessingtime', @t_ro,
  'S:Entity raw fallback count:ENTITY_RAW_FALLBACK_COUNT:strentityrawfallbackcount:entityrawfallbackcount', @t_ro,
  'S:No entity extracted (1 or 0):NO_ENTITY_EXTRACTED:strnoentityextracted:noentityextracted', @t_ro,
  'S:Entity match worst distance:ENTITY_MATCH_WORST_DISTANCE:strentitymatchworstdistance:entitymatchworstdistance', @t_ro,
  'S:Entity match worst fuzz ratio:ENTITY_MATCH_WORST_FUZZ_RATIO:strentitymatchworstfuzzratio:entitymatchworstfuzzratio', @t_ro,
  'S:Entity extraction cost:ENTITY_EXTRACTION_COST:strentityextractioncost:entityextractioncost', @t_ro,
  'S:Text2SQL cost:TEXT2SQL_COST:strtext2sqlcost:text2sqlcost', @t_ro,
  'S:Total cost:TOTAL_COST:strtotalcost:totalcost', @t_ro,
  'S:LLM prompt tokens:LLM_PROMPT_TOKENS:strllmprompttokens:llmprompttokens', @t_ro,
  'S:LLM cached tokens:LLM_CACHED_TOKENS:strllmcachedtokens:llmcachedtokens', @t_ro,
  'S:LLM completion tokens:LLM_COMPLETION_TOKENS:strllmcompletiontokens:llmcompletiontokens', @t_ro,
  'S:LLM reasoning tokens:LLM_REASONING_TOKENS:strllmreasoningtokens:llmreasoningtokens', @t_ro);

-- Anchors, list: same three places. TOTAL_PROCESSING_TIME has no character limit at [5].
SET @d1 := CONCAT('L:Complex model:COMPLEX_MODEL', @t_l);
SET @d2 := CONCAT('L:Total score:ASSERTIONS_TOTAL_SCORE', @t_l);
SET @d3 := CONCAT('L:Total processing time:TOTAL_PROCESSING_TIME:1:60::C', REPEAT(':', 29), '|');
SET @q1 := CONCAT(
  'L:Result entity model:RESULT_ENTITY_MODEL', @t_l,
  'L:Answer single value model:ANSWER_SINGLE_VALUE_MODEL', @t_l,
  'L:Vision model:VISION_MODEL', @t_l,
  'L:Complex model used:COMPLEX_MODEL_USED', @t_l,
  'L:Resolution mode declared:RESOLUTION_MODE', @t_l,
  'L:Resolution mode respected:RESOLUTION_MODE_RESPECTED', @t_l,
  'L:Query mode:QUERY_MODE', @t_l,
  'L:First pass failure code:FIRST_PASS_FAILURE_CODE', @t_l,
  'L:Flex processing:FLEX_PROCESSING', @t_l,
  'L:Flex fallback count:FLEX_FALLBACK_COUNT', @t_l);
SET @q2 := CONCAT(
  'L:Vision identification score:ASSERTIONS_VISION_IDENTIFICATION_SCORE', @t_l);
SET @q3 := CONCAT(
  'L:Result entity processing time:RESULT_ENTITY_PROCESSING_TIME', @t_l,
  'L:Embeddings cache search time:EMBEDDINGS_CACHE_SEARCH_TIME', @t_l,
  'L:Entity resolution planning time:ENTITY_RESOLUTION_PLANNING_TIME', @t_l,
  'L:Complex question processing time:COMPLEX_QUESTION_PROCESSING_TIME', @t_l,
  'L:Answer single value processing time:ANSWER_SINGLE_VALUE_PROCESSING_TIME', @t_l,
  'L:Vision identification processing time:VISION_IDENTIFICATION_PROCESSING_TIME', @t_l,
  'L:Entity raw fallback count:ENTITY_RAW_FALLBACK_COUNT', @t_l,
  'L:No entity extracted:NO_ENTITY_EXTRACTED', @t_l,
  'L:Entity match worst distance:ENTITY_MATCH_WORST_DISTANCE', @t_l,
  'L:Entity match worst fuzz ratio:ENTITY_MATCH_WORST_FUZZ_RATIO', @t_l,
  'L:Entity extraction cost:ENTITY_EXTRACTION_COST', @t_l,
  'L:Text2SQL cost:TEXT2SQL_COST', @t_l,
  'L:Total cost:TOTAL_COST', @t_l,
  'L:LLM prompt tokens:LLM_PROMPT_TOKENS', @t_l,
  'L:LLM cached tokens:LLM_CACHED_TOKENS', @t_l,
  'L:LLM completion tokens:LLM_COMPLETION_TOKENS', @t_l,
  'L:LLM reasoning tokens:LLM_REASONING_TOKENS', @t_l);

UPDATE T_WC_FORM SET
  FORM_FIELDS   = REPLACE(REPLACE(REPLACE(FORM_FIELDS,   @c1, CONCAT(@c1, @p1)), @c2, CONCAT(@c2, @p2)), @c3, CONCAT(@c3, @p3)),
  SEARCH_RESULT = REPLACE(REPLACE(REPLACE(SEARCH_RESULT, @d1, CONCAT(@d1, @q1)), @d2, CONCAT(@d2, @q2)), @d3, CONCAT(@d3, @q3)),
  TIM_UPDATED   = NOW()
WHERE ID_FORM = 1515 AND SCRIPT = 't2sevalexec.php'
  AND LOCATE(@c1, FORM_FIELDS) > 0 AND LOCATE(@c2, FORM_FIELDS) > 0 AND LOCATE(@c3, FORM_FIELDS) > 0
  AND LOCATE(@d1, SEARCH_RESULT) > 0 AND LOCATE(@d2, SEARCH_RESULT) > 0 AND LOCATE(@d3, SEARCH_RESULT) > 0
  AND LOCATE(':VISION_MODEL:', FORM_FIELDS) = 0 AND LOCATE(':TOTAL_COST:', FORM_FIELDS) = 0
  AND LOCATE(':VISION_MODEL:', SEARCH_RESULT) = 0 AND LOCATE(':TOTAL_COST:', SEARCH_RESULT) = 0;
SELECT '1b. t2sevalexec.php: rows updated (1 expected, 0 on a rerun or a missing anchor)' AS SECTION, ROW_COUNT() AS ROWS_UPDATED;

-- ----------------------------------------------------------------------------
-- Checks
-- ----------------------------------------------------------------------------
SELECT '2. After: segment counts (t2seval 21 -> 25 and 19 -> 23, t2sevalexec 23 -> 51 and 23 -> 51)' AS SECTION;
SELECT ID_FORM, SCRIPT, TIM_UPDATED,
       LENGTH(FORM_FIELDS)   - LENGTH(REPLACE(FORM_FIELDS,   '|', '')) AS FORM_SEGMENTS,
       LENGTH(SEARCH_RESULT) - LENGTH(REPLACE(SEARCH_RESULT, '|', '')) AS LIST_SEGMENTS,
       LENGTH(FORM_FIELDS) AS FORM_BYTES, LENGTH(SEARCH_RESULT) AS LIST_BYTES
FROM T_WC_FORM WHERE ID_FORM IN (1483, 1515);

SELECT '3. After: every column of both tables, declared or not in its screen' AS SECTION;
SELECT c.TABLE_NAME, c.ORDINAL_POSITION, c.COLUMN_NAME,
       LOCATE(CONCAT(':', c.COLUMN_NAME, ':'), f.FORM_FIELDS)   > 0 AS IN_RECORD_VIEW,
       LOCATE(CONCAT(':', c.COLUMN_NAME, ':'), f.SEARCH_RESULT) > 0 AS IN_LIST
FROM INFORMATION_SCHEMA.COLUMNS c
JOIN T_WC_FORM f ON f.ID_FORM = IF(c.TABLE_NAME = 'T_WC_T2S_EVALUATION', 1483, 1515)
WHERE c.TABLE_SCHEMA = DATABASE()
  AND c.TABLE_NAME IN ('T_WC_T2S_EVALUATION', 'T_WC_T2S_EVALUATION_EXECUTION')
ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;

SELECT '4. After: full strings' AS SECTION;
SELECT ID_FORM, SCRIPT, FORM_FIELDS FROM T_WC_FORM WHERE ID_FORM IN (1483, 1515);
SELECT ID_FORM, SCRIPT, SEARCH_RESULT FROM T_WC_FORM WHERE ID_FORM IN (1483, 1515);
