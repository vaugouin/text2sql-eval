-- Harvest for the person alias evaluations of FASTAPI-TEXT2SQL-293 / TMDB-MOVIE-PREPROCESS-070.
-- Read-only. Gives the ids and the exact alias strings to write the questions from, so that no
-- id or spelling is asserted from memory.

SELECT NOW() AS NOW_;

-- 1. Candidate persons for "a name only Wikidata knows": T2S id, popularity, Wikidata aliases,
--    and the TMDb aliases the resolver already holds.
SELECT p.ID_PERSON, p.PERSON_NAME, ROUND(p.POPULARITY, 1) AS POP, p.ID_WIKIDATA,
       JSON_UNQUOTE(JSON_EXTRACT(w.ALIASES_JSON, '$.en')) AS WD_EN,
       JSON_UNQUOTE(JSON_EXTRACT(w.ALIASES_JSON, '$.fr')) AS WD_FR,
       (SELECT GROUP_CONCAT(a.PERSON_NAME ORDER BY a.PERSON_NAME SEPARATOR ' | ')
          FROM T_WC_T2S_PERSON_ALSO_KNOWN_AS a WHERE a.ID_PERSON = p.ID_PERSON) AS TMDB_AKA
FROM T_WC_T2S_PERSON p
LEFT JOIN T_WC_WIKIDATA_PERSON w ON w.ID_WIKIDATA = p.ID_WIKIDATA
WHERE p.PERSON_NAME IN ('Sigrid Valdis', 'Lady Tree', 'Tom Hanks', 'Truman Hanks', 'Michael Caine',
                        'Robert De Niro', 'Kelly Curtis', 'Shunsuke Kazama', 'Geraldine Farrar',
                        'Tuc Watkins', 'John Wayne', 'MyAnna Buring')
ORDER BY p.POPULARITY DESC;

-- 2. Tie-break witnesses for the exact match: a normalized alias held by several persons today,
--    where one of them is far more popular than the others, and which is nobody's main name.
SELECT a.PERSON_NAME_NORM,
       COUNT(DISTINCT a.ID_PERSON) AS PERSONS,
       MAX(p.POPULARITY) AS TOP_POP,
       SUBSTRING_INDEX(GROUP_CONCAT(CONCAT(p.ID_PERSON, ' ', p.PERSON_NAME, ' (', ROUND(p.POPULARITY, 1), ')')
                                    ORDER BY p.POPULARITY DESC SEPARATOR ' | '), ' | ', 3) AS TOP3
FROM T_WC_T2S_PERSON_ALSO_KNOWN_AS a
JOIN T_WC_T2S_PERSON p ON p.ID_PERSON = a.ID_PERSON
WHERE a.PERSON_NAME_NORM LIKE '% %'
GROUP BY a.PERSON_NAME_NORM
HAVING PERSONS BETWEEN 2 AND 4
   AND MAX(p.POPULARITY) >= 5
   AND MAX(p.POPULARITY) >= 5 * (SUM(p.POPULARITY) - MAX(p.POPULARITY)) / (COUNT(*) - 1)
ORDER BY TOP_POP DESC
LIMIT 30;
