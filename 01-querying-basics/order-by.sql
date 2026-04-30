-- ============================================================
-- Topic: ORDER BY Clause & Sorting
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Sorting query result sets in ascending or descending order across single or multiple columns
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Basic sorting with ASC and DESC
-- ------------------------------------------------------------

SELECT
    student_id,
    first_name,
    last_name,
    gpa
FROM school.students
ORDER BY gpa DESC;


-- ------------------------------------------------------------
-- Example 2: Multi-column sorting with mixed directions
-- ------------------------------------------------------------

SELECT
    department_name,
    last_name,
    first_name,
    hire_date
FROM hr.employees
ORDER BY
    department_name ASC,
    hire_date DESC;


-- ------------------------------------------------------------
-- Example 3: Sorting by expression or SELECT alias
-- ------------------------------------------------------------

SELECT
    order_id,
    quantity,
    unit_price,
    quantity * unit_price AS total_price
FROM sales.order_items
ORDER BY total_price DESC;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Default sort direction is ASC (ascending: lowest to highest, A-Z, earliest date to latest date).
-- ORDER BY executes logically AFTER the SELECT phase. Therefore, column aliases defined in SELECT can be used in ORDER BY.
-- Multi-column sorting evaluates sequentially from left to right: column 1 is sorted first; column 2 resolves ties in column 1.
-- SQL Server NULL behavior: NULL values sort as the lowest possible values (they appear first in ASC, last in DESC).
-- Positional sorting (e.g., ORDER BY 1, 2) is valid syntax but considered an anti-pattern because changing column order in SELECT breaks the sort silently.
