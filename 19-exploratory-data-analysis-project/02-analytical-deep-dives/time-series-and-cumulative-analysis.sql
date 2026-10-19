-- ============================================================
-- Project: Exploratory Data Analysis (EDA) & Business Intelligence
-- Stage: Time-Series & Cumulative Analysis
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Tracking revenue growth trends, calculating Month-Over-Month changes, and computing running business milestones
-- ============================================================


-- ------------------------------------------------------------
-- 1. Month-Over-Month (MoM) Trend & Variance Analysis
-- ------------------------------------------------------------

WITH monthly_sales AS (
    SELECT
        d.calendar_year,
        d.calendar_month,
        d.month_name,
        SUM(f.total_revenue) AS monthly_revenue,
        COUNT(DISTINCT f.order_id) AS monthly_order_count
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_date AS d
        ON f.order_date_key = d.date_key
    GROUP BY d.calendar_year, d.calendar_month, d.month_name
)
SELECT
    calendar_year,
    calendar_month,
    month_name,
    monthly_revenue,
    monthly_order_count,
    -- Prior Month Revenue using LAG:
    LAG(monthly_revenue, 1) OVER(
        ORDER BY calendar_year, calendar_month
    ) AS prior_month_revenue,
    -- Absolute Dollar Variance:
    monthly_revenue - LAG(monthly_revenue, 1) OVER(
        ORDER BY calendar_year, calendar_month
    ) AS mom_dollar_variance,
    -- Percentage Growth:
    ROUND(
        ((monthly_revenue - LAG(monthly_revenue, 1) OVER(ORDER BY calendar_year, calendar_month)) * 100.0)
        / NULLIF(LAG(monthly_revenue, 1) OVER(ORDER BY calendar_year, calendar_month), 0),
        2
    ) AS mom_growth_percentage
FROM monthly_sales
ORDER BY calendar_year, calendar_month;


-- ------------------------------------------------------------
-- 2. Cumulative Year-to-Date (YTD) Revenue Tracking
-- ------------------------------------------------------------

SELECT
    d.calendar_year,
    d.calendar_month,
    d.month_name,
    SUM(f.total_revenue) AS monthly_revenue,
    -- YTD Running Total (Partitions reset each year):
    SUM(SUM(f.total_revenue)) OVER(
        PARTITION BY d.calendar_year
        ORDER BY d.calendar_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ytd_cumulative_revenue
FROM gold.fact_sales AS f
INNER JOIN gold.dim_date AS d
    ON f.order_date_key = d.date_key
GROUP BY d.calendar_year, d.calendar_month, d.month_name
ORDER BY d.calendar_year, d.calendar_month;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------
-- Partition Resetting in YTD: By adding `PARTITION BY d.calendar_year`, the cumulative running total automatically resets to zero on January 1st of every new calendar year.
-- Zero Division Defense: Always use `NULLIF(prior_value, 0)` when calculating percentage changes to prevent runtime divide-by-zero crashes.
