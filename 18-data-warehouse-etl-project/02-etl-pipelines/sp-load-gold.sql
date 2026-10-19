-- ============================================================
-- Project: Enterprise Data Warehouse (DWH) - Medallion Architecture
-- Pipeline: Stored Procedure - Load Gold Layer (Star Schema Data Mart)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Populating conformed dimensions and facts with surrogate keys, business tiers, and calendar keys
-- ============================================================

CREATE OR ALTER PROCEDURE gold.usp_load_gold_layer
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    PRINT '>> Starting Gold Layer Dimensional Model Population...';

    BEGIN TRY
        BEGIN TRANSACTION;

            -- 1. Populate Calendar Dimension (Dynamic Seed)
            -- If dim_date is empty, populate 2024 calendar
            IF NOT EXISTS (SELECT 1 FROM gold.dim_date)
            BEGIN
                ;WITH date_series AS (
                    SELECT CAST('2024-01-01' AS DATE) AS d_date
                    UNION ALL
                    SELECT DATEADD(DAY, 1, d_date)
                    FROM date_series
                    WHERE d_date < '2024-12-31'
                )
                INSERT INTO gold.dim_date (
                    date_key,
                    full_date,
                    calendar_year,
                    calendar_quarter,
                    calendar_month,
                    month_name,
                    day_of_month,
                    day_name,
                    is_weekend
                )
                SELECT
                    YEAR(d_date) * 10000 + MONTH(d_date) * 100 + DAY(d_date),
                    d_date,
                    YEAR(d_date),
                    DATEPART(QUARTER, d_date),
                    MONTH(d_date),
                    DATENAME(MONTH, d_date),
                    DAY(d_date),
                    DATENAME(WEEKDAY, d_date),
                    CASE WHEN DATENAME(WEEKDAY, d_date) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END
                FROM date_series
                OPTION (MAXRECURSION 400);
            END;


            -- 2. Populate Dim_Customers
            TRUNCATE TABLE gold.dim_customers;

            INSERT INTO gold.dim_customers (
                customer_id,
                customer_name,
                email,
                country_code,
                customer_tier,
                member_since
            )
            SELECT
                c.customer_id,
                c.full_name,
                c.email,
                c.country_code,
                CASE
                    WHEN ISNULL(spend.lifetime_spend, 0) >= 2000.00 THEN 'Platinum'
                    WHEN ISNULL(spend.lifetime_spend, 0) >= 500.00  THEN 'Gold'
                    ELSE 'Standard'
                END AS customer_tier,
                c.created_date
            FROM silver.customers AS c
            LEFT JOIN (
                SELECT customer_id, SUM(total_amount) AS lifetime_spend
                FROM silver.orders
                GROUP BY customer_id
            ) AS spend
                ON c.customer_id = spend.customer_id;


            -- 3. Populate Dim_Products
            TRUNCATE TABLE gold.dim_products;

            INSERT INTO gold.dim_products (
                product_id,
                sku_code,
                product_name,
                category_name,
                price_bracket,
                unit_price
            )
            SELECT
                product_id,
                sku_code,
                product_name,
                category_name,
                CASE
                    WHEN unit_price >= 1000.00 THEN 'Premium (> $1000)'
                    WHEN unit_price >= 100.00  THEN 'Mid-Range ($100-$1000)'
                    ELSE 'Budget (< $100)'
                END AS price_bracket,
                unit_price
            FROM silver.products;


            -- 4. Populate Fact_Sales (Resolving Natural Keys to Surrogate Keys)
            -- Note: Truncate fact table requires dropping/rebuilding foreign keys or standard delete if FK active
            DELETE FROM gold.fact_sales;

            INSERT INTO gold.fact_sales (
                order_id,
                customer_key,
                product_key,
                order_date_key,
                quantity_sold,
                unit_price,
                total_revenue
            )
            SELECT
                o.order_id,
                dc.customer_key,
                dp.product_key,
                YEAR(o.order_date) * 10000 + MONTH(o.order_date) * 100 + DAY(o.order_date) AS order_date_key,
                o.quantity,
                dp.unit_price,
                o.total_amount
            FROM silver.orders AS o
            INNER JOIN gold.dim_customers AS dc
                ON o.customer_id = dc.customer_id
            INNER JOIN gold.dim_products AS dp
                ON o.product_id = dp.product_id;

        COMMIT TRANSACTION;

        PRINT '>> Gold Layer dimensional data mart successfully refreshed.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        PRINT '>> ERROR: Gold Layer population failed.';
        THROW;
    END CATCH;

END;
GO
