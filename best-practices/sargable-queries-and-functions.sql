-- ============================================================
-- Best Practice: SARGable Queries & Avoiding Functions on Filtered Columns
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Ensuring query filters can utilize B-Tree index seeks rather than forcing full table scans
-- ============================================================


-- ------------------------------------------------------------
-- Scenario A: Date Filtering (Non-SARGable vs SARGable)
-- ------------------------------------------------------------

-- Non-SARGable: Wrapping indexed column 'order_date' in YEAR() forces engine to execute YEAR() on EVERY row in table (Full Scan)
SELECT
    order_id,
    order_date,
    total_amount
FROM sales.orders
WHERE YEAR(order_date) = 2024;

-- SARGable: Column is isolated on left side; engine performs a direct B-Tree Index Seek
SELECT
    order_id,
    order_date,
    total_amount
FROM sales.orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01';


-- ------------------------------------------------------------
-- Scenario B: String Prefix Filtering (Non-SARGable vs SARGable)
-- ------------------------------------------------------------

-- Non-SARGable: Function wraps column
SELECT product_id, sku_code
FROM inventory.products
WHERE LEFT(sku_code, 3) = 'PRD';

-- SARGable: Range query allows index seek
SELECT product_id, sku_code
FROM inventory.products
WHERE sku_code LIKE 'PRD%';


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- SARGable stands for "Search Argument Able".
-- A query predicate is SARGable when the database engine can directly exploit an existing index to seek directly to matching rows instead of evaluating expressions row-by-row.
-- Non-SARGable anti-patterns:
--   - Functions on indexed columns: WHERE MONTH(created_at) = 5
--   - Arithmetic on indexed columns: WHERE salary * 1.10 > 50000 (rewrite to: salary > 50000 / 1.10)
--   - Leading wildcards: WHERE email LIKE '%@domain.com'
--   - Implicit data type conversions: Comparing VARCHAR column to NVARCHAR parameter
-- Isolating the raw indexed column on one side of the operator is one of the highest-impact query optimization techniques in SQL.
