-- ============================================================
-- Topic: CASE Expressions (Simple vs Searched)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Implementing conditional branching logic within SQL queries
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Simple CASE Expression (Equality checks on single column)
-- ------------------------------------------------------------

SELECT
    order_id,
    order_status_code,
    CASE order_status_code
        WHEN 'P' THEN 'Pending Payment'
        WHEN 'S' THEN 'Shipped'
        WHEN 'D' THEN 'Delivered'
        WHEN 'C' THEN 'Cancelled'
        ELSE 'Unknown Status'
    END AS readable_status
FROM sales.orders;


-- ------------------------------------------------------------
-- Example 2: Searched CASE Expression (Complex boolean expressions)
-- ------------------------------------------------------------

SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'Executive Tier'
        WHEN salary >= 70000  THEN 'Senior Tier'
        WHEN salary >= 45000  THEN 'Mid Tier'
        ELSE 'Associate Tier'
    END AS compensation_tier
FROM hr.employees;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Simple vs Searched CASE:
--   - Simple CASE (CASE col WHEN val THEN ...) tests only for direct equality (=).
--   - Searched CASE (CASE WHEN boolean_exp THEN ...) supports any valid boolean expression (>, <, BETWEEN, LIKE, IS NULL, compound AND/OR).
-- Sequential Short-Circuiting: Conditions are evaluated sequentially from top to bottom. The first WHEN condition that evaluates to TRUE returns its THEN value and halts further evaluation.
-- Missing ELSE Gotcha: If no WHEN condition matches and no ELSE clause is provided, the CASE expression defaults to returning NULL. Always include an explicit ELSE to avoid accidental NULLs.
-- Data Type Rule: All possible THEN and ELSE return values must be convertible to a single common data type based on SQL Server data type precedence rules; otherwise a conversion error occurs.
