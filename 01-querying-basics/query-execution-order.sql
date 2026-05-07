-- ============================================================
-- Topic: Query Execution Order (Lexical vs Logical Processing)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Understanding how the database engine evaluates SQL queries vs how they are written
-- ============================================================


-- ------------------------------------------------------------
-- Syntactic (Written) Order vs Logical (Engine) Order
-- ------------------------------------------------------------

-- WRITTEN (Lexical) Order:
-- 1. SELECT (with TOP / DISTINCT)
-- 2. FROM
-- 3. WHERE
-- 4. GROUP BY
-- 5. HAVING
-- 6. ORDER BY

-- LOGICAL (Engine Execution) Order:
-- 1. FROM        -> Identifies source table(s) and joins
-- 2. WHERE       -> Filters raw rows before grouping
-- 3. GROUP BY    -> Aggregates rows into groups
-- 4. HAVING      -> Filters grouped rows
-- 5. SELECT      -> Evaluates expressions and creates column aliases
-- 6. DISTINCT    -> Removes duplicate rows from projected output
-- 7. ORDER BY    -> Sorts the resulting rows
-- 8. TOP / LIMIT -> Truncates result to requested row count / percentage


-- ------------------------------------------------------------
-- Practical Example: Why aliases fail in WHERE but work in ORDER BY
-- ------------------------------------------------------------

-- FAILS: Column alias 'annual_bonus' does not exist yet during WHERE phase
-- SELECT
--     employee_id,
--     salary * 0.15 AS annual_bonus
-- FROM hr.employees
-- WHERE annual_bonus > 5000; -- Error: Invalid column name 'annual_bonus'

-- CORRECT: Repeat expression in WHERE, or use a CTE / derived table
SELECT
    employee_id,
    salary * 0.15 AS annual_bonus
FROM hr.employees
WHERE (salary * 0.15) > 5000
ORDER BY annual_bonus DESC; -- Valid: ORDER BY executes after SELECT


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- The single biggest source of beginner SQL errors is assuming queries execute top-to-bottom as written.
-- Because FROM executes first, table aliases are available in all subsequent clauses (WHERE, SELECT, GROUP BY).
-- Because SELECT executes near the end (step 5), aliases defined in SELECT are invisible to WHERE, GROUP BY, and HAVING.
-- Because ORDER BY executes after SELECT (step 7), aliases defined in SELECT are fully accessible in ORDER BY.
-- TOP executes last (step 8) after the sort order has been determined by ORDER BY.
