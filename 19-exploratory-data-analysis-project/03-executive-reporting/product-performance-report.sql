-- ============================================================
-- Project: Exploratory Data Analysis (EDA) & Business Intelligence
-- Report: Executive Product Performance & Profitability Report
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Consolidated analytical view delivering merchandise velocity, category revenue contributions, and product rankings
-- ============================================================

CREATE OR ALTER VIEW gold.vw_report_product_performance
AS
WITH product_metrics AS (
    SELECT
        p.product_key,
        p.product_id,
        p.sku_code,
        p.product_name,
        p.category_name,
        p.price_bracket,
        p.unit_price,
        ISNULL(SUM(f.quantity_sold), 0) AS total_units_sold,
        ISNULL(SUM(f.total_revenue), 0.00) AS total_revenue_generated,
        COUNT(DISTINCT f.order_id) AS distinct_orders_containing_product
    FROM gold.dim_products AS p
    LEFT JOIN gold.fact_sales AS f
        ON p.product_key = f.product_key
    GROUP BY
        p.product_key,
        p.product_id,
        p.sku_code,
        p.product_name,
        p.category_name,
        p.price_bracket,
        p.unit_price
)
SELECT
    product_id,
    sku_code,
    product_name,
    category_name,
    price_bracket,
    unit_price,
    total_units_sold,
    total_revenue_generated,
    distinct_orders_containing_product,
    -- Category Revenue Rank:
    DENSE_RANK() OVER(
        PARTITION BY category_name
        ORDER BY total_revenue_generated DESC
    ) AS rank_within_category,
    -- Overall Global Revenue Rank:
    DENSE_RANK() OVER(
        ORDER BY total_revenue_generated DESC
    ) AS overall_catalog_rank,
    -- Revenue contribution percentage within its category:
    ROUND(
        total_revenue_generated * 100.0 /
        NULLIF(SUM(total_revenue_generated) OVER(PARTITION BY category_name), 0),
        2
    ) AS category_revenue_share_pct
FROM product_metrics;
GO

-- ------------------------------------------------------------
-- Sample Query Executing Product Report
-- ------------------------------------------------------------
SELECT
    product_name,
    category_name,
    total_units_sold,
    total_revenue_generated,
    category_revenue_share_pct,
    rank_within_category
FROM gold.vw_report_product_performance
ORDER BY category_name, rank_within_category;
