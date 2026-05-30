-- ============================================================
-- Topic: DROP TABLE Operations (DDL)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Permanently removing table definitions, constraints, indexes, and row data from a database
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Basic DROP TABLE IF EXISTS (Safe drop)
-- ------------------------------------------------------------

-- Supported in SQL Server 2016+ (avoids errors if table is already absent)
DROP TABLE IF EXISTS sales.archived_orders;


-- ------------------------------------------------------------
-- Example 2: Dropping related tables in correct dependency order
-- ------------------------------------------------------------

-- Cannot drop parent table (customers) while referenced by child table (orders)
-- Step 1: Drop child table with foreign key reference
DROP TABLE IF EXISTS sales.orders;

-- Step 2: Drop parent table safely
DROP TABLE IF EXISTS sales.customers;


-- ------------------------------------------------------------
-- Example 3: Dropping multiple tables in a single statement
-- ------------------------------------------------------------

DROP TABLE IF EXISTS
    sales.temporary_discounts,
    sales.staging_leads;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- DROP TABLE removes both the table schema structure and all stored data permanently.
-- Referential Integrity Gotcha: You cannot drop a table if another table references it with an active FOREIGN KEY constraint. You must drop the foreign key or child table first.
-- Always prefer DROP TABLE IF EXISTS in scripts and migration files to guarantee idempotent execution.
-- Caution: DROP TABLE cannot be undone unless the action occurs inside an uncommitted transaction or restored from a database backup.
