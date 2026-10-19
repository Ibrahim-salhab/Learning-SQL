-- ============================================================
-- Project: Enterprise Data Warehouse (DWH) - Medallion Architecture
-- Layer: SILVER (Cleaned, Conformed & Enriched)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Creating structured relational tables with strict data types, validated constraints, and standardized values
-- ============================================================

CREATE SCHEMA silver;
GO

-- ------------------------------------------------------------
-- 1. Cleaned Customers Entity
-- ------------------------------------------------------------
DROP TABLE IF EXISTS silver.customers;

CREATE TABLE silver.customers (
    customer_id       INT           NOT NULL PRIMARY KEY,
    first_name        NVARCHAR(50)  NOT NULL,
    last_name         NVARCHAR(50)  NOT NULL,
    full_name         NVARCHAR(100) NOT NULL,
    email             VARCHAR(100)  NOT NULL,
    country_code      CHAR(2)       NOT NULL,
    created_date      DATE          NOT NULL,
    silver_loaded_at  DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);


-- ------------------------------------------------------------
-- 2. Cleaned Products Entity
-- ------------------------------------------------------------
DROP TABLE IF EXISTS silver.products;

CREATE TABLE silver.products (
    product_id        INT            NOT NULL PRIMARY KEY,
    sku_code          VARCHAR(30)    NOT NULL,
    product_name      NVARCHAR(100)  NOT NULL,
    category_name     NVARCHAR(50)   NOT NULL,
    unit_price        DECIMAL(10, 2) NOT NULL,
    silver_loaded_at  DATETIME2      NOT NULL DEFAULT SYSDATETIME()
);


-- ------------------------------------------------------------
-- 3. Cleaned Orders Entity
-- ------------------------------------------------------------
DROP TABLE IF EXISTS silver.orders;

CREATE TABLE silver.orders (
    order_id          INT            NOT NULL PRIMARY KEY,
    customer_id       INT            NOT NULL,
    product_id        INT            NOT NULL,
    order_date        DATE           NOT NULL,
    quantity          INT            NOT NULL,
    total_amount      DECIMAL(12, 2) NOT NULL,
    silver_loaded_at  DATETIME2      NOT NULL DEFAULT SYSDATETIME()
);


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------
-- Silver Layer Philosophy:
--   - Deduplication: Duplicate natural keys resolved.
--   - Data Type Casting: Proper dates, decimals, and integer keys enforced.
--   - Data Sanitization: String trimming, handling empty strings/blanks via NULLIF, and email normalization.
