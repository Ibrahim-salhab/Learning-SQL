-- ============================================================
-- Project: Enterprise Data Warehouse (DWH) - Medallion Architecture
-- Layer: BRONZE (Raw Staging Ingestion)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Creating raw staging tables matching external ERP/CRM source system structures
-- ============================================================

CREATE SCHEMA bronze;
GO

-- ------------------------------------------------------------
-- 1. Raw Customers Ingestion Table (ERP Source)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bronze.erp_customers_raw;

CREATE TABLE bronze.erp_customers_raw (
    raw_customer_id   NVARCHAR(50)  NULL,
    raw_first_name    NVARCHAR(100) NULL,
    raw_last_name     NVARCHAR(100) NULL,
    raw_email         NVARCHAR(150) NULL,
    raw_country       NVARCHAR(50)  NULL,
    raw_created_date  NVARCHAR(50)  NULL, -- Ingested as string to prevent ingestion failure
    ingested_at       DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);


-- ------------------------------------------------------------
-- 2. Raw Products Ingestion Table (Catalog Source)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bronze.catalog_products_raw;

CREATE TABLE bronze.catalog_products_raw (
    raw_product_id    NVARCHAR(50)  NULL,
    raw_sku           NVARCHAR(50)  NULL,
    raw_product_name  NVARCHAR(150) NULL,
    raw_category      NVARCHAR(100) NULL,
    raw_unit_price    NVARCHAR(50)  NULL,
    ingested_at       DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);


-- ------------------------------------------------------------
-- 3. Raw Orders Ingestion Table (Sales Transactions)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bronze.sales_orders_raw;

CREATE TABLE bronze.sales_orders_raw (
    raw_order_id      NVARCHAR(50)  NULL,
    raw_customer_id   NVARCHAR(50)  NULL,
    raw_product_id    NVARCHAR(50)  NULL,
    raw_order_date    NVARCHAR(50)  NULL,
    raw_quantity      NVARCHAR(50)  NULL,
    raw_total_amount  NVARCHAR(50)  NULL,
    ingested_at       DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------
-- Bronze Layer Philosophy:
--   - 1:1 fidelity with source systems.
--   - Permissive datatypes (NVARCHAR) ensure automated file/API pipelines never fail on raw type conversions.
--   - Ingestion audit metadata (`ingested_at`) tracks data lineage.
