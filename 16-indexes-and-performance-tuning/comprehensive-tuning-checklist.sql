-- ============================================================
-- Topic: Enterprise SQL Query Performance Tuning Checklist
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Quick reference checklist of query optimization techniques across fetching, filtering, joining, aggregations, and DDL
-- ============================================================


-- ------------------------------------------------------------
-- 1. Data Fetching Optimization
-- ------------------------------------------------------------
-- [ ] Eliminate SELECT * in production; project only required columns.
-- [ ] Pair SELECT TOP (N) with an explicit ORDER BY to ensure deterministic results.
-- [ ] Avoid querying large tables over high-latency networks without server-side pagination (OFFSET / FETCH).


-- ------------------------------------------------------------
-- 2. Filtering & SARGability Rules
-- ------------------------------------------------------------
-- [ ] Keep indexed columns isolated on one side of comparison operators:
--     BAD:  WHERE YEAR(order_date) = 2024
--     GOOD: WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01'
-- [ ] Avoid leading wildcards in LIKE predicates (e.g. LIKE '%pattern' forces an index scan).
-- [ ] Prevent implicit data type conversions (e.g. comparing a VARCHAR column to an NVARCHAR parameter).
-- [ ] Beware of the NOT IN with NULL trap; use NOT EXISTS instead.


-- ------------------------------------------------------------
-- 3. Joining Optimization
-- ------------------------------------------------------------
-- [ ] Ensure all Foreign Key columns participating in JOIN ON clauses are indexed.
-- [ ] Avoid Cartesian explosions: Verify joining columns have 1:1 or 1:N cardinality.
-- [ ] When mixing INNER and LEFT joins, place INNER joins before outer joins to prevent accidental row filtering.
-- [ ] Filter rows in the WHERE or ON clause before joining large datasets.


-- ------------------------------------------------------------
-- 4. Aggregations & Grouping
-- ------------------------------------------------------------
-- [ ] Filter rows early with WHERE instead of filtering in HAVING.
-- [ ] In window functions, always explicitly specify ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW to prevent tempdb spooling.
-- [ ] Prefer UNION ALL over UNION whenever duplicate removal is not strictly required.


-- ------------------------------------------------------------
-- 5. Subqueries vs CTEs vs Temp Tables
-- ------------------------------------------------------------
-- [ ] Avoid correlated subqueries in SELECT projection lists when a JOIN or CTE can achieve the same result in a single set-based pass.
-- [ ] When a CTE or subquery is queried more than once in a batch, dump results into a `#temp` table with an index to prevent redundant multiple evaluations.


-- ------------------------------------------------------------
-- 6. Table DDL & Physical Schema Design
-- ------------------------------------------------------------
-- [ ] Choose the smallest appropriate data type (e.g., TINYINT vs INT, DATE vs DATETIME2).
-- [ ] Use VARCHAR instead of NVARCHAR if Unicode character support is not required (saves 50% storage space).
-- [ ] Ensure every table has a narrow, sequential, non-updating Clustered Index (e.g. IDENTITY or sequential GUID) to avoid B-Tree page splits.
-- [ ] Use Clustered Columnstore Indexes (CCI) for massive fact tables (> 5-10 million rows) with analytical workloads.
