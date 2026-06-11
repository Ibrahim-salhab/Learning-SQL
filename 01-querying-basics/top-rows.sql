-- ============================================================
-- Topic: Limiting Output with TOP
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Restricting the number of rows returned by a query
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Basic TOP with fixed row count
-- ------------------------------------------------------------

SELECT TOP (5)
    order_id,
    order_date,
    total_amount
FROM sales.orders
ORDER BY total_amount DESC;


-- ------------------------------------------------------------
-- Example 2: TOP with PERCENT
-- ------------------------------------------------------------

-- Returns top 10 percent of highest-paid employees
SELECT TOP (10) PERCENT
    employee_id,
    first_name,
    last_name,
    salary
FROM hr.employees
ORDER BY salary DESC;


-- ------------------------------------------------------------
-- Example 3: TOP with WITH TIES
-- ------------------------------------------------------------

-- Returns top 3 rows plus any additional rows that share the same price as the 3rd row
SELECT TOP (3) WITH TIES
    product_name,
    unit_price
FROM inventory.products
ORDER BY unit_price DESC;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- TOP without ORDER BY returns an arbitrary, non-deterministic subset of rows. Always pair TOP with ORDER BY when deterministic results are needed.
-- WITH TIES requires an explicit ORDER BY clause; without ORDER BY, SQL Server raises a syntax error.
-- Dialect differences:
--   - SQL Server: SELECT TOP (N) ...
--   - PostgreSQL / MySQL / SQLite: SELECT ... LIMIT N
--   - ANSI SQL / Oracle 12c+: FETCH FIRST N ROWS ONLY
-- In production queries, parentheses around the TOP count (e.g., TOP (10)) are standard and support parameterized values.

-- Updated: update progress tracking in notes
