-- ============================================================
-- Topic: Table Partitioning (Function, Scheme, Partition Elimination)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Horizontally partitioning massive tables across discrete boundary ranges for fast archival, sliding windows, and partition elimination
-- ============================================================


-- ------------------------------------------------------------
-- Step 1: Create the Partition Function (Defines Boundaries)
-- ------------------------------------------------------------

-- Divides data chronologically by year:
-- Partition 1: (-infinity, '2023-01-01')
-- Partition 2: ['2023-01-01', '2024-01-01')
-- Partition 3: ['2024-01-01', '2025-01-01')
-- Partition 4: ['2025-01-01', +infinity)
CREATE PARTITION FUNCTION pf_annual_order_dates (DATE)
AS RANGE RIGHT FOR VALUES (
    '2023-01-01',
    '2024-01-01',
    '2025-01-01'
);
GO


-- ------------------------------------------------------------
-- Step 2: Create the Partition Scheme (Maps Partitions to Filegroups)
-- ------------------------------------------------------------

-- In this example, maps all partitions to the PRIMARY filegroup (can map to separate physical disks)
CREATE PARTITION SCHEME ps_annual_orders
AS PARTITION pf_annual_order_dates
ALL TO ([PRIMARY]);
GO


-- ------------------------------------------------------------
-- Step 3: Create the Partitioned Table
-- ------------------------------------------------------------

CREATE TABLE sales.partitioned_orders (
    order_id        INT IDENTITY(1, 1) NOT NULL,
    order_date      DATE               NOT NULL,
    customer_id     INT                NOT NULL,
    total_amount    DECIMAL(12, 2)     NOT NULL,

    -- Partition key MUST be part of the Clustered Index / Primary Key
    CONSTRAINT pk_partitioned_orders PRIMARY KEY CLUSTERED (order_date, order_id)
)
ON ps_annual_orders (order_date); -- Specifies the partition scheme and partitioning column
GO


-- ------------------------------------------------------------
-- Step 4: Partition Elimination / Pruning in Queries
-- ------------------------------------------------------------

-- SQL Server reads ONLY Partition 3; partitions 1, 2, and 4 are completely skipped (eliminated)!
SELECT
    order_id,
    order_date,
    total_amount
FROM sales.partitioned_orders
WHERE order_date >= '2024-06-01' AND order_date <= '2024-08-31';


-- ------------------------------------------------------------
-- Step 5: Inspecting Row Distribution Across Partitions
-- ------------------------------------------------------------

SELECT
    p.partition_number,
    r.boundary_value,
    p.rows AS row_count
FROM sys.partitions AS p
INNER JOIN sys.tables AS t
    ON p.object_id = t.object_id
LEFT JOIN sys.partition_range_values AS r
    ON p.partition_number = r.boundary_id
WHERE t.name = 'partitioned_orders'
  AND p.index_id = 1; -- Clustered index


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Purpose of Partitioning:
--   - Manageability: Instantly archive old years by switching entire partitions to history tables in metadata time (< 1 second) via `ALTER TABLE ... SWITCH PARTITION`.
--   - Performance: Partition Elimination allows queries filtering on the partition key to scan only relevant subsets of data pages.
-- RANGE LEFT vs RANGE RIGHT:
--   - RANGE RIGHT: The boundary value is the LOWER bound of the next partition (>= boundary). Preferred standard for date ranges.
--   - RANGE LEFT: The boundary value is the UPPER bound of the preceding partition (<= boundary).
-- Partition Key Rule:
--   - The column used to partition the table MUST be included in the primary key and all unique clustered/non-clustered indexes (referred to as an "Aligned Index").
