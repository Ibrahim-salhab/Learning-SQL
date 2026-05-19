-- ============================================================
-- Topic: GROUP BY Clause & Aggregations
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Collapsing multiple rows into summary groups using aggregate functions (COUNT, SUM, AVG, MIN, MAX)
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Basic grouping with single aggregate
-- ------------------------------------------------------------

SELECT
    department_id,
    COUNT(*) AS total_employees,
    AVG(salary) AS average_salary
FROM hr.employees
GROUP BY department_id;


-- ------------------------------------------------------------
-- Example 2: Grouping across multiple columns
-- ------------------------------------------------------------

SELECT
    warehouse_id,
    category_id,
    COUNT(product_id) AS total_items,
    SUM(stock_quantity) AS total_units_in_stock,
    MAX(unit_price) AS highest_priced_item
FROM inventory.stock
GROUP BY
    warehouse_id,
    category_id;


-- ------------------------------------------------------------
-- Example 3: Grouping with date expressions
-- ------------------------------------------------------------

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(order_id) AS orders_placed,
    SUM(total_amount) AS monthly_revenue
FROM sales.orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year DESC,
    order_month DESC;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Golden Rule of GROUP BY: Any column in the SELECT list that is NOT inside an aggregate function must be included in the GROUP BY clause.
-- Aggregate function behaviors:
--   - COUNT(*) counts all rows, including rows where columns contain NULL.
--   - COUNT(column_name) counts non-NULL values only.
--   - SUM(), AVG(), MIN(), MAX() ignore NULL values during computation.
-- GROUP BY collapses all NULL values in the grouping column into a single combined group.
-- WHERE filters individual rows BEFORE they are grouped; it cannot filter on aggregate results.
