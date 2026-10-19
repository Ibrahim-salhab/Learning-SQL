-- ============================================================
-- Project: Exploratory Data Analysis (EDA) & Business Intelligence
-- Stage: Segmentation & Part-To-Whole Analysis
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Calculating percentage contributions to totals and customer behavioral segmentation
-- ============================================================


-- ------------------------------------------------------------
-- 1. Part-to-Whole Analysis: Category Contribution to Total Revenue
-- ------------------------------------------------------------

WITH category_totals AS (
    SELECT
        p.category_name,
        SUM(f.total_revenue) AS category_revenue,
        SUM(f.quantity_sold) AS category_volume
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    GROUP BY p.category_name
)
SELECT
    category_name,
    category_revenue,
    category_volume,
    -- Window SUM() OVER() calculates the grand total denominator without an extra query:
    SUM(category_revenue) OVER() AS company_grand_total_revenue,
    ROUND(
        category_revenue * 100.0 / SUM(category_revenue) OVER(),
        2
    ) AS revenue_contribution_pct
FROM category_totals
ORDER BY category_revenue DESC;


-- ------------------------------------------------------------
-- 2. Customer RFM-Style Behavioral Segmentation
-- ------------------------------------------------------------

WITH customer_rfm_raw AS (
    SELECT
        c.customer_key,
        c.customer_name,
        c.email,
        -- Monetary: Total spend
        SUM(f.total_revenue) AS monetary_value,
        -- Frequency: Distinct order count
        COUNT(DISTINCT f.order_id) AS frequency_count,
        -- Recency: Days since latest purchase (relative to end of 2024)
        DATEDIFF(DAY, MAX(d.full_date), '2024-12-31') AS recency_days
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    INNER JOIN gold.dim_date AS d
        ON f.order_date_key = d.date_key
    GROUP BY c.customer_key, c.customer_name, c.email
)
SELECT
    customer_name,
    email,
    monetary_value,
    frequency_count,
    recency_days,
    CASE
        WHEN monetary_value >= 2000 AND recency_days <= 60 THEN 'VIP / High Value Active'
        WHEN monetary_value >= 1000 AND recency_days > 120 THEN 'At-Risk High Spender'
        WHEN frequency_count = 1   AND recency_days <= 90  THEN 'New / Single Order'
        ELSE 'Regular Consistent'
    END AS customer_behavioral_segment
FROM customer_rfm_raw
ORDER BY monetary_value DESC;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------
-- Part-to-Whole Pattern:
--   - Expression: `SUM(metric) * 100.0 / SUM(SUM(metric)) OVER()` computes exact percentage contribution within a single aggregated pass.
-- Customer Segmentation:
--   - Segmenting customers by Recency, Frequency, and Monetary (RFM) value enables targeted retention campaigns and marketing allocation.
