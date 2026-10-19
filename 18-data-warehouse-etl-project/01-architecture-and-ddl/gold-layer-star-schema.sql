-- ============================================================
-- Project: Enterprise Data Warehouse (DWH) - Medallion Architecture
-- Layer: GOLD (Kimball Dimensional Star Schema)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Creating analytical dimension and fact tables for executive reporting and BI semantic models
-- ============================================================

CREATE SCHEMA gold;
GO

-- ------------------------------------------------------------
-- 1. Dimension: Customers (Conformed Dimension)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS gold.dim_customers;

CREATE TABLE gold.dim_customers (
    customer_key      INT IDENTITY(1, 1) NOT NULL PRIMARY KEY, -- Surrogate Key
    customer_id       INT                NOT NULL,             -- Business / Natural Key
    customer_name     NVARCHAR(100)      NOT NULL,
    email             VARCHAR(100)       NOT NULL,
    country_code      CHAR(2)            NOT NULL,
    customer_tier     VARCHAR(20)        NOT NULL,
    member_since      DATE               NOT NULL
);


-- ------------------------------------------------------------
-- 2. Dimension: Products
-- ------------------------------------------------------------
DROP TABLE IF EXISTS gold.dim_products;

CREATE TABLE gold.dim_products (
    product_key       INT IDENTITY(1, 1) NOT NULL PRIMARY KEY, -- Surrogate Key
    product_id        INT                NOT NULL,             -- Business / Natural Key
    sku_code          VARCHAR(30)        NOT NULL,
    product_name      NVARCHAR(100)      NOT NULL,
    category_name     NVARCHAR(50)       NOT NULL,
    price_bracket     VARCHAR(20)        NOT NULL,
    unit_price        DECIMAL(10, 2)     NOT NULL
);


-- ------------------------------------------------------------
-- 3. Dimension: Date (Calendar Dimension)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS gold.dim_date;

CREATE TABLE gold.dim_date (
    date_key          INT          NOT NULL PRIMARY KEY, -- YYYYMMDD
    full_date         DATE         NOT NULL,
    calendar_year     INT          NOT NULL,
    calendar_quarter  INT          NOT NULL,
    calendar_month    INT          NOT NULL,
    month_name        VARCHAR(20)  NOT NULL,
    day_of_month      INT          NOT NULL,
    day_name          VARCHAR(20)  NOT NULL,
    is_weekend        BIT          NOT NULL
);


-- ------------------------------------------------------------
-- 4. Fact Table: Sales Transactions (Central Fact)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS gold.fact_sales;

CREATE TABLE gold.fact_sales (
    sales_key         BIGINT IDENTITY(1, 1) NOT NULL,
    order_id          INT                   NOT NULL,
    customer_key      INT                   NOT NULL REFERENCES gold.dim_customers(customer_key),
    product_key       INT                   NOT NULL REFERENCES gold.dim_products(product_key),
    order_date_key    INT                   NOT NULL REFERENCES gold.dim_date(date_key),
    quantity_sold     INT                   NOT NULL,
    unit_price        DECIMAL(10, 2)        NOT NULL,
    total_revenue     DECIMAL(12, 2)        NOT NULL
);

-- Analytical Optimization: Clustered Columnstore Index for lightning-fast OLAP aggregations
CREATE CLUSTERED COLUMNSTORE INDEX cci_gold_fact_sales
ON gold.fact_sales;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------
-- Star Schema Principles:
--   - Dimensions contain descriptive text context (slicers, filters, group by).
--   - Fact tables store granular numeric business metrics (quantities, revenue).
--   - Surrogate Keys (INT IDENTITY) insulate the warehouse from source system key changes.
