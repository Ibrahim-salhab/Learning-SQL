-- ============================================================
-- Topic: Subqueries Basics, Types & Clause Placements
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Nesting SELECT queries inside outer queries across SELECT, FROM, JOIN, and WHERE clauses
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Scalar Subquery in SELECT (Column Projection)
-- ------------------------------------------------------------

-- A scalar subquery returns exactly one value (1 row, 1 column)
SELECT
    product_id,
    product_name,
    unit_price,
    -- Scalar subquery: calculates overall average price across all products
    (SELECT AVG(unit_price) FROM inventory.products) AS overall_avg_price,
    unit_price - (SELECT AVG(unit_price) FROM inventory.products) AS price_diff_from_avg
FROM inventory.products;


-- ------------------------------------------------------------
-- Example 2: Table-Valued Subquery in FROM (Derived Table)
-- ------------------------------------------------------------

-- Every derived table MUST have an explicit alias (e.g., AS dept_metrics)
SELECT
    dept_metrics.department_id,
    dept_metrics.total_staff,
    dept_metrics.avg_salary
FROM (
    SELECT
        department_id,
        COUNT(employee_id) AS total_staff,
        AVG(salary) AS avg_salary
    FROM hr.employees
    GROUP BY department_id
) AS dept_metrics
WHERE dept_metrics.total_staff >= 5;


-- ------------------------------------------------------------
-- Example 3: Subquery in JOIN (Pre-aggregation before joining)
-- ------------------------------------------------------------

SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    ISNULL(recent_orders.last_order_date, '1900-01-01') AS last_order_date,
    ISNULL(recent_orders.total_spent, 0.00) AS total_spent
FROM sales.customers AS c
LEFT JOIN (
    SELECT
        customer_id,
        MAX(order_date) AS last_order_date,
        SUM(total_amount) AS total_spent
    FROM sales.orders
    GROUP BY customer_id
) AS recent_orders
    ON c.customer_id = recent_orders.customer_id;


-- ------------------------------------------------------------
-- Example 4: Subquery in WHERE (Scalar filter comparison)
-- ------------------------------------------------------------

-- Return products priced above the overall average catalog price
SELECT
    product_id,
    product_name,
    unit_price
FROM inventory.products
WHERE unit_price > (SELECT AVG(unit_price) FROM inventory.products);


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Subquery Result Classifications:
--   1. Scalar Subquery: Exactly 1 row and 1 column. Can be used anywhere a single literal value or expression is valid (=, >, <). If it returns 0 rows, it evaluates to NULL; if it returns > 1 row, SQL Server raises a runtime error (Msg 512).
--   2. Multi-Row / Single-Column: Returns 1 column with multiple rows. Used with list operators (IN, NOT IN, ANY, ALL).
--   3. Multi-Column / Table-Valued: Returns multiple rows and columns. Placed in FROM or JOIN as a derived table.
-- Mandatory Rule for Derived Tables:
--   - In T-SQL, every subquery in a FROM or JOIN clause MUST be assigned an explicit table alias (`AS alias_name`), or a syntax error occurs.
-- Performance Warning: Scalar subqueries in SELECT clauses run once per outer row if correlated, which can severely degrade performance on large tables. Prefer JOINs or CTEs.
