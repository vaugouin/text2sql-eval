-- Regression risk of "voie 1" (an exact alias match wins over a fuzzy main-name match in the
-- person resolver), measured on the whole bank. Read-only. 2026-11-05.
--
-- Voie 1 only changes a question whose person name was accepted by the main-name strategy
-- (T_WC_T2S_PERSON) on a FUZZY match, not an exact one. The 61 distinct (sought, candidate)
-- pairs below are every such hit of the 2,131 executions of the 1.1.20 campaigns (EN and FR,
-- exports of 2026-11-05), with the evaluations they come from (lang + id : score). For each,
-- the query says whether the sought form exists exactly in T_WC_T2S_PERSON_ALSO_KNOWN_AS (same
-- normalization as PERSON_NAME_NORM, utf8mb4_unicode_ci) and whose alias it is. Verdict:
--   NONE       no exact alias: voie 1 changes nothing;
--   SAME       the most popular alias owner is the fuzzy candidate: same answer;
--   DIFFERENT  voie 1 would hand the name to another person: a fix or a regression, read EVALS.

SELECT NOW() AS NOW_;

WITH s AS (
SELECT 'Andre Previn' AS SOUGHT, 'André Previn' AS FUZZY_CANDIDATE, 'en829:1 fr829:1' AS EVALS UNION ALL
SELECT 'Arnaud Depleschin' AS SOUGHT, 'Arnaud Desplechin' AS FUZZY_CANDIDATE, 'en2227:1' AS EVALS UNION ALL
SELECT 'Arnold schwarzeneger' AS SOUGHT, 'Arnold Schwarzenegger' AS FUZZY_CANDIDATE, 'en1111:1' AS EVALS UNION ALL
SELECT 'Catherine allegret' AS SOUGHT, 'Catherine Allégret' AS FUZZY_CANDIDATE, 'en1074:1' AS EVALS UNION ALL
SELECT 'Charles Chaplin' AS SOUGHT, 'Charles Champlin' AS FUZZY_CANDIDATE, 'en2262:0' AS EVALS UNION ALL
SELECT 'Chu Kong' AS SOUGHT, 'Chu Bong' AS FUZZY_CANDIDATE, 'en2629:0 fr2629:0' AS EVALS UNION ALL
SELECT 'Céline Song' AS SOUGHT, 'Celine Song' AS FUZZY_CANDIDATE, 'fr1045:1' AS EVALS UNION ALL
SELECT 'Dany Elfman' AS SOUGHT, 'Danny Elfman' AS FUZZY_CANDIDATE, 'fr831:1' AS EVALS UNION ALL
SELECT 'Edward g Robinson' AS SOUGHT, 'Edward G. Robinson' AS FUZZY_CANDIDATE, 'en905:1' AS EVALS UNION ALL
SELECT 'Francois Reichenbach' AS SOUGHT, 'François Reichenbach' AS FUZZY_CANDIDATE, 'en1105:1 fr1105:1' AS EVALS UNION ALL
SELECT 'Frederic Chopin' AS SOUGHT, 'Frédéric Chopin' AS FUZZY_CANDIDATE, 'en1121:0 en1122:1 en67:1' AS EVALS UNION ALL
SELECT 'Gerard Rinaldi' AS SOUGHT, 'Gérard Rinaldi' AS FUZZY_CANDIDATE, 'en999:1 fr999:1' AS EVALS UNION ALL
SELECT 'Hillary Swank' AS SOUGHT, 'Hilary Swank' AS FUZZY_CANDIDATE, 'en2328:1 fr2328:1' AS EVALS UNION ALL
SELECT 'J. K. Rowling' AS SOUGHT, 'J.K. Rowling' AS FUZZY_CANDIDATE, 'en274:1 fr274:1' AS EVALS UNION ALL
SELECT 'Jean Christophe grange' AS SOUGHT, 'Jean-Christophe Grangé' AS FUZZY_CANDIDATE, 'en982:1' AS EVALS UNION ALL
SELECT 'Jean Laurent Cochet' AS SOUGHT, 'Jean-Laurent Cochet' AS FUZZY_CANDIDATE, 'fr691:1' AS EVALS UNION ALL
SELECT 'Jean Laurent cochet' AS SOUGHT, 'Jean-Laurent Cochet' AS FUZZY_CANDIDATE, 'en691:1' AS EVALS UNION ALL
SELECT 'Jean Pierre Mocky' AS SOUGHT, 'Jean-Pierre Mocky' AS FUZZY_CANDIDATE, 'fr992:1' AS EVALS UNION ALL
SELECT 'Jean Pierre mocky' AS SOUGHT, 'Jean-Pierre Mocky' AS FUZZY_CANDIDATE, 'en992:1' AS EVALS UNION ALL
SELECT 'Jeff Bridge' AS SOUGHT, 'Jeff Bridges' AS FUZZY_CANDIDATE, 'fr305:1' AS EVALS UNION ALL
SELECT 'Jeff bridge' AS SOUGHT, 'Jeff Bridges' AS FUZZY_CANDIDATE, 'en305:1' AS EVALS UNION ALL
SELECT 'Jenny Aguter' AS SOUGHT, 'Jenny Agutter' AS FUZZY_CANDIDATE, 'fr1110:1' AS EVALS UNION ALL
SELECT 'Jenny aguter' AS SOUGHT, 'Jenny Agutter' AS FUZZY_CANDIDATE, 'en1110:1' AS EVALS UNION ALL
SELECT 'Johnathan Swift' AS SOUGHT, 'Jonathan Swift' AS FUZZY_CANDIDATE, 'fr1016:1' AS EVALS UNION ALL
SELECT 'Johnathan swift' AS SOUGHT, 'Jonathan Swift' AS FUZZY_CANDIDATE, 'en1016:1' AS EVALS UNION ALL
SELECT 'Jude Apatow' AS SOUGHT, 'Judd Apatow' AS FUZZY_CANDIDATE, 'fr830:1' AS EVALS UNION ALL
SELECT 'Jude appatow' AS SOUGHT, 'Judd Apatow' AS FUZZY_CANDIDATE, 'en830:1' AS EVALS UNION ALL
SELECT 'Katherine Hepburn' AS SOUGHT, 'Katharine Hepburn' AS FUZZY_CANDIDATE, 'en2329:1 fr2329:1 fr506:1' AS EVALS UNION ALL
SELECT 'Kléber Mendonça Filho' AS SOUGHT, 'Kleber Mendonça Filho' AS FUZZY_CANDIDATE, 'fr1097:1 fr980:1' AS EVALS UNION ALL
SELECT 'Kléber mendoca filho' AS SOUGHT, 'Kleber Mendonça Filho' AS FUZZY_CANDIDATE, 'en980:1' AS EVALS UNION ALL
SELECT 'Kléber mendonca filho' AS SOUGHT, 'Kleber Mendonça Filho' AS FUZZY_CANDIDATE, 'en1097:1' AS EVALS UNION ALL
SELECT 'Krzysztof Kieslowski' AS SOUGHT, 'Krzysztof Kieślowski' AS FUZZY_CANDIDATE, 'en2604:1 fr2604:1' AS EVALS UNION ALL
SELECT 'Leonardo di caprio' AS SOUGHT, 'Leonardo DiCaprio' AS FUZZY_CANDIDATE, 'en524:1 en525:1 fr524:1 fr525:1' AS EVALS UNION ALL
SELECT 'Marion Morrison' AS SOUGHT, 'Marq Morrison' AS FUZZY_CANDIDATE, 'en2478:0 fr2478:0' AS EVALS UNION ALL
SELECT 'Martin Scorcese' AS SOUGHT, 'Martin Scorsese' AS FUZZY_CANDIDATE, 'en2278:1 en64:1' AS EVALS UNION ALL
SELECT 'Martin scorcese' AS SOUGHT, 'Martin Scorsese' AS FUZZY_CANDIDATE, 'en731:0' AS EVALS UNION ALL
SELECT 'Michele pfeiffer' AS SOUGHT, 'Michelle Pfeiffer' AS FUZZY_CANDIDATE, 'en1077:0' AS EVALS UNION ALL
SELECT 'Paul gegauf' AS SOUGHT, 'Paul Gégauff' AS FUZZY_CANDIDATE, 'en708:1 fr708:1' AS EVALS UNION ALL
SELECT 'RICARDO FREDA' AS SOUGHT, 'Riccardo Freda' AS FUZZY_CANDIDATE, 'en2330:1 fr2330:1' AS EVALS UNION ALL
SELECT 'Sasha Guitry' AS SOUGHT, 'Sacha Guitry' AS FUZZY_CANDIDATE, 'fr640:1' AS EVALS UNION ALL
SELECT 'Suzanne schifman' AS SOUGHT, 'Suzanne Schiffman' AS FUZZY_CANDIDATE, 'en853:1 fr853:1' AS EVALS UNION ALL
SELECT 'Toshiro Mifune' AS SOUGHT, 'Toshirō Mifune' AS FUZZY_CANDIDATE, 'en2140:1 en2141:1 fr2140:1 fr2141:1' AS EVALS UNION ALL
SELECT 'Vincent Barré' AS SOUGHT, 'Vincent Darré' AS FUZZY_CANDIDATE, 'en863:0 fr863:0' AS EVALS UNION ALL
SELECT 'david gauque' AS SOUGHT, 'David Gauquié' AS FUZZY_CANDIDATE, 'en1108:1 fr1108:1' AS EVALS UNION ALL
SELECT 'dwayne jonson' AS SOUGHT, 'Dwayne Johnson' AS FUZZY_CANDIDATE, 'en878:1 en879:0' AS EVALS UNION ALL
SELECT 'elisabeth ii' AS SOUGHT, 'Elisabeth Quin' AS FUZZY_CANDIDATE, 'en849:0' AS EVALS UNION ALL
SELECT 'francoise Arnoul' AS SOUGHT, 'Françoise Arnoul' AS FUZZY_CANDIDATE, 'en852:1' AS EVALS UNION ALL
SELECT 'humphrey bogard' AS SOUGHT, 'Humphrey Bogart' AS FUZZY_CANDIDATE, 'en871:1' AS EVALS UNION ALL
SELECT 'john frankheimer' AS SOUGHT, 'John Frankenheimer' AS FUZZY_CANDIDATE, 'en1060:1 fr1060:1' AS EVALS UNION ALL
SELECT 'john voigt' AS SOUGHT, 'Jon Voight' AS FUZZY_CANDIDATE, 'en565:1' AS EVALS UNION ALL
SELECT 'katherine hepburn' AS SOUGHT, 'Katharine Hepburn' AS FUZZY_CANDIDATE, 'en506:1' AS EVALS UNION ALL
SELECT 'lauren bacal' AS SOUGHT, 'Lauren Bacall' AS FUZZY_CANDIDATE, 'en508:1' AS EVALS UNION ALL
SELECT 'leonardo di caprio' AS SOUGHT, 'Leonardo DiCaprio' AS FUZZY_CANDIDATE, 'en490:1 fr490:1' AS EVALS UNION ALL
SELECT 'louis de funes' AS SOUGHT, 'Louis de Funès' AS FUZZY_CANDIDATE, 'en485:1 en510:1' AS EVALS UNION ALL
SELECT 'marcello mastrioanni' AS SOUGHT, 'Marcello Mastroianni' AS FUZZY_CANDIDATE, 'en514:1' AS EVALS UNION ALL
SELECT 'marcello mastroiani' AS SOUGHT, 'Marcello Mastroianni' AS FUZZY_CANDIDATE, 'en728:1 fr728:1' AS EVALS UNION ALL
SELECT 'marco tullio giordano' AS SOUGHT, 'Marco Tullio Giordana' AS FUZZY_CANDIDATE, 'en985:1 fr985:1' AS EVALS UNION ALL
SELECT 'martin scorcese' AS SOUGHT, 'Martin Scorsese' AS FUZZY_CANDIDATE, 'en490:1 en539:1 fr490:1 fr539:1' AS EVALS UNION ALL
SELECT 'park Chan wook' AS SOUGHT, 'Park Chan-wook' AS FUZZY_CANDIDATE, 'en2136:1' AS EVALS UNION ALL
SELECT 'sasha guitry' AS SOUGHT, 'Sacha Guitry' AS FUZZY_CANDIDATE, 'en640:1' AS EVALS UNION ALL
SELECT 'yasujiro ozu' AS SOUGHT, 'Yasujirō Ozu' AS FUZZY_CANDIDATE, 'en593:1' AS EVALS
), r AS (
  SELECT s.SOUGHT, s.FUZZY_CANDIDATE, s.EVALS,
         (SELECT p.ID_PERSON FROM T_WC_T2S_PERSON p WHERE p.PERSON_NAME = s.FUZZY_CANDIDATE
           ORDER BY p.POPULARITY DESC LIMIT 1) AS FUZZY_ID,
         (SELECT a.ID_PERSON FROM T_WC_T2S_PERSON_ALSO_KNOWN_AS a
            LEFT JOIN T_WC_T2S_PERSON p ON p.ID_PERSON = a.ID_PERSON
           WHERE a.PERSON_NAME_NORM = LCASE(REGEXP_REPLACE(REGEXP_REPLACE(s.SOUGHT, '[^\p{L}\p{M}\p{N} ]+', ' '), ' +', ' '))
           ORDER BY COALESCE(p.POPULARITY, 0) DESC, a.ID_ROW ASC LIMIT 1) AS ALIAS_ID,
         (SELECT GROUP_CONCAT(DISTINCT CONCAT(a.ID_PERSON, ' ', p.PERSON_NAME, ' (', ROUND(p.POPULARITY, 1), ', ', a.ALIAS_SOURCE, ')')
                              ORDER BY p.POPULARITY DESC SEPARATOR ' | ')
            FROM T_WC_T2S_PERSON_ALSO_KNOWN_AS a
            JOIN T_WC_T2S_PERSON p ON p.ID_PERSON = a.ID_PERSON
           WHERE a.PERSON_NAME_NORM = LCASE(REGEXP_REPLACE(REGEXP_REPLACE(s.SOUGHT, '[^\p{L}\p{M}\p{N} ]+', ' '), ' +', ' '))) AS ALIAS_OWNERS
  FROM s
)
SELECT CASE WHEN ALIAS_ID IS NULL THEN 'NONE' WHEN ALIAS_ID = FUZZY_ID THEN 'SAME' ELSE 'DIFFERENT' END AS VERDICT,
       COUNT(*) AS PAIRS
FROM r GROUP BY VERDICT ORDER BY VERDICT;

WITH s AS (
SELECT 'Andre Previn' AS SOUGHT, 'André Previn' AS FUZZY_CANDIDATE, 'en829:1 fr829:1' AS EVALS UNION ALL
SELECT 'Arnaud Depleschin' AS SOUGHT, 'Arnaud Desplechin' AS FUZZY_CANDIDATE, 'en2227:1' AS EVALS UNION ALL
SELECT 'Arnold schwarzeneger' AS SOUGHT, 'Arnold Schwarzenegger' AS FUZZY_CANDIDATE, 'en1111:1' AS EVALS UNION ALL
SELECT 'Catherine allegret' AS SOUGHT, 'Catherine Allégret' AS FUZZY_CANDIDATE, 'en1074:1' AS EVALS UNION ALL
SELECT 'Charles Chaplin' AS SOUGHT, 'Charles Champlin' AS FUZZY_CANDIDATE, 'en2262:0' AS EVALS UNION ALL
SELECT 'Chu Kong' AS SOUGHT, 'Chu Bong' AS FUZZY_CANDIDATE, 'en2629:0 fr2629:0' AS EVALS UNION ALL
SELECT 'Céline Song' AS SOUGHT, 'Celine Song' AS FUZZY_CANDIDATE, 'fr1045:1' AS EVALS UNION ALL
SELECT 'Dany Elfman' AS SOUGHT, 'Danny Elfman' AS FUZZY_CANDIDATE, 'fr831:1' AS EVALS UNION ALL
SELECT 'Edward g Robinson' AS SOUGHT, 'Edward G. Robinson' AS FUZZY_CANDIDATE, 'en905:1' AS EVALS UNION ALL
SELECT 'Francois Reichenbach' AS SOUGHT, 'François Reichenbach' AS FUZZY_CANDIDATE, 'en1105:1 fr1105:1' AS EVALS UNION ALL
SELECT 'Frederic Chopin' AS SOUGHT, 'Frédéric Chopin' AS FUZZY_CANDIDATE, 'en1121:0 en1122:1 en67:1' AS EVALS UNION ALL
SELECT 'Gerard Rinaldi' AS SOUGHT, 'Gérard Rinaldi' AS FUZZY_CANDIDATE, 'en999:1 fr999:1' AS EVALS UNION ALL
SELECT 'Hillary Swank' AS SOUGHT, 'Hilary Swank' AS FUZZY_CANDIDATE, 'en2328:1 fr2328:1' AS EVALS UNION ALL
SELECT 'J. K. Rowling' AS SOUGHT, 'J.K. Rowling' AS FUZZY_CANDIDATE, 'en274:1 fr274:1' AS EVALS UNION ALL
SELECT 'Jean Christophe grange' AS SOUGHT, 'Jean-Christophe Grangé' AS FUZZY_CANDIDATE, 'en982:1' AS EVALS UNION ALL
SELECT 'Jean Laurent Cochet' AS SOUGHT, 'Jean-Laurent Cochet' AS FUZZY_CANDIDATE, 'fr691:1' AS EVALS UNION ALL
SELECT 'Jean Laurent cochet' AS SOUGHT, 'Jean-Laurent Cochet' AS FUZZY_CANDIDATE, 'en691:1' AS EVALS UNION ALL
SELECT 'Jean Pierre Mocky' AS SOUGHT, 'Jean-Pierre Mocky' AS FUZZY_CANDIDATE, 'fr992:1' AS EVALS UNION ALL
SELECT 'Jean Pierre mocky' AS SOUGHT, 'Jean-Pierre Mocky' AS FUZZY_CANDIDATE, 'en992:1' AS EVALS UNION ALL
SELECT 'Jeff Bridge' AS SOUGHT, 'Jeff Bridges' AS FUZZY_CANDIDATE, 'fr305:1' AS EVALS UNION ALL
SELECT 'Jeff bridge' AS SOUGHT, 'Jeff Bridges' AS FUZZY_CANDIDATE, 'en305:1' AS EVALS UNION ALL
SELECT 'Jenny Aguter' AS SOUGHT, 'Jenny Agutter' AS FUZZY_CANDIDATE, 'fr1110:1' AS EVALS UNION ALL
SELECT 'Jenny aguter' AS SOUGHT, 'Jenny Agutter' AS FUZZY_CANDIDATE, 'en1110:1' AS EVALS UNION ALL
SELECT 'Johnathan Swift' AS SOUGHT, 'Jonathan Swift' AS FUZZY_CANDIDATE, 'fr1016:1' AS EVALS UNION ALL
SELECT 'Johnathan swift' AS SOUGHT, 'Jonathan Swift' AS FUZZY_CANDIDATE, 'en1016:1' AS EVALS UNION ALL
SELECT 'Jude Apatow' AS SOUGHT, 'Judd Apatow' AS FUZZY_CANDIDATE, 'fr830:1' AS EVALS UNION ALL
SELECT 'Jude appatow' AS SOUGHT, 'Judd Apatow' AS FUZZY_CANDIDATE, 'en830:1' AS EVALS UNION ALL
SELECT 'Katherine Hepburn' AS SOUGHT, 'Katharine Hepburn' AS FUZZY_CANDIDATE, 'en2329:1 fr2329:1 fr506:1' AS EVALS UNION ALL
SELECT 'Kléber Mendonça Filho' AS SOUGHT, 'Kleber Mendonça Filho' AS FUZZY_CANDIDATE, 'fr1097:1 fr980:1' AS EVALS UNION ALL
SELECT 'Kléber mendoca filho' AS SOUGHT, 'Kleber Mendonça Filho' AS FUZZY_CANDIDATE, 'en980:1' AS EVALS UNION ALL
SELECT 'Kléber mendonca filho' AS SOUGHT, 'Kleber Mendonça Filho' AS FUZZY_CANDIDATE, 'en1097:1' AS EVALS UNION ALL
SELECT 'Krzysztof Kieslowski' AS SOUGHT, 'Krzysztof Kieślowski' AS FUZZY_CANDIDATE, 'en2604:1 fr2604:1' AS EVALS UNION ALL
SELECT 'Leonardo di caprio' AS SOUGHT, 'Leonardo DiCaprio' AS FUZZY_CANDIDATE, 'en524:1 en525:1 fr524:1 fr525:1' AS EVALS UNION ALL
SELECT 'Marion Morrison' AS SOUGHT, 'Marq Morrison' AS FUZZY_CANDIDATE, 'en2478:0 fr2478:0' AS EVALS UNION ALL
SELECT 'Martin Scorcese' AS SOUGHT, 'Martin Scorsese' AS FUZZY_CANDIDATE, 'en2278:1 en64:1' AS EVALS UNION ALL
SELECT 'Martin scorcese' AS SOUGHT, 'Martin Scorsese' AS FUZZY_CANDIDATE, 'en731:0' AS EVALS UNION ALL
SELECT 'Michele pfeiffer' AS SOUGHT, 'Michelle Pfeiffer' AS FUZZY_CANDIDATE, 'en1077:0' AS EVALS UNION ALL
SELECT 'Paul gegauf' AS SOUGHT, 'Paul Gégauff' AS FUZZY_CANDIDATE, 'en708:1 fr708:1' AS EVALS UNION ALL
SELECT 'RICARDO FREDA' AS SOUGHT, 'Riccardo Freda' AS FUZZY_CANDIDATE, 'en2330:1 fr2330:1' AS EVALS UNION ALL
SELECT 'Sasha Guitry' AS SOUGHT, 'Sacha Guitry' AS FUZZY_CANDIDATE, 'fr640:1' AS EVALS UNION ALL
SELECT 'Suzanne schifman' AS SOUGHT, 'Suzanne Schiffman' AS FUZZY_CANDIDATE, 'en853:1 fr853:1' AS EVALS UNION ALL
SELECT 'Toshiro Mifune' AS SOUGHT, 'Toshirō Mifune' AS FUZZY_CANDIDATE, 'en2140:1 en2141:1 fr2140:1 fr2141:1' AS EVALS UNION ALL
SELECT 'Vincent Barré' AS SOUGHT, 'Vincent Darré' AS FUZZY_CANDIDATE, 'en863:0 fr863:0' AS EVALS UNION ALL
SELECT 'david gauque' AS SOUGHT, 'David Gauquié' AS FUZZY_CANDIDATE, 'en1108:1 fr1108:1' AS EVALS UNION ALL
SELECT 'dwayne jonson' AS SOUGHT, 'Dwayne Johnson' AS FUZZY_CANDIDATE, 'en878:1 en879:0' AS EVALS UNION ALL
SELECT 'elisabeth ii' AS SOUGHT, 'Elisabeth Quin' AS FUZZY_CANDIDATE, 'en849:0' AS EVALS UNION ALL
SELECT 'francoise Arnoul' AS SOUGHT, 'Françoise Arnoul' AS FUZZY_CANDIDATE, 'en852:1' AS EVALS UNION ALL
SELECT 'humphrey bogard' AS SOUGHT, 'Humphrey Bogart' AS FUZZY_CANDIDATE, 'en871:1' AS EVALS UNION ALL
SELECT 'john frankheimer' AS SOUGHT, 'John Frankenheimer' AS FUZZY_CANDIDATE, 'en1060:1 fr1060:1' AS EVALS UNION ALL
SELECT 'john voigt' AS SOUGHT, 'Jon Voight' AS FUZZY_CANDIDATE, 'en565:1' AS EVALS UNION ALL
SELECT 'katherine hepburn' AS SOUGHT, 'Katharine Hepburn' AS FUZZY_CANDIDATE, 'en506:1' AS EVALS UNION ALL
SELECT 'lauren bacal' AS SOUGHT, 'Lauren Bacall' AS FUZZY_CANDIDATE, 'en508:1' AS EVALS UNION ALL
SELECT 'leonardo di caprio' AS SOUGHT, 'Leonardo DiCaprio' AS FUZZY_CANDIDATE, 'en490:1 fr490:1' AS EVALS UNION ALL
SELECT 'louis de funes' AS SOUGHT, 'Louis de Funès' AS FUZZY_CANDIDATE, 'en485:1 en510:1' AS EVALS UNION ALL
SELECT 'marcello mastrioanni' AS SOUGHT, 'Marcello Mastroianni' AS FUZZY_CANDIDATE, 'en514:1' AS EVALS UNION ALL
SELECT 'marcello mastroiani' AS SOUGHT, 'Marcello Mastroianni' AS FUZZY_CANDIDATE, 'en728:1 fr728:1' AS EVALS UNION ALL
SELECT 'marco tullio giordano' AS SOUGHT, 'Marco Tullio Giordana' AS FUZZY_CANDIDATE, 'en985:1 fr985:1' AS EVALS UNION ALL
SELECT 'martin scorcese' AS SOUGHT, 'Martin Scorsese' AS FUZZY_CANDIDATE, 'en490:1 en539:1 fr490:1 fr539:1' AS EVALS UNION ALL
SELECT 'park Chan wook' AS SOUGHT, 'Park Chan-wook' AS FUZZY_CANDIDATE, 'en2136:1' AS EVALS UNION ALL
SELECT 'sasha guitry' AS SOUGHT, 'Sacha Guitry' AS FUZZY_CANDIDATE, 'en640:1' AS EVALS UNION ALL
SELECT 'yasujiro ozu' AS SOUGHT, 'Yasujirō Ozu' AS FUZZY_CANDIDATE, 'en593:1' AS EVALS
)
SELECT s.SOUGHT, s.FUZZY_CANDIDATE, s.EVALS,
       (SELECT p.ID_PERSON FROM T_WC_T2S_PERSON p WHERE p.PERSON_NAME = s.FUZZY_CANDIDATE
         ORDER BY p.POPULARITY DESC LIMIT 1) AS FUZZY_ID,
       (SELECT GROUP_CONCAT(DISTINCT CONCAT(a.ID_PERSON, ' ', p.PERSON_NAME, ' (', ROUND(p.POPULARITY, 1), ', ', a.ALIAS_SOURCE, ')')
                            ORDER BY p.POPULARITY DESC SEPARATOR ' | ')
          FROM T_WC_T2S_PERSON_ALSO_KNOWN_AS a
          JOIN T_WC_T2S_PERSON p ON p.ID_PERSON = a.ID_PERSON
         WHERE a.PERSON_NAME_NORM = LCASE(REGEXP_REPLACE(REGEXP_REPLACE(s.SOUGHT, '[^\p{L}\p{M}\p{N} ]+', ' '), ' +', ' '))) AS ALIAS_OWNERS
FROM s
ORDER BY ALIAS_OWNERS IS NULL, s.SOUGHT;
