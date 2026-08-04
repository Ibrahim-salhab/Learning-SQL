-- ============================================================
-- Topic: Window Functions Fundamentals & OVER Clause
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Understanding window function execution, OVER clause components (PARTITION BY, ORDER BY, Framing), and contrast with GROUP BY
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Window Function vs GROUP BY (Granularity comparison)
-- ------------------------------------------------------------

-- GROUP BY collapses rows: Returns 1 row per department, losing employee details
-- SELECT department_id, AVG(salary) AS avg_sal FROM hr.employees GROUP BY department_id;

-- Window Function preserves individual rows while appending aggregated context
SELECT
    employee_id,
    first_name + ' ' + last_name AS employee_name,
    department_id,
    salary,
    -- Calculates average salary for the employee's department:
    AVG(salary) OVER(PARTITION BY department_id) AS dept_avg_salary,
    -- Calculates average salary across the entire company:
    AVG(salary) OVER() AS company_avg_salary,
    -- Difference from department average:
    salary - AVG(salary) OVER(PARTITION BY department_id) AS salary_diff_from_dept_avg
FROM hr.employees;


-- ------------------------------------------------------------
-- Example 2: PARTITION BY and ORDER BY within OVER()
-- ------------------------------------------------------------

SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    -- Cumulative spend per customer ordered chronologically:
    SUM(total_amount) OVER(
        PARTITION BY customer_id
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS customer_running_spend
FROM sales.orders;


-- ------------------------------------------------------------
-- Example 3: Window Framing (ROWS vs RANGE)
-- ------------------------------------------------------------

SELECT
    transaction_id,
    account_id,
    transaction_date,
    amount,
    -- ROWS: Strict physical row count (Current row + 2 preceding rows = 3-row moving total)
    SUM(amount) OVER(
        PARTITION BY account_id
        ORDER BY transaction_date, transaction_id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_tx_moving_sum,
    -- Full partition window:
    SUM(amount) OVER(
        PARTITION BY account_id
        ORDER BY transaction_date, transaction_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS account_lifetime_total
FROM banking.transactions;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Window Functions vs GROUP BY:
--   - GROUP BY collapses multiple rows into a single summary row per group.
--   - Window functions perform calculations across a set of rows while retaining individual row-level detail in the output.
-- Clause Placement & Execution Rule:
--   - Window functions are logically evaluated in Step 5 (SELECT) and Step 7 (ORDER BY).
--   - They CANNOT be placed in WHERE or HAVING clauses because those clauses execute BEFORE window functions are computed.
--   - Window functions CANNOT be nested inside each other (e.g. SUM(AVG(salary) OVER()) is illegal).
-- Default Frame Warning:
--   - When ORDER BY is present in OVER() but no frame is specified, SQL Server defaults to:
--     RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--   - This causes duplicate tied values to be grouped together and forces an on-disk/tempdb spool. Always explicitly specify ROWS BETWEEN ... for predictable performance.
