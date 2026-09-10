-- ============================================================
-- Topic: CTAS (Create Table As Select) & SELECT INTO
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Creating new physical tables directly from query projections for snapshots, performance optimization, and staging
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Basic SELECT INTO (T-SQL CTAS Equivalent)
-- ------------------------------------------------------------

-- Creates a physical table and populates it in a single minimally-logged operation
DROP TABLE IF EXISTS reporting.annual_sales_summary_2024;

SELECT
    customer_id,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_spent,
    AVG(total_amount) AS avg_order_value
INTO reporting.annual_sales_summary_2024
FROM sales.orders
WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01'
GROUP BY customer_id;


-- ------------------------------------------------------------
-- Example 2: Table Snapshot for Pre-Deployment Backup
-- ------------------------------------------------------------

DROP TABLE IF EXISTS backup.products_snapshot_20241020;

SELECT *
INTO backup.products_snapshot_20241020
FROM inventory.products;


-- ------------------------------------------------------------
-- Example 3: Creating Empty Table Structure via WHERE 1 = 0
-- ------------------------------------------------------------

-- Copies columns and data types into a new empty table without copying data rows
DROP TABLE IF EXISTS staging.new_leads_template;

SELECT
    lead_id,
    lead_name,
    email,
    created_at
INTO staging.new_leads_template
FROM crm.leads
WHERE 1 = 0;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- CTAS vs SELECT INTO:
--   - ANSI SQL, PostgreSQL, Oracle, and Azure Synapse use the syntax: `CREATE TABLE table_name AS SELECT ...` (CTAS).
--   - SQL Server (T-SQL on-prem) uses: `SELECT ... INTO table_name FROM ...`.
-- Execution Mechanics & Logging:
--   - `SELECT INTO` creates the target table automatically based on the projected column names and inferred data types.
--   - In databases with Simple or Bulk-Logged recovery models, `SELECT INTO` is minimally logged, making it significantly faster than `CREATE TABLE` followed by a fully-logged standard `INSERT INTO`.
-- What is NOT Copied by SELECT INTO:
--   - Primary keys, foreign keys, indexes, check constraints, default constraints, and triggers are NOT carried over to the new table!
--   - Identity property IS copied if an uncalculated identity column is in the SELECT list; use `IDENTITY(int, 1, 1)` or expressions to control this behavior.
