-- ============================================================
-- Topic: DELETE Statement (DML)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Removing specific rows from a table while preserving table structure
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Deleting specific rows using WHERE
-- ------------------------------------------------------------

DELETE FROM sales.shopping_carts
WHERE cart_id = 9021;


-- ------------------------------------------------------------
-- Example 2: Deleting expired or stale records
-- ------------------------------------------------------------

DELETE FROM security.user_sessions
WHERE last_activity < DATEADD(DAY, -30, GETDATE())
  AND is_remembered = 0;


-- ------------------------------------------------------------
-- Comparison: DELETE vs TRUNCATE TABLE
-- ------------------------------------------------------------

-- DELETE (DML):
-- Removes filtered or all rows, logs each row deletion, fires triggers, does not reset IDENTITY.
-- DELETE FROM logging.application_logs WHERE log_level = 'Debug';

-- TRUNCATE TABLE (DDL):
-- Empties entire table instantly by deallocating pages, resets IDENTITY to seed, cannot filter with WHERE.
-- TRUNCATE TABLE logging.application_logs;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- CRITICAL SAFETY RULE: DELETE without a WHERE clause removes all records from the table.
-- Referential Integrity: If a row is referenced as a foreign key by another active table, DELETE will fail unless ON DELETE CASCADE is configured.
-- TRUNCATE TABLE is not permitted if the table is referenced by ANY foreign key constraint from another table, even if the other table is empty.
-- Always verify row count with SELECT COUNT(*) using the identical WHERE clause before running DELETE in production.
