-- ============================================================
-- Topic: Built-In String Functions
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Transforming, formatting, trimming, and extracting text values
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Case manipulation and whitespace trimming
-- ------------------------------------------------------------

SELECT
    raw_user_input,
    UPPER(raw_user_input) AS uppercase_text,
    LOWER(raw_user_input) AS lowercase_text,
    TRIM(raw_user_input) AS trimmed_text,     -- Strips leading & trailing spaces (SQL Server 2017+)
    LTRIM(raw_user_input) AS left_trimmed,
    RTRIM(raw_user_input) AS right_trimmed
FROM staging.raw_imports;


-- ------------------------------------------------------------
-- Example 2: String concatenation (CONCAT vs + operator)
-- ------------------------------------------------------------

-- CONCAT automatically converts non-strings and treats NULL as an empty string ''
SELECT
    first_name,
    middle_name,
    last_name,
    -- If middle_name is NULL, + yields NULL:
    first_name + ' ' + middle_name + ' ' + last_name AS unsafe_plus_concat,
    -- CONCAT safely ignores NULLs:
    CONCAT(first_name, ' ' + middle_name + ' ', last_name) AS safe_concat,
    CONCAT_WS(' ', first_name, middle_name, last_name) AS safe_concat_with_separator
FROM hr.employees;


-- ------------------------------------------------------------
-- Example 3: Substring extraction and length measurement
-- ------------------------------------------------------------

SELECT
    phone_number,
    LEFT(phone_number, 3) AS area_code,
    RIGHT(phone_number, 4) AS line_number,
    SUBSTRING(phone_number, 5, 3) AS prefix_number,
    LEN(phone_number) AS character_length,
    DATALENGTH(phone_number) AS byte_length
FROM sales.customer_contacts;


-- ------------------------------------------------------------
-- Example 4: Text replacement and cleaning
-- ------------------------------------------------------------

SELECT
    description,
    REPLACE(description, 'N/A', 'Not Specified') AS cleaned_description,
    REPLACE(REPLACE(phone_number, '(', ''), ')', '') AS normalized_phone
FROM inventory.product_notes;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- LEN vs DATALENGTH:
--   - LEN() returns character count, but silently IGNORES trailing spaces!
--   - DATALENGTH() returns actual byte count including trailing spaces. For NVARCHAR (2 bytes per character), DATALENGTH is twice LEN.
-- SUBSTRING(string, start_position, length):
--   - SQL uses 1-based indexing (the first character is position 1, NOT 0).
-- CONCAT vs + :
--   - 'Hello ' + NULL evaluates to NULL (due to ANSI NULL propagation).
--   - CONCAT('Hello ', NULL) converts NULL to an empty string and returns 'Hello '.
-- TRIM in modern T-SQL (2017+) can strip specific characters: TRIM('xyz' FROM column_name).
