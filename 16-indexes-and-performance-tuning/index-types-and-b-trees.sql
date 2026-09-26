-- ============================================================
-- Topic: Indexes & Physical B-Tree Structures (Heaps, Clustered, Non-Clustered)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Understanding database storage architecture, B-Tree index structures, and physical row lookups
-- ============================================================


-- ------------------------------------------------------------
-- Physical Storage Concepts: Heap vs Clustered Table
-- ------------------------------------------------------------

-- 1. HEAP: A table without a clustered index. Data pages have no physical ordering.
-- Rows are inserted wherever free space exists. Pointers are 8-byte Row Identifiers (RIDs).
-- Table Scans on Heaps require reading every page sequentially.

-- 2. CLUSTERED INDEX: The table IS the index. The leaf level of the B-Tree contains the actual data rows.
-- A table can have EXACTLY ONE clustered index because data can only be physically sorted one way.
-- In SQL Server, creating a PRIMARY KEY constraint creates a UNIQUE CLUSTERED index by default.


-- ------------------------------------------------------------
-- Example 1: Creating a Clustered Index
-- ------------------------------------------------------------

-- Explicitly defining a clustered index on a high-throughput time series table
CREATE TABLE iot.sensor_readings (
    reading_id      BIGINT IDENTITY(1, 1) NOT NULL,
    sensor_id       INT                   NOT NULL,
    recorded_at     DATETIME2(3)          NOT NULL,
    temperature     DECIMAL(5, 2)         NOT NULL,
    humidity        DECIMAL(5, 2)         NOT NULL,

    -- Clustered on sensor_id + recorded_at for range scans
    CONSTRAINT pk_sensor_readings PRIMARY KEY CLUSTERED (sensor_id, recorded_at)
);


-- ------------------------------------------------------------
-- Example 2: Creating a Non-Clustered Index (B-Tree Pointers)
-- ------------------------------------------------------------

-- A separate B-Tree whose leaf nodes contain the index key and a bookmark:
-- If table has a clustered index -> Bookmark is the Clustered Key.
-- If table is a heap -> Bookmark is the physical RID (File:Page:Slot).
CREATE NONCLUSTERED INDEX ix_customers_email
ON sales.customers (email);


-- ------------------------------------------------------------
-- Example 3: Key Lookup Demonstration
-- ------------------------------------------------------------

-- If this query uses ix_customers_email, it seeks the email in the non-clustered index,
-- then performs a "Key Lookup" back to the Clustered Index to retrieve phone_number.
SELECT
    first_name,
    last_name,
    phone
FROM sales.customers
WHERE email = 'tariq.zaid@example.com';


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- B-Tree Anatomy:
--   - Root Level -> Intermediate Levels -> Leaf Level.
--   - Index Seek: Navigates the B-Tree from root to leaf in O(log N) page reads.
--   - Index Scan: Reads all leaf pages sequentially from beginning to end.
-- Key Lookup / Bookmark Lookup:
--   - Occurs when a non-clustered index satisfies the WHERE clause, but the SELECT projection asks for additional columns not present in the index.
--   - If many rows match, the cost of multiple random I/O Key Lookups causes the query optimizer to abandon the index and execute a full Clustered Index Scan instead!
-- Clustered Index Key Guidelines:
--   - Should be: Unique, Narrow (small byte size), Static (rarely updated), and Sequential (like IDENTITY) to prevent leaf page splits.
