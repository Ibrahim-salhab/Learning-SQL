-- ============================================================
-- Topic: Type Casting & Formatting (CAST, CONVERT, FORMAT)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Converting between data types and formatting dates, numbers, and currencies
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: ANSI Standard CAST
-- ------------------------------------------------------------

SELECT
    order_id,
    -- Convert numeric price to integer:
    CAST(unit_price AS INT) AS integer_price,
    -- Convert date to string:
    CAST(order_date AS VARCHAR(10)) AS order_date_string,
    -- Convert integer to decimal for precise math:
    CAST(quantity AS DECIMAL(8, 2)) AS decimal_quantity
FROM sales.order_items;


-- ------------------------------------------------------------
-- Example 2: T-SQL CONVERT with Style Codes
-- ------------------------------------------------------------

SELECT
    GETDATE() AS raw_datetime,
    -- Style 101: US standard mm/dd/yyyy
    CONVERT(VARCHAR(10), GETDATE(), 101) AS us_date_format,
    -- Style 103: British / French standard dd/mm/yyyy
    CONVERT(VARCHAR(10), GETDATE(), 103) AS uk_date_format,
    -- Style 120: ODBC Canonical standard yyyy-mm-dd hh:mi:ss (24h)
    CONVERT(VARCHAR(19), GETDATE(), 120) AS iso_canonical_format,
    -- Style 112: ISO standard yyyymmdd (compact date)
    CONVERT(VARCHAR(8), GETDATE(), 112) AS compact_iso_date;


-- ------------------------------------------------------------
-- Example 3: FORMAT for culture-specific display
-- ------------------------------------------------------------

SELECT
    order_id,
    total_amount,
    order_date,
    -- Currency in US Dollars:
    FORMAT(total_amount, 'C', 'en-US') AS amount_usd,
    -- Currency in Jordanian Dinars:
    FORMAT(total_amount, 'C', 'ar-JO') AS amount_jod,
    -- Custom date format:
    FORMAT(order_date, 'dddd, MMMM dd, yyyy') AS verbose_date
FROM sales.orders;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- CAST vs CONVERT vs FORMAT:
--   - CAST is ANSI SQL standard; works across SQL Server, PostgreSQL, MySQL, Oracle.
--   - CONVERT is T-SQL specific; essential for parsing and outputting specific date/time string styles (e.g. style 101, 103, 120).
--   - FORMAT is powered by the .NET CLR; extremely flexible for localized currencies and strings.
-- PERFORMANCE CRITICAL WARNING: FORMAT() has substantial overhead because it invokes the .NET CLR runtime per row. Avoid FORMAT() inside large queries, WHERE clauses, or JOINs. Use CONVERT for high-throughput data processing.
-- Style Code Tip: Adding 100 to a 2-digit year style produces a 4-digit year (e.g., style 1 is mm/dd/yy; style 101 is mm/dd/yyyy).
