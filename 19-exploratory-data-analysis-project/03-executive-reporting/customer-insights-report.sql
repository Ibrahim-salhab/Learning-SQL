-- ============================================================
-- Project: Exploratory Data Analysis (EDA) & Business Intelligence
-- Report: Executive Customer Insights & Cohort Report
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Consolidated analytical view delivering 360-degree customer profile metrics for leadership
-- ============================================================

CREATE OR ALTER VIEW gold.vw_report_customer_insights
AS
WITH customer_aggregates AS (
    SELECT
        c.customer_key,
        c.customer_id,
        c.customer_name,
        c.email,
        c.country_code,
        c.customer_tier,
        c.member_since,
        COUNT(DISTINCT f.order_id) AS lifetime_orders,
        SUM(f.quantity_sold) AS total_units_purchased,
        SUM(f.total_revenue) AS lifetime_revenue,
        AVG(f.total_revenue) AS avg_order_value,
        MIN(d.full_date) AS first_order_date,
        MAX(d.full_date) AS most_recent_order_date
    FROM gold.dim_customers AS c
    LEFT JOIN gold.fact_sales AS f
        ON c.customer_key = f.customer_key
    LEFT JOIN gold.dim_date AS d
        ON f.order_date_key = d.date_key
    GROUP BY
        c.customer_key,
        c.customer_id,
        c.customer_name,
        c.email,
        c.country_code,
        c.customer_tier,
        c.member_since
)
SELECT
    customer_id,
    customer_name,
    country_code,
    customer_tier,
    member_since,
    lifetime_orders,
    total_units_purchased,
    ISNULL(lifetime_revenue, 0.00) AS lifetime_revenue,
    ISNULL(avg_order_value, 0.00) AS avg_order_value,
    first_order_date,
    most_recent_order_date,
    -- Customer tenure in months:
    DATEDIFF(MONTH, member_since, CAST(GETDATE() AS DATE)) AS tenure_months,
    -- Revenue percentile ranking across all customers:
    ROUND(
        PERCENT_RANK() OVER(ORDER BY ISNULL(lifetime_revenue, 0.00) ASC) * 100.0,
        1
    ) AS customer_revenue_percentile
FROM customer_aggregates;
GO

-- ------------------------------------------------------------
-- Sample Query Executing Customer Report
-- ------------------------------------------------------------
SELECT TOP (10)
    customer_name,
    customer_tier,
    lifetime_revenue,
    avg_order_value,
    customer_revenue_percentile
FROM gold.vw_report_customer_insights
ORDER BY lifetime_revenue DESC;
