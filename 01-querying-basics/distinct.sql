-- ============================================================
-- Topic: DISTINCT Keyword
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Eliminating duplicate rows from query output
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Distinct values across a single column
-- ------------------------------------------------------------

SELECT DISTINCT
    country
FROM sales.customers;


-- ------------------------------------------------------------
-- Example 2: Distinct combinations across multiple columns
-- ------------------------------------------------------------

SELECT DISTINCT
    department_id,
    job_title
FROM hr.employees;


-- ------------------------------------------------------------
-- Example 3: DISTINCT with COUNT aggregate preview
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT category_id) AS unique_categories_count
FROM inventory.products;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- DISTINCT applies to the entire row of selected columns, not just the first column listed.
-- Example: SELECT DISTINCT col_a, col_b returns unique pairs of (col_a, col_b).
-- For DISTINCT purposes, SQL treats all NULL values as identical, returning at most one NULL.
-- Performance Gotcha: DISTINCT requires sorting or hashing in memory to identify duplicates.
-- Avoid using DISTINCT as a quick fix for poorly joined queries that produce accidental duplicate rows.
