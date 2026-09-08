-- ============================================================
-- Best Practice: View Design, Security & Anti-Patterns
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Best practices for designing performant, secure database views and avoiding view-nesting traps
-- ============================================================


-- ------------------------------------------------------------
-- Less Ideal: Nested Views (The "View-on-View-on-View" Trap)
-- ------------------------------------------------------------

-- Anti-Pattern: Calling View C, which queries View B, which queries View A
-- Obscures underlying execution logic and prevents the query optimizer from pruning unused tables and indexes.
-- SELECT * FROM reporting.vw_final_customer_summary;


-- ------------------------------------------------------------
-- Preferred: Single-Layer Specialized Views with Explicit Projections
-- ------------------------------------------------------------

CREATE OR ALTER VIEW hr.vw_secure_staff_roster
WITH SCHEMABINDING -- Locks base table schema; enables indexing and prevents column alteration
AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    e.department_id
FROM hr.employees AS e
WHERE e.is_active = 1;
GO


-- ------------------------------------------------------------
-- Security Standard: Separation of Permissions
-- ------------------------------------------------------------

-- 1. Grant SELECT on the View to Analysts / App Service Accounts:
-- GRANT SELECT ON hr.vw_secure_staff_roster TO role_reporting_analyst;

-- 2. Deny/Revoke SELECT on the underlying base physical table:
-- DENY SELECT ON hr.employees TO role_reporting_analyst;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- WITH SCHEMABINDING:
--   - Ties the view strictly to the underlying base table definitions.
--   - Prevents accidental alterations of underlying columns (e.g. dropping a column that breaks the view).
--   - Mandatory if you plan to create a Clustered Index on the view (Indexed/Materialized View).
-- Avoid ORDER BY in Views:
--   - In relational theory, a view represents an unordered mathematical relation.
--   - Using `TOP 100 PERCENT ... ORDER BY` inside a view is an anti-pattern; SQL Server's query optimizer does NOT guarantee that rows returned from the view will honor that internal order when queried!
