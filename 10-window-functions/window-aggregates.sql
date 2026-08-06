-- ============================================================
-- Topic: Window Aggregate Functions (Running Totals & Moving Averages)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Calculating cumulative sums, running totals, moving averages, and rolling minimums/maximums across partitions
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Running Totals and Cumulative Counts
-- ------------------------------------------------------------

SELECT
    sale_id,
    sales_rep_id,
    sale_date,
    revenue,
    -- Running count of sales transactions completed so far by this rep:
    COUNT(sale_id) OVER(
        PARTITION BY sales_rep_id
        ORDER BY sale_date, sale_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_sales_count,
    -- Running cumulative revenue earned so far by this rep:
    SUM(revenue) OVER(
        PARTITION BY sales_rep_id
        ORDER BY sale_date, sale_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_cumulative_revenue
FROM commercial.sales_records;


-- ------------------------------------------------------------
-- Example 2: Moving Average (3-Day and 7-Day Smoothing)
-- ------------------------------------------------------------

SELECT
    metric_date,
    active_users,
    -- 3-day moving average (Current day + 2 prior days):
    AVG(active_users * 1.0) OVER(
        ORDER BY metric_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_day_moving_avg,
    -- Centered 5-day moving average (2 days before, current day, 2 days after):
    AVG(active_users * 1.0) OVER(
        ORDER BY metric_date
        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
    ) AS centered_five_day_moving_avg
FROM analytics.daily_active_users;


-- ------------------------------------------------------------
-- Example 3: Rolling MIN and MAX (Boundary Tracking)
-- ------------------------------------------------------------

SELECT
    stock_ticker,
    trading_date,
    closing_price,
    -- Lowest price observed from start of period up to current day:
    MIN(closing_price) OVER(
        PARTITION BY stock_ticker
        ORDER BY trading_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_lowest_price,
    -- Highest price observed from start of period up to current day:
    MAX(closing_price) OVER(
        PARTITION BY stock_ticker
        ORDER BY trading_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_highest_price
FROM market.daily_equities;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Running Total Pattern:
--   SUM(amount) OVER (PARTITION BY partition_col ORDER BY sort_col ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
-- Moving Average Pattern:
--   AVG(val * 1.0) OVER (ORDER BY sort_col ROWS BETWEEN N PRECEDING AND CURRENT ROW)
--   *Note: Multiply by 1.0 or CAST to decimal to avoid integer division truncation in SQL Server.*
-- Frame Boundary Specifications:
--   - UNBOUNDED PRECEDING: The very first row of the partition.
--   - n PRECEDING: n physical rows before the current row.
--   - CURRENT ROW: The row currently being evaluated.
--   - n FOLLOWING: n physical rows after the current row.
--   - UNBOUNDED FOLLOWING: The very last row of the partition.
-- Aggregate window functions ignore NULL values inside the evaluated column, identical to standard GROUP BY aggregate functions.
