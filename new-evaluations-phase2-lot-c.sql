-- New evaluations for phase 2 lot C of the result representations (histogram, share-bar,
-- flag-list), 2026-11-11. The last lot of phase 2.
--
-- WHAT THIS FILE DOES
-- Adds thirty questions with their French twins, ids 2870 to 2899 set explicitly:
--   2870-2879  histogram: entities counted per bin of one quantity (runtime, rating, budget,
--              seasons), the bins in their own order. 2870 to 2876 are already binned by the SQL
--              on 1.1.20; 2877 to 2879 returned the films themselves and need the distribution rule
--              added to data/text_to_sql.md in the same lot (fastapi-text2sql).
--   2880-2889  share-bar: parts of a whole, a label and a COUNT over a complete result of two to
--              eight parts (2880 to 2884, 2889), or one share or percentage (2885 to 2888), drawn
--              as one 100% bar. 2884 asks for the form ("as a pie", "en camembert").
--   2890-2899  flag-list: countries with their flag and name, from location rows of type country
--              (2890 to 2893), from a grouped country code and a count (2894 to 2898), or from one
--              film repeated per production country (2899).
--
-- ASSERTIONS. query_result pins what the 1.1.20 probes returned (a row floor for the bins and
-- the shares, the countries for the flag lists); result_shape (out of score) asserts the new
-- representation only: the task the classifier reads varies on these forms (value, count, rank,
-- list), so no intent.task clause.
--
-- BASELINE on the live API 1.1.20 (cache off, 2026-11-11, 30 English and 12 French calls; the
-- responses are the lotc-* fixtures of voice-agent and t2s-front): every result_shape assertion
-- fails, as intended (table, ranked-bars, card-grid, value-cards, number-card or entity-page
-- served). query_result: 2895 and 2899 fail in French (the SQL read T_WC_T2S_LOCATION).
--
-- FLAGS: IS_EVAL = 1, IS_SAMPLE = 1, IS_SHOWCASE = 0 on all thirty.
--
-- ROUTING: INSERTs on T_WC_T2S_EVALUATION only, no DDL: voie 1.
--   ssh vps-agent pull text2sql-eval
--   ssh vps-agent run text2sql-eval/new-evaluations-phase2-lot-c.sql
-- Commit and push before running. Each INSERT is guarded by NOT EXISTS on its id or its English
-- question, so a re-run inserts nothing. `>` is stored as &gt; in query_result. French twins carry
-- their accents: the runner sets utf8mb4. AUTO_INCREMENT moves to 2900.

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2870
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2870, 'What is the distribution of IMDb ratings of the films released in 2023?', 'Quelle est la distribution des notes IMDb des films sortis en 2023 ?', 3, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 5',
       'representation == histogram',
       'Phase 2 lot C, histogram. The SQL bins the ratings itself (FLOOR(IMDB_RATING) AS RATING_BAND plus a COUNT): one column per band, in band order, never sorted by count. Served table on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2870 OR QUESTION = 'What is the distribution of IMDb ratings of the films released in 2023?') AS guard);

-- 2871
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2871, 'How many Stanley Kubrick films are there in each 30-minute runtime range?', 'Combien de films de Stanley Kubrick y a-t-il dans chaque tranche de durée de 30 minutes ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 4',
       'representation == histogram',
       'Phase 2 lot C, histogram with a range start and a range end (RUNTIME_RANGE_START, RUNTIME_RANGE_END): an empty 30-minute bin between two filled ones is drawn empty, not skipped. Served table on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2871 OR QUESTION = 'How many Stanley Kubrick films are there in each 30-minute runtime range?') AS guard);

-- 2872
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2872, 'How many films from the 1950s are there per IMDb rating band, rounded to the nearest point?', 'Combien de films des années 1950 y a-t-il par tranche de note IMDb, arrondie au point le plus proche ?', 3, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 5',
       'representation == histogram',
       'Phase 2 lot C, histogram on ROUND(IMDB_RATING). Served table on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2872 OR QUESTION = 'How many films from the 1950s are there per IMDb rating band, rounded to the nearest point?') AS guard);

-- 2873
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2873, 'How are HBO series distributed by number of seasons?', 'Comment les séries HBO se répartissent-elles par nombre de saisons ?', 6, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 5',
       'representation == histogram',
       'Phase 2 lot C, histogram on a stored integer (NUMBER_OF_SEASONS grouped, one bin per value). Served table on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2873 OR QUESTION = 'How are HBO series distributed by number of seasons?') AS guard);

-- 2874
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2874, 'Histogram of the runtimes of the James Bond films', 'Histogramme des durées des films James Bond', 3, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 3',
       'representation == histogram',
       'Phase 2 lot C, histogram asked by name (requested_view chart). On 1.1.20 the English SQL binned by 10 minutes (table), the French one returned the films with their bin joined (entity rows, ranked-bars): only rows that are bins become a histogram, the API never bins entity rows itself.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2874 OR QUESTION = 'Histogram of the runtimes of the James Bond films') AS guard);

-- 2875
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2875, 'How are Akira Kurosawa''s films distributed by IMDb rating?', 'Comment les films d''Akira Kurosawa se répartissent-ils par note IMDb ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 5',
       'representation == histogram',
       'Phase 2 lot C, histogram on the raw rating grouped (IMDB_RATING plus FILM_COUNT, one bin per tenth of a point). Served table on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2875 OR QUESTION = 'How are Akira Kurosawa''s films distributed by IMDb rating?') AS guard);

-- 2876
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2876, 'How many Christopher Nolan films fall in each budget range of 50 million dollars?', 'Combien de films de Christopher Nolan y a-t-il dans chaque tranche de budget de 50 millions de dollars ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 3',
       'representation == histogram',
       'Phase 2 lot C, histogram on money bins (BUDGET_RANGE_START, unit usd). Served table on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2876 OR QUESTION = 'How many Christopher Nolan films fall in each budget range of 50 million dollars?') AS guard);

-- 2877
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2877, 'How are Alfred Hitchcock''s films distributed by runtime?', 'Comment les films d''Alfred Hitchcock se répartissent-ils par durée ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 4',
       'representation == histogram',
       'Phase 2 lot C, histogram. On 1.1.20 the SQL returned the 84 films ordered by runtime (ranked-bars in English and French): it passes only once the SQL groups the runtimes into bins (the distribution rule of data/text_to_sql.md, phase 2 lot C).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2877 OR QUESTION = 'How are Alfred Hitchcock''s films distributed by runtime?') AS guard);

-- 2878
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2878, 'Distribution of the runtimes of the Pixar films', 'Distribution des durées des films Pixar', 3, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 3',
       'representation == histogram',
       'Phase 2 lot C, histogram. On 1.1.20 the SQL returned the films ordered by runtime (ranked-bars): passes once the SQL bins (data/text_to_sql.md, phase 2 lot C).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2878 OR QUESTION = 'Distribution of the runtimes of the Pixar films') AS guard);

-- 2879
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2879, 'Distribution of the IMDb ratings of the Studio Ghibli films', 'Distribution des notes IMDb des films du Studio Ghibli', 3, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 3',
       'representation == histogram',
       'Phase 2 lot C, histogram. On 1.1.20 the SQL returned the films ordered by rating (value-cards): passes once the SQL bins (data/text_to_sql.md, phase 2 lot C).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2879 OR QUESTION = 'Distribution of the IMDb ratings of the Studio Ghibli films') AS guard);

-- 2880
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2880, 'How are HBO series split by type?', 'Comment les séries HBO se répartissent-elles par type ?', 6, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 3',
       'representation == share-bar',
       'Phase 2 lot C, share-bar. A label (SERIE_TYPE) and a COUNT, six parts of a complete result: one 100% bar with labelled segments and the numbers. The question asks for a split, so share-bar is the default over ranked-bars (served on 1.1.20).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2880 OR QUESTION = 'How are HBO series split by type?') AS guard);

-- 2881
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2881, 'What is the gender split of the cast of Oppenheimer?', 'Quelle est la répartition hommes-femmes de la distribution d''Oppenheimer ?', 3, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 2',
       'representation == share-bar',
       'Phase 2 lot C, share-bar on a coded column: GENDER (0 not set, 1 women, 2 men, 3 non-binary) is a category, never a measure; the fronts name the codes. Served table on 1.1.20 (English), ranked-bars on a CASE label (French).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2881 OR QUESTION = 'What is the gender split of the cast of Oppenheimer?') AS guard);

-- 2882
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2882, 'What is the gender split of the cast of Barbie (2023)?', 'Quelle est la répartition hommes-femmes de la distribution de Barbie (2023) ?', 3, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 2',
       'representation == share-bar',
       'Phase 2 lot C, share-bar, two parts (GENDER 1 and 2). Served table on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2882 OR QUESTION = 'What is the gender split of the cast of Barbie (2023)?') AS guard);

-- 2883
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2883, 'What is the gender split of the directors of the films on the Sight & Sound 2022 list?', 'Quelle est la répartition hommes-femmes des réalisateurs des films de la liste Sight & Sound 2022 ?', 3, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 2',
       'representation == share-bar',
       'Phase 2 lot C, share-bar, three parts including GENDER 0 (not set). Served table on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2883 OR QUESTION = 'What is the gender split of the directors of the films on the Sight & Sound 2022 list?') AS guard);

-- 2884
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2884, 'Show the split of the HBO series by status as a pie', 'Montre la répartition des séries HBO par statut en camembert', 6, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 3',
       'representation == share-bar',
       'Phase 2 lot C, share-bar asked by its form (as a pie, en camembert: requested_view share, which wins over the classifier''s chart). Served ranked-bars on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2884 OR QUESTION = 'Show the split of the HBO series by status as a pie') AS guard);

-- 2885
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2885, 'What share of Alfred Hitchcock''s films are in black and white?', 'Quelle part des films d''Alfred Hitchcock est en noir et blanc ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) == 1',
       'representation == share-bar',
       'Phase 2 lot C, share-bar from one share (FILM_SHARE 0.74 in English, PERCENTAGE_OF_MOVIES 73.81 in French): the part and the rest, 74% and 26%. Served number-card on 1.1.20, which printed 0.74.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2885 OR QUESTION = 'What share of Alfred Hitchcock''s films are in black and white?') AS guard);

-- 2886
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2886, 'What share of Christopher Nolan''s films are in English?', 'Quelle part des films de Christopher Nolan est en anglais ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) == 1',
       'representation == share-bar',
       'Phase 2 lot C, share-bar from one share (ENGLISH_FILM_SHARE 0.9 on 1.1.20, served number-card).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2886 OR QUESTION = 'What share of Christopher Nolan''s films are in English?') AS guard);

-- 2887
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2887, 'What share of the Studio Ghibli films did Hayao Miyazaki direct?', 'Quelle part des films du Studio Ghibli Hayao Miyazaki a-t-il réalisée ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) == 1',
       'representation == share-bar',
       'Phase 2 lot C, share-bar from one percentage (DIRECTED_SHARE_PERCENT 37.5 on 1.1.20, served number-card): a PERCENT column is read on a 0 to 100 scale.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2887 OR QUESTION = 'What share of the Studio Ghibli films did Hayao Miyazaki direct?') AS guard);

-- 2888
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2888, 'What share of Martin Scorsese''s films are documentaries?', 'Quelle part des films de Martin Scorsese sont des documentaires ?', 4, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) == 1',
       'representation == share-bar',
       'Phase 2 lot C, share-bar from one percentage (PERCENT_OF_FILMS 27.27 on 1.1.20, served number-card).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2888 OR QUESTION = 'What share of Martin Scorsese''s films are documentaries?') AS guard);

-- 2889
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2889, 'What is the gender split of the cast of Little Women (2019)?', 'Quelle est la répartition hommes-femmes de la distribution des Filles du docteur March (2019) ?', 3, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 2',
       'representation == share-bar',
       'Phase 2 lot C, share-bar on GENDER, same shape as 2882 on another film.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2889 OR QUESTION = 'What is the gender split of the cast of Little Women (2019)?') AS guard);

-- 2890
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2890, 'In which countries was Mad Max: Fury Road filmed?', 'Dans quels pays Mad Max: Fury Road a-t-il été tourné ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_LOCATION IN (228, 697)',
       'representation == flag-list',
       'Phase 2 lot C, flag-list from location rows of type country (Angola, Australia, Namibia, South Africa): the API maps each LOCATION_NAME to its ISO 3166-1 code for the flag. Served card-grid on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2890 OR QUESTION = 'In which countries was Mad Max: Fury Road filmed?') AS guard);

-- 2891
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2891, 'In which countries was Lawrence of Arabia filmed?', 'Dans quels pays Lawrence d''Arabie a-t-il été tourné ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_LOCATION IN (879, 416, 56)',
       'representation == flag-list',
       'Phase 2 lot C, flag-list from location rows; England maps to the United Kingdom flag and keeps its own name. Served card-grid on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2891 OR QUESTION = 'In which countries was Lawrence of Arabia filmed?') AS guard);

-- 2892
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2892, 'In which countries was Inception filmed?', 'Dans quels pays Inception a-t-il été tourné ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'ID_LOCATION IN (32, 416)',
       'representation == flag-list',
       'Phase 2 lot C, flag-list, two location rows (Japan, Morocco on 1.1.20, card-grid).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2892 OR QUESTION = 'In which countries was Inception filmed?') AS guard);

-- 2893
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2893, 'In which countries were Christopher Nolan''s films shot?', 'Dans quels pays les films de Christopher Nolan ont-ils été tournés ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNT(*) &gt;= 5 AND ID_LOCATION IN (105)',
       'representation == flag-list',
       'Phase 2 lot C, flag-list over a filmography (twenty location rows of type country on 1.1.20, card-grid).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2893 OR QUESTION = 'In which countries were Christopher Nolan''s films shot?') AS guard);

-- 2894
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2894, 'Which countries produced Akira Kurosawa''s films, and how many each?', 'Quels pays ont produit les films d''Akira Kurosawa, et combien chacun ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNTRY_CODE IN (''JP'', ''US'')',
       'representation == flag-list',
       'Phase 2 lot C, flag-list from a grouped COUNTRY_CODE and a COUNT: the flag, the country name and the number, in the SQL''s order. Served ranked-bars on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2894 OR QUESTION = 'Which countries produced Akira Kurosawa''s films, and how many each?') AS guard);

-- 2895
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2895, 'Which countries produced the most Netflix series?', 'Quels pays ont produit le plus de séries Netflix ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNTRY_CODE IN (''US'', ''GB'')',
       'representation == flag-list',
       'Phase 2 lot C, flag-list of a ranking by country (SERIE_COUNT); ranked-bars stays offered. Served ranked-bars on 1.1.20 in English; the French SQL listed every location of type country (query_result fails).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2895 OR QUESTION = 'Which countries produced the most Netflix series?') AS guard);

-- 2896
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2896, 'Which production countries had the most films released in 2020?', 'Quels pays de production comptent le plus de films sortis en 2020 ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNTRY_CODE IN (''US'', ''GB'', ''FR'')',
       'representation == flag-list',
       'Phase 2 lot C, flag-list of a ranking by production country. Served ranked-bars on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2896 OR QUESTION = 'Which production countries had the most films released in 2020?') AS guard);

-- 2897
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2897, 'Which countries have co-produced the most films with France?', 'Quels pays ont coproduit le plus de films avec la France ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNTRY_CODE IN (''IT'', ''BE'', ''DE'')',
       'representation == flag-list',
       'Phase 2 lot C, flag-list of a ranking by partner country. Served ranked-bars on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2897 OR QUESTION = 'Which countries have co-produced the most films with France?') AS guard);

-- 2898
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2898, 'Which countries of birth are the most common among the directors of Palme d''Or winners?', 'Quels pays de naissance sont les plus fréquents parmi les réalisateurs lauréats de la Palme d''or ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNTRY_OF_BIRTH IN (''US'', ''IT'', ''FR'')',
       'representation == flag-list',
       'Phase 2 lot C, flag-list from COUNTRY_OF_BIRTH grouped (a nationality by birth). Served ranked-bars on 1.1.20.'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2898 OR QUESTION = 'Which countries of birth are the most common among the directors of Palme d''Or winners?') AS guard);

-- 2899
INSERT INTO T_WC_T2S_EVALUATION
  (ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, DELETED, DAT_CREAT, ID_CREATOR, ID_OWNER, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE, LONG_DESC)
SELECT 2899, 'What are the production countries of The Lord of the Rings: The Fellowship of the Ring?', 'Quels sont les pays de production du Seigneur des anneaux : La Communauté de l''anneau ?', 8, 1, 1, 0, 0, CURDATE(), 1, 1,
       'COUNTRY_CODE IN (''NZ'', ''US'')',
       'representation == flag-list',
       'Phase 2 lot C, flag-list from one film repeated once per production country (COUNTRY_CODE beside the film columns): New Zealand and the United States. Served card-grid on 1.1.20 in English; the French SQL read the location table instead (query_result fails).'
FROM DUAL WHERE NOT EXISTS (
  SELECT 1 FROM (SELECT ID_T2S_EVALUATION FROM T_WC_T2S_EVALUATION
    WHERE ID_T2S_EVALUATION = 2899 OR QUESTION = 'What are the production countries of The Lord of the Rings: The Fellowship of the Ring?') AS guard);

-- Read-back: the thirty rows as stored.
SELECT ID_T2S_EVALUATION, QUESTION, QUESTION_FR, ID_T2S_EVALUATION_CATEGORY, IS_EVAL, IS_SAMPLE, IS_SHOWCASE, ASSERTIONS_QUERY_RESULT, ASSERTIONS_RESULT_SHAPE
FROM T_WC_T2S_EVALUATION
WHERE ID_T2S_EVALUATION BETWEEN 2870 AND 2899
ORDER BY ID_T2S_EVALUATION;
