-- Diagnostic of check-exact-alias-over-fuzzy-name-20261105.txt: seven unrelated sought names
-- matched the same three alias owners (1506746, Chino Moreno 1105179, Shaun Lopez 3242481).
-- Read-only.
SELECT 'Jeff Bridge' AS S, LCASE(REGEXP_REPLACE(REGEXP_REPLACE('Jeff Bridge', '[^\p{L}\p{M}\p{N} ]+', ' '), ' +', ' ')) AS NORM_,
       HEX(LCASE(REGEXP_REPLACE(REGEXP_REPLACE('Jeff Bridge', '[^\p{L}\p{M}\p{N} ]+', ' '), ' +', ' '))) AS HEX_;
SELECT a.ID_ROW, a.ID_PERSON, a.PERSON_NAME, HEX(a.PERSON_NAME) AS HEX_NAME, a.PERSON_NAME_NORM, HEX(a.PERSON_NAME_NORM) AS HEX_NORM, a.ALIAS_SOURCE
FROM T_WC_T2S_PERSON_ALSO_KNOWN_AS a
WHERE a.ID_PERSON IN (1506746, 1105179, 3242481)
ORDER BY a.ID_PERSON, a.ID_ROW;
SELECT COUNT(*) AS N FROM T_WC_T2S_PERSON_ALSO_KNOWN_AS a WHERE a.PERSON_NAME_NORM = 'jeff bridge';
SELECT a.ID_PERSON, a.PERSON_NAME FROM T_WC_T2S_PERSON_ALSO_KNOWN_AS a WHERE a.PERSON_NAME_NORM = 'yasujiro ozu';
