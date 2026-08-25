-- ============================================================
-- Best Practice: EXISTS vs IN for Subquery Filtering
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Selecting the appropriate existence predicate, preventing three-valued logic failures, and leveraging short-circuit optimization
-- ============================================================


-- ------------------------------------------------------------
-- Scenario A: Positive Membership (IN vs EXISTS)
-- ------------------------------------------------------------

-- Pattern 1: IN (Best for small, static literal lists)
SELECT customer_id, customer_name
FROM sales.customers
WHERE country_code IN ('JO', 'SA', 'AE');

-- Pattern 2: EXISTS (Best when subquery references a large related table)
-- Short-circuits immediately upon finding the first match
SELECT c.customer_id, c.first_name, c.last_name
FROM sales.customers AS c
WHERE EXISTS (
    SELECT 1
    FROM sales.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
);


-- ------------------------------------------------------------
-- Scenario B: Negative Membership (NOT IN vs NOT EXISTS) - THE DANGER ZONE
-- ------------------------------------------------------------

-- High Risk / Dangerous: If audit_exceptions has even ONE row with NULL customer_id,
-- the entire query silently returns ZERO rows!
-- SELECT customer_id FROM sales.customers WHERE customer_id NOT IN (SELECT customer_id FROM compliance.audit_exceptions);

-- Preferred Safe Standard: NOT EXISTS is 100% immune to NULL values
SELECT c.customer_id, c.first_name, c.last_name
FROM sales.customers AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM compliance.audit_exceptions AS e
    WHERE e.customer_id = c.customer_id
);


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Three-Valued Logic Breakdown:
--   - If subquery returns values {1, 2, NULL}:
--   - `x NOT IN (1, 2, NULL)` translates to: `x <> 1 AND x <> 2 AND x <> NULL`.
--   - In SQL, `x <> NULL` evaluates to UNKNOWN.
--   - `TRUE AND TRUE AND UNKNOWN` resolves to UNKNOWN. Because WHERE only retains rows where the predicate is TRUE, ALL rows are discarded!
-- Execution Plan Optimization:
--   - Modern SQL Server query optimizers often convert both `IN` and `EXISTS` into the same internal Left Semi Join.
--   - However, for negative checks, `NOT EXISTS` consistently produces cleaner anti-semi-join plans and never risks catastrophic three-valued logic errors.
-- Rule of Thumb: Use `IN` for static literal lists; use `EXISTS` / `NOT EXISTS` for table-backed subqueries.
