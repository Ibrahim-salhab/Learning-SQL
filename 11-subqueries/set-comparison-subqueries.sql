-- ============================================================
-- Topic: Subqueries with Set Comparison Operators (IN, ANY, ALL)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Filtering outer query rows against multi-row subquery result lists using IN, ANY/SOME, and ALL
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Subquery using IN & NOT IN
-- ------------------------------------------------------------

-- Target: Find customers who placed high-value orders (> $2,000)
SELECT
    customer_id,
    first_name,
    last_name,
    email
FROM sales.customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM sales.orders
    WHERE total_amount > 2000.00
);


-- ------------------------------------------------------------
-- Example 2: Subquery using ANY (or SOME)
-- ------------------------------------------------------------

-- Target: Find employees earning more than ANY senior engineer in department 10
-- (Equivalent to: salary > MIN(senior engineer salaries in dept 10))
SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM hr.employees
WHERE salary > ANY (
    SELECT salary
    FROM hr.employees
    WHERE department_id = 10
      AND job_title LIKE 'Senior%'
);


-- ------------------------------------------------------------
-- Example 3: Subquery using ALL
-- ------------------------------------------------------------

-- Target: Find products whose price is greater than ALL products in Category 5
-- (Equivalent to: unit_price > MAX(prices in Category 5))
SELECT
    product_id,
    product_name,
    category_id,
    unit_price
FROM inventory.products
WHERE unit_price > ALL (
    SELECT unit_price
    FROM inventory.products
    WHERE category_id = 5
);


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- ANY (or SOME):
--   - Returns TRUE if the comparison is true for AT LEAST ONE value returned by the subquery.
--   - `> ANY (subquery)` is logically equivalent to `> MIN(subquery)`.
--   - `= ANY (subquery)` is identical to `IN (subquery)`.
-- ALL:
--   - Returns TRUE only if the comparison is true for EVERY value returned by the subquery.
--   - `> ALL (subquery)` is logically equivalent to `> MAX(subquery)`.
--   - `<> ALL (subquery)` is identical to `NOT IN (subquery)`.
-- The Subquery NULL Trap:
--   - If the subquery in NOT IN / <> ALL returns even a SINGLE NULL row, the entire predicate becomes UNKNOWN and returns 0 rows!
--   - Best Practice: Always include `WHERE col IS NOT NULL` inside subqueries feeding NOT IN or ALL.
