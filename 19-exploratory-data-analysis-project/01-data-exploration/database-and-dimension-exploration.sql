-- ============================================================
-- Project: Exploratory Data Analysis (EDA) & Business Intelligence
-- Stage: Data Exploration & Validation
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Initial profiling: exploring dimensions, checking distinct cardinalities, verifying date ranges, and assessing data completeness
-- ============================================================


-- ------------------------------------------------------------
-- 1. Database & Table Health Check (Row Counts & Completeness)
-- ------------------------------------------------------------

SELECT
    'gold.fact_sales' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders,
    MIN(order_date_key) AS earliest_date_key,
    MAX(order_date_key) AS latest_date_key
FROM gold.fact_sales

UNION ALL

SELECT
    'gold.dim_customers',
    COUNT(*),
    COUNT(DISTINCT customer_id),
    NULL,
    NULL
FROM gold.dim_customers

UNION ALL

SELECT
    'gold.dim_products',
    COUNT(*),
    COUNT(DISTINCT product_id),
    NULL,
    NULL
FROM gold.dim_products;


-- ------------------------------------------------------------
-- 2. Dimension Exploration: Categorical Distributions
-- ------------------------------------------------------------

-- Explore Customer Country Representation
SELECT
    country_code,
    COUNT(customer_key) AS total_customers,
    ROUND(COUNT(customer_key) * 100.0 / SUM(COUNT(customer_key)) OVER(), 2) AS pct_of_total_customers
FROM gold.dim_customers
GROUP BY country_code
ORDER BY total_customers DESC;

-- Explore Product Category Breadth & Price Range
SELECT
    category_name,
    COUNT(product_key) AS unique_products_count,
    MIN(unit_price) AS min_price,
    AVG(unit_price) AS avg_price,
    MAX(unit_price) AS max_price
FROM gold.dim_products
GROUP BY category_name;


-- ------------------------------------------------------------
-- 3. Date Exploration: Reporting Horizon & Granularity
-- ------------------------------------------------------------

SELECT
    d.calendar_year,
    d.calendar_quarter,
    COUNT(DISTINCT f.order_id) AS total_orders_placed,
    SUM(f.total_revenue) AS total_revenue_generated
FROM gold.fact_sales AS f
INNER JOIN gold.dim_date AS d
    ON f.order_date_key = d.date_key
GROUP BY d.calendar_year, d.calendar_quarter
ORDER BY d.calendar_year, d.calendar_quarter;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------
-- Dimensions vs Measures:
--   - Dimensions: Qualitative context used for grouping and filtering (e.g. Country, Category, Year).
--   - Measures: Quantitative numerical values that can be aggregated mathematically (e.g. Total Revenue, Quantity Sold).
-- First Step in EDA: Always inspect minimum and maximum date ranges and verify that dimension foreign keys have zero orphaned records in fact tables.
