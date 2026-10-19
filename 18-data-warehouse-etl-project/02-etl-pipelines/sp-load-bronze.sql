-- ============================================================
-- Project: Enterprise Data Warehouse (DWH) - Medallion Architecture
-- Pipeline: Stored Procedure - Load Bronze Layer
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Ingesting raw external feed files into Bronze staging tables with transaction handling and execution duration logging
-- ============================================================

CREATE OR ALTER PROCEDURE bronze.usp_load_bronze_layer
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @batch_start_time DATETIME2 = SYSDATETIME();

    PRINT '>> Starting Bronze Layer Batch Ingestion...';

    BEGIN TRY
        -- Step 1: Truncate Bronze Staging Tables
        TRUNCATE TABLE bronze.erp_customers_raw;
        TRUNCATE TABLE bronze.catalog_products_raw;
        TRUNCATE TABLE bronze.sales_orders_raw;

        -- Step 2: Simulated Ingestion from Staging Files / BULK INSERT
        INSERT INTO bronze.erp_customers_raw (raw_customer_id, raw_first_name, raw_last_name, raw_email, raw_country, raw_created_date)
        VALUES
            ('101', 'Maya', 'Haddad', 'maya.haddad@example.com', 'JO', '2023-01-15'),
            ('102', 'Tariq', 'Zaid', 'tariq.zaid@example.com', 'SA', '2023-02-20'),
            ('103', 'Rania', 'Khoury', 'rania.k@example.com', 'AE', '2023-03-10'),
            ('104', 'Omar', 'Nasser', 'omar.n@example.com', 'JO', '2023-04-05');

        INSERT INTO bronze.catalog_products_raw (raw_product_id, raw_sku, raw_product_name, raw_category, raw_unit_price)
        VALUES
            ('201', 'SKU-LAP-01', 'High-Performance Laptop', 'Electronics', '1250.00'),
            ('202', 'SKU-MOU-02', 'Ergonomic Wireless Mouse', 'Accessories', '45.00'),
            ('203', 'SKU-MON-03', '4K UHD 27-inch Monitor', 'Electronics', '380.00'),
            ('204', 'SKU-KEY-04', 'Mechanical Gaming Keyboard', 'Accessories', '85.00');

        INSERT INTO bronze.sales_orders_raw (raw_order_id, raw_customer_id, raw_product_id, raw_order_date, raw_quantity, raw_total_amount)
        VALUES
            ('1001', '101', '201', '2024-01-10', '1', '1250.00'),
            ('1002', '102', '202', '2024-01-12', '2', '90.00'),
            ('1003', '101', '203', '2024-02-05', '1', '380.00'),
            ('1004', '103', '204', '2024-02-14', '3', '255.00'),
            ('1005', '104', '201', '2024-03-01', '2', '2500.00');

        DECLARE @elapsed_sec INT = DATEDIFF(SECOND, @batch_start_time, SYSDATETIME());
        PRINT CONCAT('>> Bronze Layer loaded successfully in ', @elapsed_sec, ' seconds.');
    END TRY
    BEGIN CATCH
        PRINT '>> ERROR: Bronze Layer load failed.';
        THROW;
    END CATCH;

END;
GO
