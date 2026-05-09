-- ============================================================
-- Best Practice: Avoid SELECT * in Production Queries
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Ensuring queries remain explicit, performant, and resilient to schema changes
-- ============================================================


-- ------------------------------------------------------------
-- Less Ideal: Wildcard projection
-- ------------------------------------------------------------

-- Returns every column, including unneeded text, blobs, or newly added schema columns
SELECT *
FROM hr.employees
WHERE department_id = 4;


-- ------------------------------------------------------------
-- Preferred: Explicit column projection
-- ------------------------------------------------------------

-- Retrieves only required attributes, supports covering indexes, and prevents memory waste
SELECT
    employee_id,
    first_name,
    last_name,
    email,
    job_title
FROM hr.employees
WHERE department_id = 4;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Network & Memory Overhead: Transferring unnecessary columns wastes database buffer cache and client network bandwidth.
-- Index Optimization: Explicit column selection allows query optimizers to satisfy queries purely from non-clustered index pages (Index-Only / Covering scans) without costly table/clustered lookups.
-- Schema Decoupling: Applications using ordinal positions break immediately when columns are added, removed, or reordered in the table schema.
-- Acceptable Exception: SELECT * is acceptable for rapid ad-hoc data exploration in development or inside EXISTS (SELECT * FROM ...).
