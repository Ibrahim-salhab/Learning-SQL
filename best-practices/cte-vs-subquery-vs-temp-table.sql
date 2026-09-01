-- ============================================================
-- Best Practice: CTE vs Derived Table vs Temporary Table
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Choosing the optimal query structuring mechanism for readability, maintainability, and query optimizer efficiency
-- ============================================================


-- ------------------------------------------------------------
-- Comparison: When to Use Each Construct
-- ------------------------------------------------------------

-- Option 1: CTE (Best for readability, logical sequencing, and recursion)
;WITH active_subscribers AS (
    SELECT user_id, plan_id, start_date
    FROM billing.subscriptions
    WHERE is_active = 1
),
plan_tiers AS (
    SELECT user_id, plan_id
    FROM active_subscribers
    WHERE start_date >= '2024-01-01'
)
SELECT * FROM plan_tiers;

-- Option 2: Temporary Table (#temp)
-- Best for heavy datasets queried multiple times or requiring explicit indexes
CREATE TABLE #recent_high_spenders (
    customer_id INT PRIMARY KEY,
    total_spend DECIMAL(12, 2) NOT NULL
);

INSERT INTO #recent_high_spenders (customer_id, total_spend)
SELECT customer_id, SUM(total_amount)
FROM sales.orders
WHERE order_date >= '2024-01-01'
GROUP BY customer_id
HAVING SUM(total_amount) > 10000.00;

-- Can now be joined multiple times with full statistics and index seeks
SELECT * FROM #recent_high_spenders;

DROP TABLE IF EXISTS #recent_high_spenders;


-- ------------------------------------------------------------
-- Decision Guide Matrix
-- ------------------------------------------------------------

-- 1. Common Table Expression (CTE):
--    - Use when: Structuring complex multi-step queries for human readability.
--    - Use when: Solving recursive problems (hierarchies, date series).
--    - Caution: In SQL Server, a CTE does NOT materialize data. If referenced multiple times in the outer query, it executes multiple times!
--
-- 2. Derived Table (Subquery in FROM):
--    - Use when: Encapsulating a small, one-off filter or aggregation needed immediately in a single query.
--    - Drawback: Deeply nested derived tables quickly become unreadable ("SQL Pyramid of Doom").
--
-- 3. Temporary Table (#temp):
--    - Use when: Storing intermediate results that will be queried multiple times within a stored procedure or script.
--    - Advantage: Supports explicit indexes (clustered/non-clustered), maintains real distribution statistics, and relieves optimizer complexity on large datasets.
