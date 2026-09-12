-- ============================================================
-- Topic: Temporary Tables (#Local vs ##Global) & Table Variables
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Creating, populating, and managing temporary storage structures in Tempdb for complex procedural processing
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Local Temporary Table (#temp)
-- ------------------------------------------------------------

-- Scoped strictly to the current session/connection. Dropped automatically when session terminates.
DROP TABLE IF EXISTS #high_value_customers;

CREATE TABLE #high_value_customers (
    customer_id     INT             NOT NULL,
    total_spend     DECIMAL(12, 2)  NOT NULL,
    order_count     INT             NOT NULL,

    CONSTRAINT pk_temp_customers PRIMARY KEY CLUSTERED (customer_id)
);

INSERT INTO #high_value_customers (customer_id, total_spend, order_count)
SELECT
    customer_id,
    SUM(total_amount),
    COUNT(order_id)
FROM sales.orders
GROUP BY customer_id
HAVING SUM(total_amount) > 5000.00;

-- Querying the local temp table:
SELECT * FROM #high_value_customers;

-- Best Practice: Explicitly drop temp tables when finished
DROP TABLE IF EXISTS #high_value_customers;


-- ------------------------------------------------------------
-- Example 2: Table Variable (@table)
-- ------------------------------------------------------------

-- Scoped strictly to the current execution batch. Does not participate in transactions.
DECLARE @eligible_discounts TABLE (
    product_id       INT            PRIMARY KEY,
    discount_pct     DECIMAL(4, 2)  NOT NULL
);

INSERT INTO @eligible_discounts (product_id, discount_pct)
VALUES
    (101, 0.15),
    (204, 0.20),
    (309, 0.10);

SELECT
    p.product_name,
    p.unit_price,
    d.discount_pct,
    p.unit_price * (1 - d.discount_pct) AS promotional_price
FROM inventory.products AS p
INNER JOIN @eligible_discounts AS d
    ON p.product_id = d.product_id;


-- ------------------------------------------------------------
-- Example 3: Global Temporary Table (##global_temp)
-- ------------------------------------------------------------

-- Accessible across ALL active database sessions.
-- Dropped when the creating session disconnects AND all referencing sessions finish.
DROP TABLE IF EXISTS ##shared_system_status;

CREATE TABLE ##shared_system_status (
    server_node      VARCHAR(50),
    is_under_load    BIT,
    reported_at      DATETIME2 DEFAULT SYSDATETIME()
);


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Physical Storage in Tempdb:
--   - Both #temp tables and table variables (@table) reside physically in the `tempdb` system database.
-- #Temp Tables vs @Table Variables:
--   - Statistics & Cardinality: #temp tables have full distribution statistics and histograms. Table variables historically assume 1 row (improved in modern SQL Server 2019+ table variable deferred compilation), which can cause catastrophic execution plans on large datasets (> 100 rows).
--   - Indexing: #temp tables support creating additional non-clustered indexes after creation. Table variables only support indexes declared inline during initial declaration.
--   - Transactions: #temp tables roll back during `ROLLBACK TRANSACTION`. Table variables DO NOT roll back!
-- Best Practice Rule: Use Table Variables only for tiny lookup lists (< 100 rows). Use Local Temp Tables (#temp) for medium-to-large staging data.
