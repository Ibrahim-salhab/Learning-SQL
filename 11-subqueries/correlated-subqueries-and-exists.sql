-- ============================================================
-- Topic: Correlated Subqueries & EXISTS / NOT EXISTS
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Writing row-dependent correlated subqueries and leveraging short-circuit boolean checks with EXISTS
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Correlated Subquery in WHERE
-- ------------------------------------------------------------

-- Target: Find employees who earn MORE than the average salary of their OWN department
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    e.salary
FROM hr.employees AS e
WHERE e.salary > (
    -- Subquery references outer query table e: Evaluates per candidate row of e
    SELECT AVG(sub.salary)
    FROM hr.employees AS sub
    WHERE sub.department_id = e.department_id
);


-- ------------------------------------------------------------
-- Example 2: Subquery using EXISTS
-- ------------------------------------------------------------

-- Target: Find customers who placed at least one order in 2024
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM sales.customers AS c
WHERE EXISTS (
    -- Returns TRUE as soon as the first matching order is found (Short-circuits)
    SELECT 1
    FROM sales.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_date >= '2024-01-01'
      AND o.order_date < '2025-01-01'
);


-- ------------------------------------------------------------
-- Example 3: Subquery using NOT EXISTS
-- ------------------------------------------------------------

-- Target: Find products that have never been ordered
SELECT
    p.product_id,
    p.product_name,
    p.unit_price
FROM inventory.products AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM sales.order_items AS oi
    WHERE oi.product_id = p.product_id
);


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Correlated Subquery Mechanics:
--   - An uncorrelated subquery executes ONCE, and its result is reused by the outer query.
--   - A correlated subquery contains a reference to columns from the outer query; it executes once for EVERY candidate row processed by the outer query.
-- EXISTS Operator Characteristics:
--   - Tests purely for the existence of rows; does NOT return or pass data back to the outer query.
--   - Short-circuit evaluation: The database stops scanning the inner table as soon as a single matching record is located.
--   - Projection convention: By convention, developers write `SELECT 1` or `SELECT *` inside EXISTS; the optimizer ignores the SELECT list entirely.
--   - NULL Immunity: NOT EXISTS is completely immune to the NULL bug that plagues NOT IN. If the inner query encounters NULL keys, NOT EXISTS continues evaluating reliably.
