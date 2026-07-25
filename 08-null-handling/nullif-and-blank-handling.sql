-- ============================================================
-- Topic: NULLIF, Blank Handling & Data Policies
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Preventing divide-by-zero errors with NULLIF and distinguishing NULL vs Empty String vs Blank Whitespace
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Preventing Divide-by-Zero using NULLIF
-- ------------------------------------------------------------

-- NULLIF(a, b) returns NULL if a = b; otherwise returns a
SELECT
    campaign_id,
    total_conversions,
    total_ad_clicks,
    -- If total_ad_clicks = 0, NULLIF returns NULL; division by NULL safely evaluates to NULL
    (total_conversions * 1.0) / NULLIF(total_ad_clicks, 0) AS conversion_rate
FROM marketing.campaign_metrics;


-- ------------------------------------------------------------
-- Example 2: Distinguishing NULL vs Empty String '' vs Whitespace ' '
-- ------------------------------------------------------------

-- Comparing string representations:
SELECT
    'NULL value' AS state_description,
    NULL AS raw_value,
    LEN(NULL) AS char_len,
    DATALENGTH(NULL) AS byte_len
UNION ALL
SELECT
    'Empty String',
    '',
    LEN(''),
    DATALENGTH('')
UNION ALL
SELECT
    'Whitespace String',
    '   ',
    LEN('   '),         -- Gotcha: LEN returns 0 for trailing whitespace!
    DATALENGTH('   ');   -- DATALENGTH returns actual 3 bytes


-- ------------------------------------------------------------
-- Example 3: Converting Blanks and Whitespace to NULL (Data Cleaning Policy)
-- ------------------------------------------------------------

SELECT
    customer_id,
    raw_middle_name,
    -- Converts '' or '   ' directly to NULL:
    NULLIF(TRIM(raw_middle_name), '') AS sanitized_middle_name
FROM staging.imported_users;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- NULLIF Syntax: NULLIF(expression1, expression2).
--   - If expression1 equals expression2, returns NULL.
--   - Otherwise, returns expression1.
--   - Standard idiom: expression / NULLIF(divisor, 0) prevents runtime Error 8134: "Divide by zero error encountered."
-- NULL vs Empty ('') vs Blank (' '):
--   - NULL represents missing, unknown, or unrecorded data.
--   - Empty string ('') represents known, defined text of zero length.
--   - Whitespace string (' ') contains ASCII 32 spaces.
-- Data Cleaning Pattern: NULLIF(TRIM(col), '') sanitizes messy dirty text data by mapping both empty strings and whitespace-only strings to true database NULLs.
