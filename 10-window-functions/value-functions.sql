-- ============================================================
-- Topic: Window Value Functions (LEAD, LAG, FIRST_VALUE, LAST_VALUE)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Accessing prior or subsequent rows without self-joins, calculating period-over-period growth, and boundary value retrieval
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: LEAD and LAG with custom offset and default values
-- ------------------------------------------------------------

SELECT
    order_id,
    order_date,
    total_amount,
    -- Prior order total (offset 1, default 0.00 if first row):
    LAG(total_amount, 1, 0.00) OVER(ORDER BY order_date, order_id) AS prev_order_amount,
    -- Next order total (offset 1, default 0.00 if last row):
    LEAD(total_amount, 1, 0.00) OVER(ORDER BY order_date, order_id) AS next_order_amount
FROM sales.orders;


-- ------------------------------------------------------------
-- Example 2: Use Case - Month-Over-Month (MoM) Growth Percentage
-- ------------------------------------------------------------

WITH monthly_revenue AS (
    SELECT
        YEAR(order_date) AS rev_year,
        MONTH(order_date) AS rev_month,
        SUM(total_amount) AS current_month_rev
    FROM sales.orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    rev_year,
    rev_month,
    current_month_rev,
    LAG(current_month_rev, 1) OVER(ORDER BY rev_year, rev_month) AS prev_month_rev,
    -- MoM Growth Calculation: ((Current - Prior) / Prior) * 100
    ROUND(
        ((current_month_rev - LAG(current_month_rev, 1) OVER(ORDER BY rev_year, rev_month)) * 100.0)
        / NULLIF(LAG(current_month_rev, 1) OVER(ORDER BY rev_year, rev_month), 0),
        2
    ) AS mom_growth_pct
FROM monthly_revenue
ORDER BY rev_year, rev_month;


-- ------------------------------------------------------------
-- Example 3: Use Case - Customer Retention & Time Gap Analysis
-- ------------------------------------------------------------

SELECT
    customer_id,
    order_id,
    order_date,
    LAG(order_date, 1) OVER(
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS previous_order_date,
    -- Days between consecutive orders:
    DATEDIFF(
        DAY,
        LAG(order_date, 1) OVER(PARTITION BY customer_id ORDER BY order_date, order_id),
        order_date
    ) AS days_since_last_purchase
FROM sales.orders;


-- ------------------------------------------------------------
-- Example 4: FIRST_VALUE & LAST_VALUE (The Window Frame Trap)
-- ------------------------------------------------------------

SELECT
    department_id,
    employee_id,
    salary,
    -- Lowest salary in department:
    FIRST_VALUE(salary) OVER(
        PARTITION BY department_id
        ORDER BY salary ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS dept_lowest_salary,
    -- Highest salary in department (MUST expand frame to UNBOUNDED FOLLOWING):
    LAST_VALUE(salary) OVER(
        PARTITION BY department_id
        ORDER BY salary ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS dept_highest_salary
FROM hr.employees;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- LEAD(col, offset, default) / LAG(col, offset, default):
--   - offset defaults to 1 if omitted.
--   - default defaults to NULL if omitted. Always supply a default value (e.g. 0) when performing direct subtraction.
-- The LAST_VALUE() Gotcha:
--   - Without explicit framing, SQL Server defaults to `ROWS/RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`.
--   - Under the default frame, LAST_VALUE() returns the CURRENT ROW value because the frame ends at the current row!
--   - Always append `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` when using LAST_VALUE().
