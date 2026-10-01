-- ============================================================
-- Topic: Specialized Indexes (Filtered, Unique & Columnstore)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Building filtered B-Tree indexes, enforcing uniqueness, and leveraging Columnstore indexes for analytical workloads
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Filtered Index (Partial Index with WHERE)
-- ------------------------------------------------------------

-- In many tables, 95% of rows have order_status = 'Completed'.
-- We only need fast queries on active, pending orders (small subset):
CREATE NONCLUSTERED INDEX ix_orders_pending_only
ON sales.orders (order_date, total_amount)
WHERE order_status IN ('Pending', 'Processing');

-- Benefits:
-- 1. Extremely small index footprint in memory.
-- 2. Lower maintenance cost during updates to 'Completed' orders.


-- ------------------------------------------------------------
-- Example 2: Unique Index with NULL Handling
-- ------------------------------------------------------------

-- Enforcing business uniqueness across non-primary key attributes
CREATE UNIQUE NONCLUSTERED INDEX uq_ix_members_national_id
ON membership.members (national_id)
WHERE national_id IS NOT NULL; -- Filtered unique index: Allows multiple NULLs in T-SQL!


-- ------------------------------------------------------------
-- Example 3: Clustered Columnstore Index (CCI) for Data Warehousing
-- ------------------------------------------------------------

-- Standard Rowstore: Data is stored page-by-page as complete rows (Row-oriented). Ideal for OLTP.
-- Columnstore: Data is stored column-by-column in compressed rowgroups (~1 million rows per group). Ideal for OLAP/DWH.

CREATE TABLE fact.sales_transactions (
    transaction_key   BIGINT IDENTITY(1, 1),
    date_key          INT NOT NULL,
    customer_key      INT NOT NULL,
    product_key       INT NOT NULL,
    store_key         INT NOT NULL,
    quantity          INT NOT NULL,
    sale_amount       DECIMAL(10, 2) NOT NULL,
    cost_amount       DECIMAL(10, 2) NOT NULL
);

-- Convert physical table into a Clustered Columnstore structure
CREATE CLUSTERED COLUMNSTORE INDEX cci_fact_sales_transactions
ON fact.sales_transactions;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Filtered Indexes:
--   - Reduces index size and maintenance overhead by indexing only a defined subset of rows.
--   - Solves the ANSI NULL uniqueness dilemma in SQL Server (where a standard UNIQUE constraint permits only one single NULL).
-- Columnstore Architecture:
--   - Rowgroups: Rows are divided into groups of up to 1,048,576 rows.
--   - Column Segments: Each column within a rowgroup is compressed independently into a segment using dictionary and run-length encoding.
--   - Batch Mode Execution: Processes chunks of ~900 rows simultaneously in CPU vectors rather than row-by-row (Row Mode), achieving 10x-100x query speedups on aggregate analytical queries.
--   - Trade-off: Columnstore indexes have higher latency for single-row singleton updates and inserts; they are optimized for analytical aggregations (SUM, AVG, COUNT) and bulk loading.
