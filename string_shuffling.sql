-- function that returns a table with word or group of words from original string in each table row
CREATE OR REPLACE FUNCTION split_string(string varchar, min_len int)
    RETURNS table
            (
                word_group varchar
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    words       varchar[];
    word_group  varchar = '';
    word_groups varchar[];
BEGIN
    SELECT string_to_array(string, ' ')
    INTO words;
    FOR i IN 1..array_length(words, 1)
        LOOP
            word_group = word_group || words[i];
            IF i = array_length(words, 1) THEN
                word_groups = word_groups || word_group;
            ELSE
                IF length(words[i]) <= min_len THEN
                    word_group = word_group || ' ';
                ELSE
                    word_groups = word_groups || word_group;
                    word_group = '';
                END IF;
            END IF;
        END LOOP;
    RETURN QUERY
        SELECT *
        FROM unnest(word_groups);
END;
$$;

--test function
SELECT *
FROM split_string('testing and testing 1, 2, 3', 3);

--return all permutations of the string

WITH RECURSIVE
words(word) AS (
            SELECT *
            FROM split_string('You can test your string here', 3)
            ),
    tab  AS (
            SELECT word AS combo, word, 1 AS ct
            FROM words
            UNION ALL
            SELECT tab.combo || ' ' || words.word, words.word, ct + 1
            FROM tab
            JOIN words
                ON position(words.word IN tab.combo) = 0
            )
SELECT combo
FROM (
     SELECT *, RANK() OVER (PARTITION BY word ORDER BY ct DESC) AS rank
     FROM tab
     ) ranked
WHERE rank = 1;