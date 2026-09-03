-- ============================================================
-- Topic: Database Views Fundamentals & Architecture
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Creating, altering, and dropping views, understanding query expansion, and 3-level schema architecture
-- ============================================================


-- ------------------------------------------------------------
-- The 3-Levels ANSI/SPARC Database Architecture
-- ------------------------------------------------------------
-- 1. Internal Level (Physical Schema): Data files (.mdf, .ldf), page allocations, B-Tree indexes, partitioning.
-- 2. Conceptual Level (Logical Schema): Physical tables, columns, primary/foreign keys, constraints.
-- 3. External Level (View Schema): Virtual views tailored to specific applications, user roles, or reports.


-- ------------------------------------------------------------
-- Example 1: CREATE OR ALTER VIEW (Standard Definition)
-- ------------------------------------------------------------

-- CREATE OR ALTER VIEW is supported in SQL Server 2016 SP1+
CREATE OR ALTER VIEW sales.vw_active_customer_orders
AS
SELECT
    o.order_id,
    o.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    c.email,
    o.order_date,
    o.order_status,
    o.total_amount
FROM sales.orders AS o
INNER JOIN sales.customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status <> 'Cancelled';
GO


-- ------------------------------------------------------------
-- Example 2: Querying the View as a Virtual Table
-- ------------------------------------------------------------

-- The database engine expands the view definition into the outer query's execution plan
SELECT
    order_id,
    customer_name,
    total_amount
FROM sales.vw_active_customer_orders
WHERE total_amount >= 500.00
ORDER BY total_amount DESC;


-- ------------------------------------------------------------
-- Example 3: Dropping a View Safely
-- ------------------------------------------------------------

DROP VIEW IF EXISTS sales.vw_active_customer_orders;
GO


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- What is a View?
--   - A view is a stored SQL query definition that acts as a virtual table.
--   - Standard views DO NOT store physical data (unless created as an Indexed / Materialized View with SCHEMABINDING).
-- How the Database Engine Executes a View:
--   - Query Expansion: When you query a view, SQL Server merges the view's internal SELECT statement with your outer query, optimizing them together into a single execution plan.
-- View Syntax Constraints in T-SQL:
--   - ORDER BY is NOT allowed inside a view definition unless TOP, OFFSET, or FOR XML is also specified (relational views have no inherent order).
--   - Temporary tables cannot be referenced inside views.
--   - The `CREATE VIEW` statement must be the first statement in a query batch (hence separated by `GO`).
-- Views vs CTEs vs Tables:
--   - Tables store physical data on disk.
--   - Views persist the query definition permanently in the database catalog for reuse across multiple sessions.
--   - CTEs exist only for the duration of a single query execution.
