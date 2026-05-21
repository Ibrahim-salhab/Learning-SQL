-- ============================================================
-- Topic: HAVING Clause & Group Filtering
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Filtering aggregated groups after the GROUP BY operation has occurred
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Basic group filtering on aggregate condition
-- ------------------------------------------------------------

-- Target: Find departments with more than 5 employees
SELECT
    department_id,
    COUNT(employee_id) AS employee_count,
    AVG(salary) AS avg_department_salary
FROM hr.employees
GROUP BY department_id
HAVING COUNT(employee_id) > 5;


-- ------------------------------------------------------------
-- Example 2: Combining WHERE and HAVING in the same query
-- ------------------------------------------------------------

-- Target: Find customers who spent over $1,000 in completed orders during 2024
SELECT
    customer_id,
    COUNT(order_id) AS completed_orders_count,
    SUM(total_amount) AS total_spend
FROM sales.orders
WHERE order_status = 'Completed'     -- Filters raw rows BEFORE grouping
  AND order_date >= '2024-01-01'
GROUP BY customer_id
HAVING SUM(total_amount) >= 1000.00   -- Filters groups AFTER aggregation
ORDER BY total_spend DESC;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Difference between WHERE and HAVING:
--   - WHERE filters individual rows before grouping or aggregation occurs.
--   - HAVING filters group summaries after GROUP BY evaluates.
-- Never put non-aggregated row filters in HAVING if they can be evaluated in WHERE:
--   - Filtering rows early in WHERE reduces the number of records the engine must sort and group, yielding much better performance.
-- You can reference aggregate functions in HAVING that are not explicitly present in the SELECT clause.
-- Column aliases created in SELECT cannot be used in HAVING because HAVING executes before SELECT.
