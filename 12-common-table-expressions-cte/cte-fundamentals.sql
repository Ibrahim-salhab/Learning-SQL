-- ============================================================
-- Topic: Common Table Expressions (CTE) Fundamentals
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Creating modular, readable query structures using standalone, multiple, and chained/nested CTEs
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Standalone CTE
-- ------------------------------------------------------------

-- Note the preceding semicolon (;) which guarantees proper statement termination
;WITH high_value_orders AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        total_amount
    FROM sales.orders
    WHERE total_amount >= 1000.00
)
SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    hvo.order_id,
    hvo.total_amount
FROM sales.customers AS c
INNER JOIN high_value_orders AS hvo
    ON c.customer_id = hvo.customer_id
ORDER BY hvo.total_amount DESC;


-- ------------------------------------------------------------
-- Example 2: Multiple Independent CTEs (Comma-separated)
-- ------------------------------------------------------------

;WITH customer_totals AS (
    SELECT
        customer_id,
        SUM(total_amount) AS lifetime_spend,
        COUNT(order_id) AS total_orders
    FROM sales.orders
    GROUP BY customer_id
),
high_risk_flags AS (
    SELECT
        customer_id,
        flag_reason
    FROM compliance.risk_flags
    WHERE is_resolved = 0
)
SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    ISNULL(ct.lifetime_spend, 0.00) AS lifetime_spend,
    ISNULL(ct.total_orders, 0) AS total_orders,
    hrf.flag_reason
FROM sales.customers AS c
LEFT JOIN customer_totals AS ct
    ON c.customer_id = ct.customer_id
INNER JOIN high_risk_flags AS hrf
    ON c.customer_id = hrf.customer_id;


-- ------------------------------------------------------------
-- Example 3: Nested / Chained CTEs (Downstream CTE referencing Upstream CTE)
-- ------------------------------------------------------------

;WITH raw_monthly_metrics AS (
    -- Step 1: Base aggregation
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(total_amount) AS monthly_revenue
    FROM sales.orders
    GROUP BY YEAR(order_date), MONTH(order_date)
),
ranked_months AS (
    -- Step 2: Reference raw_monthly_metrics to rank performance per year
    SELECT
        order_year,
        order_month,
        monthly_revenue,
        DENSE_RANK() OVER(
            PARTITION BY order_year
            ORDER BY monthly_revenue DESC
        ) AS rank_in_year
    FROM raw_monthly_metrics
)
-- Step 3: Final presentation consuming the ranked dataset
SELECT
    order_year,
    order_month,
    monthly_revenue,
    rank_in_year
FROM ranked_months
WHERE rank_in_year = 1 -- Only the best performing month per year
ORDER BY order_year DESC;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- What is a CTE?
--   - A Common Table Expression is a temporary, named result set defined within the execution scope of a single SELECT, INSERT, UPDATE, DELETE, or MERGE statement.
-- Semicolon Best Practice:
--   - T-SQL syntax requires that the statement immediately preceding a WITH keyword MUST end with a semicolon.
--   - Defensive SQL habit: Always prefix your CTE with `;WITH` to avoid syntax errors from un-terminated prior statements.
-- Scope & Execution:
--   - A CTE exists ONLY during the execution of the query that immediately follows it. It is not saved to disk and cannot be queried in a subsequent separate batch.
--   - SQL Server's query optimizer typically treats CTEs as inline views; it expands the definition directly into the main query execution plan (no physical temp table is created unless spooled).
-- Multiple CTE Syntax:
--   - The `WITH` keyword is written ONCE. Multiple CTE definitions are separated by commas.
