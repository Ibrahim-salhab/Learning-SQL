-- ============================================================
-- Best Practice: Choosing the Appropriate JOIN Type
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Selecting the correct join method based on relational cardinality and business intent while avoiding unintended data loss or row multiplication
-- ============================================================


-- ------------------------------------------------------------
-- Less Ideal: Using INNER JOIN when records might have optional relationships
-- ------------------------------------------------------------

-- Risk: Customers who have not made a purchase yet are silently dropped from report
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    o.order_id,
    o.total_amount
FROM sales.customers AS c
INNER JOIN sales.orders AS o
    ON c.customer_id = o.customer_id;


-- ------------------------------------------------------------
-- Preferred: Use LEFT JOIN when parent entities must always be preserved
-- ------------------------------------------------------------

-- Guarantees all customers appear, displaying NULL for order fields if none exist
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ISNULL(o.order_id, 0) AS order_id,
    ISNULL(o.total_amount, 0.00) AS total_amount
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
    ON c.customer_id = o.customer_id;


-- ------------------------------------------------------------
-- Join Decision Matrix
-- ------------------------------------------------------------

-- Ask: "Do I need rows from Table A even if Table B has no matching entry?"
--   - If YES (keep A): Use LEFT JOIN.
--   - If NO (only keep rows existing in both): Use INNER JOIN.
--   - If I only want rows in A that DO NOT exist in B: Use LEFT ANTI JOIN (LEFT JOIN + WHERE B.key IS NULL).
--   - If I need every row from both tables regardless of match: Use FULL OUTER JOIN.
--   - If I need every possible combination: Use CROSS JOIN.


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Always ensure foreign key columns participating in JOIN ON clauses are indexed in large production databases to avoid costly table scans.
-- Standardize on LEFT JOIN across your codebase instead of mixing LEFT and RIGHT joins; reading left-to-right makes query logic far easier to maintain.
-- Beware of Cartesian explosion: Joining on non-unique columns multiplies matching rows (M x N), skewing subsequent aggregate sums and counts.
