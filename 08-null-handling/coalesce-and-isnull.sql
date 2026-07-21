-- ============================================================
-- Topic: COALESCE vs ISNULL
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Handling missing values, evaluating fallbacks, and understanding subtle differences between COALESCE and ISNULL
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Basic NULL replacement
-- ------------------------------------------------------------

SELECT
    customer_id,
    first_name,
    last_name,
    ISNULL(phone_number, 'No Phone on Record') AS contact_phone_isnull,
    COALESCE(phone_number, 'No Phone on Record') AS contact_phone_coalesce
FROM sales.customers;


-- ------------------------------------------------------------
-- Example 2: Multi-argument fallback cascade with COALESCE
-- ------------------------------------------------------------

-- Priority order: Mobile -> Office -> Home -> Company Default
SELECT
    employee_id,
    first_name,
    last_name,
    COALESCE(
        mobile_phone,
        office_phone,
        home_phone,
        '+1-800-555-0100'
    ) AS primary_contact_number
FROM hr.employees;


-- ------------------------------------------------------------
-- Example 3: The Data Type Truncation Trap (ISNULL vs COALESCE)
-- ------------------------------------------------------------

-- In ISNULL, the return type is fixed to the data type of the 1ST argument!
-- If first arg is VARCHAR(5), a longer replacement gets silently truncated.
DECLARE @short_code VARCHAR(3) = NULL;

-- Returns 'UNK' (truncated from 'Unknown'):
SELECT ISNULL(@short_code, 'Unknown') AS isnull_truncated_result;

-- Returns 'Unknown' (promotes to highest precedence / widest type):
SELECT COALESCE(@short_code, 'Unknown') AS coalesce_safe_result;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Key Differences between ISNULL and COALESCE:
--   1. Portability: ISNULL is proprietary to T-SQL; COALESCE is ANSI SQL standard and works across all major RDBMSs.
--   2. Arguments: ISNULL accepts exactly 2 arguments; COALESCE accepts 2 or more arguments.
--   3. Data Type Resolution:
--      - ISNULL adopts the data type of the FIRST argument (causes truncation if the 2nd argument is wider!).
--      - COALESCE adopts the data type with the HIGHEST precedence among all arguments.
--   4. Evaluation: COALESCE is internally translated by SQL Server into a CASE expression (CASE WHEN val1 IS NOT NULL THEN val1 ...).
