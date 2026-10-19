-- ============================================================
-- Project: Enterprise Data Warehouse (DWH) - Medallion Architecture
-- Pipeline: Stored Procedure - Load Silver Layer (Cleansing & Conform)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Transforming, validating, deduplicating, and casting Bronze raw data into conformed Silver tables
-- ============================================================

CREATE OR ALTER PROCEDURE silver.usp_load_silver_layer
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    PRINT '>> Starting Silver Layer Transformation & Cleansing...';

    BEGIN TRY
        BEGIN TRANSACTION;

            -- 1. Transform & Load Customers (Trimming, Lowercase Email, Date Casting)
            TRUNCATE TABLE silver.customers;

            INSERT INTO silver.customers (
                customer_id,
                first_name,
                last_name,
                full_name,
                email,
                country_code,
                created_date
            )
            SELECT
                CAST(raw_customer_id AS INT),
                TRIM(raw_first_name),
                TRIM(raw_last_name),
                CONCAT(TRIM(raw_first_name), ' ', TRIM(raw_last_name)),
                LOWER(TRIM(raw_email)),
                UPPER(TRIM(raw_country)),
                CAST(raw_created_date AS DATE)
            FROM bronze.erp_customers_raw
            WHERE raw_customer_id IS NOT NULL;


            -- 2. Transform & Load Products (Clean names, price casting)
            TRUNCATE TABLE silver.products;

            INSERT INTO silver.products (
                product_id,
                sku_code,
                product_name,
                category_name,
                unit_price
            )
            SELECT
                CAST(raw_product_id AS INT),
                UPPER(TRIM(raw_sku)),
                TRIM(raw_product_name),
                TRIM(raw_category),
                CAST(raw_unit_price AS DECIMAL(10, 2))
            FROM bronze.catalog_products_raw
            WHERE raw_product_id IS NOT NULL;


            -- 3. Transform & Load Orders
            TRUNCATE TABLE silver.orders;

            INSERT INTO silver.orders (
                order_id,
                customer_id,
                product_id,
                order_date,
                quantity,
                total_amount
            )
            SELECT
                CAST(raw_order_id AS INT),
                CAST(raw_customer_id AS INT),
                CAST(raw_product_id AS INT),
                CAST(raw_order_date AS DATE),
                CAST(raw_quantity AS INT),
                CAST(raw_total_amount AS DECIMAL(12, 2))
            FROM bronze.sales_orders_raw
            WHERE raw_order_id IS NOT NULL;

        COMMIT TRANSACTION;

        PRINT '>> Silver Layer cleansing completed successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        PRINT '>> ERROR: Silver Layer transformation failed.';
        THROW;
    END CATCH;

END;
GO
