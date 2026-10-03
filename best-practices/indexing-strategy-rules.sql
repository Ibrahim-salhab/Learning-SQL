-- ============================================================
-- Best Practice: Indexing Strategy & Golden Rules
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Practical guidelines for index design, write overhead trade-offs, and avoiding over-indexing
-- ============================================================


-- ------------------------------------------------------------
-- The 5 Golden Rules of Database Indexing
-- ------------------------------------------------------------

-- Rule 1: Every table must have a narrow, unique, static Clustered Index (IDENTITY is ideal).
-- Rule 2: Index all Foreign Key columns to prevent table locks and slow joins.
-- Rule 3: Use the Leftmost Prefix Rule for composite indexes (Put high-selectivity columns first).
-- Rule 4: Use INCLUDE columns to create Covering Indexes without widening upper B-Tree levels.
-- Rule 5: Regularly identify and drop unused indexes (they slow down every INSERT, UPDATE, and DELETE).


-- ------------------------------------------------------------
-- Less Ideal vs Preferred Covering Index Comparison
-- ------------------------------------------------------------

-- Less Ideal: Wide composite key (stores address, phone at EVERY level of B-tree)
-- CREATE NONCLUSTERED INDEX ix_bad ON sales.customers (customer_id, country_code, address_line, phone_number);

-- Preferred: Narrow key with payload in INCLUDE (address, phone stored ONLY at leaf level)
CREATE NONCLUSTERED INDEX ix_customers_country_COVERING
ON sales.customers (country_code)
INCLUDE (customer_name, email, member_since);


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Write Amplification / DML Overhead:
--   - An index is not free! Every additional non-clustered index adds overhead to every `INSERT`, `UPDATE`, and `DELETE` on that table.
--   - OLTP systems (transactional apps) require lean indexing (3 to 6 indexes per table maximum).
--   - OLAP / Data Warehouse systems tolerate heavy indexing (or Clustered Columnstore) because data is loaded in bulk batches and queried intensely.
-- Duplicate & Overlapping Indexes:
--   - An index on `(A, B)` makes an index on `(A)` completely redundant! Drop the index on `(A)` to save disk space and write overhead.
