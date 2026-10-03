-- ============================================================
-- Topic: Execution Plans & Query Hints
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Reading graphical/text execution plans, identifying physical join operators, and applying query hints
-- ============================================================


-- ------------------------------------------------------------
-- Enabling Text Execution Plans in SSMS / Scripts
-- ------------------------------------------------------------

-- SET SHOWPLAN_TEXT ON;   -- Generates estimated plan without executing query
-- SET STATISTICS TIME ON;  -- Displays CPU time and elapsed execution time
-- SET STATISTICS IO ON;    -- Displays logical reads, physical reads, and read-ahead reads


-- ------------------------------------------------------------
-- Understanding Physical Join Operators in Execution Plans
-- ------------------------------------------------------------

-- 1. NESTED LOOPS:
--    - Outer loop iterates through each row of Table A; inner loop seeks matching rows in Table B.
--    - Ideal when: One input is small, and the inner input has an efficient index seek.
--
-- 2. MERGE JOIN:
--    - Both inputs must be physically presorted on the join key (via Clustered Index or explicit Sort).
--    - Reads both streams simultaneously in parallel. Highly efficient for large, sorted datasets.
--
-- 3. HASH MATCH:
--    - Builds an in-memory hash table on the smaller input; probes the hash table using the larger input.
--    - Ideal when: Joining large, unsorted, unindexed tables. High CPU/memory grant requirement.


-- ------------------------------------------------------------
-- Example: Query Hints (Use as Last Resort)
-- ------------------------------------------------------------

-- Hint 1: OPTION (RECOMPILE)
-- Prevents parameter sniffing bugs by generating a fresh plan on every execution
SELECT order_id, customer_id, total_amount
FROM sales.orders
WHERE customer_id = 1042
OPTION (RECOMPILE);

-- Hint 2: OPTIMIZE FOR (Value)
-- Forces the query optimizer to compile the plan assuming a representative parameter value
DECLARE @status VARCHAR(20) = 'Pending';

SELECT order_id, total_amount
FROM sales.orders
WHERE order_status = @status
OPTION (OPTIMIZE FOR (@status = 'Pending'));

-- Hint 3: Table Hint WITH (NOLOCK) / READUNCOMMITTED
-- Reads uncommitted dirty rows; bypasses shared locks (Risk of dirty reads & phantom rows!)
SELECT COUNT(*) AS approximate_order_count
FROM sales.orders WITH (NOLOCK);


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Estimated vs Actual Execution Plans:
--   - Estimated Plan: The optimizer's best guess based on cardinality statistics without actually running the query.
--   - Actual Plan: Includes runtime statistics (actual rows returned, elapsed time, memory grant, thread parallelism).
-- Cardinality Estimation Warning Signs:
--   - If "Estimated Number of Rows" significantly diverges from "Actual Number of Rows" (e.g. Estimated 1 vs Actual 500,000), statistics are stale or the query is non-sargable.
-- Beware of Table Hints:
--   - Query hints like `WITH (NOLOCK)` or forcing an index (`WITH (INDEX(...))`) override the cost-based optimizer. As data volumes grow, hardcoded hints often degrade performance rather than improving it. Fix missing indexes or statistics first before resorting to hints.
