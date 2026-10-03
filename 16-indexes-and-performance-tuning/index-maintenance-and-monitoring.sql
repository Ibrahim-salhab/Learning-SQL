-- ============================================================
-- Topic: Index Maintenance, DMVs & Statistics
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Monitoring index usage, detecting unused and missing indexes, analyzing fragmentation, and maintaining statistics
-- ============================================================


-- ------------------------------------------------------------
-- Diagnostic 1: Identifying Unused or Costly Indexes via DMVs
-- ------------------------------------------------------------

-- Indexes with high write counts (user_updates) but 0 reads (seeks/scans/lookups) waste disk I/O
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates, -- Number of INSERT/UPDATE/DELETE writes
    (s.user_seeks + s.user_scans + s.user_lookups) AS total_reads
FROM sys.indexes AS i
LEFT JOIN sys.dm_db_index_usage_stats AS s
    ON i.object_id = s.object_id
   AND i.index_id = s.index_id
   AND s.database_id = DB_ID()
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
  AND i.type_desc = 'NONCLUSTERED'
ORDER BY s.user_updates DESC, total_reads ASC;


-- ------------------------------------------------------------
-- Diagnostic 2: Querying SQL Server's Missing Index Recommendations
-- ------------------------------------------------------------

SELECT TOP (10)
    mig.index_group_handle,
    mid.statement AS table_name,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.unique_compiles,
    migs.user_seeks,
    migs.avg_user_impact AS estimated_percentage_improvement
FROM sys.dm_db_missing_index_groups AS mig
INNER JOIN sys.dm_db_missing_index_group_stats AS migs
    ON mig.index_group_handle = migs.group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid
    ON mig.index_handle = mid.index_handle
ORDER BY (migs.avg_user_impact * migs.user_seeks) DESC;


-- ------------------------------------------------------------
-- Diagnostic 3: Analyzing Index Fragmentation (sys.dm_db_index_physical_stats)
-- ------------------------------------------------------------

SELECT
    OBJECT_SCHEMA_NAME(object_id) AS schema_name,
    OBJECT_NAME(object_id) AS table_name,
    index_id,
    avg_fragmentation_in_percent,
    page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED')
WHERE page_count > 1000 -- Ignore small tables (< 1,000 pages) where fragmentation does not matter
ORDER BY avg_fragmentation_in_percent DESC;


-- ------------------------------------------------------------
-- Remediation: Rebuilding vs Reorganizing Indexes & Updating Statistics
-- ------------------------------------------------------------

-- Fragmentation between 10% and 30%: REORGANIZE (Online, defragments leaf level in-place)
ALTER INDEX ix_customers_email ON sales.customers REORGANIZE;

-- Fragmentation > 30%: REBUILD (Recreates index completely; can run ONLINE = ON in Enterprise)
ALTER INDEX ix_customers_email ON sales.customers REBUILD WITH (ONLINE = ON);

-- Updating Cardinality Statistics:
-- Outdated statistics cause the query optimizer to make inaccurate cardinality estimates
UPDATE STATISTICS sales.customers WITH FULLSCAN;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Why DMVs Reset:
--   - Dynamic Management Views (`sys.dm_*`) are stored in server memory and reset whenever SQL Server restarts. Never drop an index based on usage stats collected right after a server reboot!
-- The Fragmentation Threshold Rules of Thumb:
--   - Fragmentation < 10%: No action needed.
--   - Fragmentation 10% to 30%: `ALTER INDEX ... REORGANIZE` (lightweight, non-blocking).
--   - Fragmentation > 30%: `ALTER INDEX ... REBUILD` (heavy, drops and recreates B-Tree pages).
-- Statistics vs Indexes:
--   - An index without accurate statistics is like a map with outdated roads. Even with a perfect index, stale statistics force bad choices (e.g., choosing a full scan instead of an index seek).
