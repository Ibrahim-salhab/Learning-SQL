-- ============================================================
-- Best Practice: Defaulting to UNION ALL over UNION
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Maximizing query execution efficiency by avoiding unnecessary distinct sort operations
-- ============================================================


-- ------------------------------------------------------------
-- Less Ideal: Defaulting to UNION when datasets are mutually exclusive
-- ------------------------------------------------------------

-- Incurs an expensive internal SORT DISTINCT operator even though the two tables cannot share IDs
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM sales.current_orders

UNION

SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM archive.historical_orders;


-- ------------------------------------------------------------
-- Preferred: Use UNION ALL when rows are distinct or duplicates are acceptable
-- ------------------------------------------------------------

-- Merges result streams with zero memory sorting or deduplication overhead
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM sales.current_orders

UNION ALL

SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM archive.historical_orders;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Performance Difference:
--   - UNION forces the database engine to perform a DISTINCT sort or hash match across all projected columns to find and purge duplicate rows. This requires memory grants and potential tempdb spills on large datasets.
--   - UNION ALL simply concatenates the two rowsets, streaming output immediately with minimal memory and CPU usage.
-- Golden Rule: Default to UNION ALL. Only switch to UNION if business logic explicitly demands eliminating duplicate rows across both queries.
