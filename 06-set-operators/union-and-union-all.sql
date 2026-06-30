-- ============================================================
-- Topic: SET Operators - UNION & UNION ALL
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Combining result sets from multiple queries vertically into a single output
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: UNION (Combines and eliminates duplicate rows)
-- ------------------------------------------------------------

-- Combine internal full-time employees and external contractor rosters without duplicates
SELECT
    first_name,
    last_name,
    email,
    'Internal' AS worker_type
FROM hr.employees
WHERE is_active = 1

UNION

SELECT
    first_name,
    last_name,
    email,
    'Contractor' AS worker_type
FROM hr.contractors
WHERE is_active = 1
ORDER BY last_name, first_name;


-- ------------------------------------------------------------
-- Example 2: UNION ALL (Combines all rows, preserving duplicates)
-- ------------------------------------------------------------

-- Appending historical archive orders to current active orders without deduplication overhead
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    'Current' AS source_table
FROM sales.orders

UNION ALL

SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    'Archive' AS source_table
FROM archive.historical_orders;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- SET Operator Syntax Rules:
--   1. Number of columns in each SELECT query must be identical.
--   2. Data types of corresponding columns must be compatible (implicit conversion must succeed).
--   3. Column names and aliases in the final output are determined solely by the FIRST query.
--   4. ORDER BY can only appear ONCE, at the very end of the entire combined statement.
-- UNION vs UNION ALL:
--   - UNION executes an internal sort/hash operation to identify and eliminate duplicate rows.
--   - UNION ALL simply concatenates the result streams without checking for duplicates.
-- Performance Rule: Always prefer UNION ALL unless duplicate elimination is an explicit business requirement.
