-- ============================================================
-- Topic: CREATE TABLE & Schema Definition (DDL)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Defining new relational tables, columns, data types, and integrity constraints
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Creating a parent table with primary key and defaults
-- ------------------------------------------------------------

CREATE TABLE sales.customers (
    customer_id     INT IDENTITY(1, 1)  NOT NULL,
    first_name      NVARCHAR(50)        NOT NULL,
    last_name       NVARCHAR(50)        NOT NULL,
    email           VARCHAR(100)        NOT NULL,
    phone           VARCHAR(20)         NULL,
    is_active       BIT                 NOT NULL DEFAULT 1,
    created_at      DATETIME2(0)        NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uq_customers_email UNIQUE (email)
);


-- ------------------------------------------------------------
-- Example 2: Creating a child table with foreign key relationship
-- ------------------------------------------------------------

CREATE TABLE sales.orders (
    order_id        INT IDENTITY(1001, 1) NOT NULL,
    customer_id     INT                   NOT NULL,
    order_date      DATE                  NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    total_amount    DECIMAL(10, 2)        NOT NULL DEFAULT 0.00,
    order_status    VARCHAR(20)           NOT NULL DEFAULT 'Pending',

    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id)
        REFERENCES sales.customers (customer_id),
    CONSTRAINT chk_orders_amount CHECK (total_amount >= 0.00)
);


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- DDL (Data Definition Language) commands modify database structure/schema, not table data records.
-- IDENTITY(seed, increment): Generates auto-incrementing numbers in SQL Server (equivalent to AUTO_INCREMENT in MySQL or GENERATED ALWAYS AS IDENTITY in ANSI/PostgreSQL).
-- NVARCHAR vs VARCHAR: NVARCHAR supports Unicode characters (requires 2 bytes per char); VARCHAR is standard single-byte ASCII.
-- Explicitly naming constraints (e.g., pk_customers, fk_orders_customers) makes debugging and future schema modifications much easier.
-- CHECK constraints validate that column values adhere to a specified boolean condition upon INSERT or UPDATE.
