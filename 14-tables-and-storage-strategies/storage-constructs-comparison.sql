-- ============================================================
-- Topic: Architectural Comparison: Tables, Views, CTEs & Temp Tables
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Comprehensive reference guide comparing SQL storage constructs and execution trade-offs
-- ============================================================


-- ------------------------------------------------------------
-- Comprehensive Comparison Matrix
-- ------------------------------------------------------------

/*
+-----------------------+-------------------------+--------------------+---------------------+--------------------+--------------------+
| Feature               | Physical Table          | View               | CTE                 | Temp Table (#temp) | Table Var (@table) |
+-----------------------+-------------------------+--------------------+---------------------+--------------------+--------------------+
| Data Persistence      | Permanent on disk       | None (Virtual) *   | None (In-memory)    | Session / Tempdb   | Batch / Tempdb     |
| Reusability           | Global (All queries)    | Global (Catalog)   | Single statement    | Current session    | Current batch      |
| Query Optimization    | Full statistics/indexes | Expands into query | Expands into query  | Full statistics    | Fixed / Deferred   |
| Index Support         | Clustered & Nonclustered| If Indexed View    | None                | Full index support | Primary/Unique key |
| Memory / Tempdb Cost  | User data file (.mdf)   | Zero storage       | Zero storage        | Uses Tempdb        | Uses Tempdb        |
| Best Used For         | Source of Truth         | Logic encapsulation| Query readability & | Multi-step batch   | Tiny lookups       |
|                       | & Persistent Entities   | & Data Security    | Recursive queries   | ETL processing     | (< 100 rows)       |
+-----------------------+-------------------------+--------------------+---------------------+--------------------+--------------------+
* Standard Views store no data; Materialized/Indexed Views persist a physical clustered index.
*/


-- ------------------------------------------------------------
-- Architectural Decision Workflow
-- ------------------------------------------------------------

-- 1. Does the data need to be stored permanently for the business?
--    -> YES: Use a Physical Table (CREATE TABLE).
--
-- 2. Do you need a reusable, central query definition for BI / Security that always reflects real-time data?
--    -> YES: Use a View (CREATE VIEW).
--
-- 3. Do you need to structure a single complex query into clean, readable steps, or run a recursive hierarchy?
--    -> YES: Use a Common Table Expression (WITH cte AS (...)).
--
-- 4. Do you need intermediate staging data within a stored procedure that will be filtered or joined multiple times?
--    -> YES: Use a Local Temporary Table (#temp) with explicit indexes.
--
-- 5. Do you need a fast, tiny in-memory list of IDs inside a function or short script?
--    -> YES: Use a Table Variable (@table).


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Common Anti-Pattern: Overusing CTEs for heavy multi-table joins when referenced multiple times in the same statement. In SQL Server, referencing a CTE 3 times executes its underlying query 3 times! In such cases, dump the result into a `#temp` table once and query the temp table.
-- Common Anti-Pattern: Replacing views with physical staging tables without an automated refresh schedule, leading to stale and desynchronized reporting data.
