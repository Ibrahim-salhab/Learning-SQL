-- ============================================================
-- Best Practice: Defensive NULL Handling Patterns
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Preventing arithmetic silent failures, runtime division-by-zero crashes, and three-valued boolean logic bugs
-- ============================================================


-- ------------------------------------------------------------
-- Pattern 1: Safe Division using NULLIF
-- ------------------------------------------------------------

-- Crash Risk: Query halts with "Divide by zero error encountered" if any row has zero units
-- SELECT product_id, revenue / units_sold FROM sales.summary;

-- Defensive: NULLIF turns 0 into NULL; division by NULL yields safe NULL
SELECT
    product_id,
    revenue,
    units_sold,
    revenue / NULLIF(units_sold, 0) AS safe_average_selling_price
FROM sales.summary;


-- ------------------------------------------------------------
-- Pattern 2: Defensive Arithmetic with Nullable Columns
-- ------------------------------------------------------------

-- Risk: Single NULL column nullifies the entire computed expression
SELECT
    invoice_id,
    subtotal + ISNULL(shipping_fee, 0.00) + ISNULL(tax_fee, 0.00) AS calculated_total
FROM billing.invoices;


-- ------------------------------------------------------------
-- Pattern 3: The Fatal NOT IN with NULL Trap
-- ------------------------------------------------------------

-- DANGEROUS: If the subquery or list returns even ONE NULL, NOT IN returns ZERO rows total!
-- SELECT customer_id FROM sales.customers WHERE customer_id NOT IN (SELECT customer_id FROM sales.blacklisted_accounts);

-- Preferred Defensive Alternatives:
-- Option A: Explicitly filter NULLs out of the candidate set:
SELECT customer_id
FROM sales.customers
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM sales.blacklisted_accounts
    WHERE customer_id IS NOT NULL
);

-- Option B (Best): Use NOT EXISTS instead of NOT IN:
SELECT c.customer_id
FROM sales.customers AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM sales.blacklisted_accounts AS b
    WHERE b.customer_id = c.customer_id
);


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Three-Valued Logic Trap: In SQL, comparisons involving NULL produce UNKNOWN.
--   - For IN: value IN (1, 2, NULL) can be TRUE if value is 1 or 2.
--   - For NOT IN: NOT (value = 1 OR value = 2 OR value = NULL). If value is not 1 or 2, NOT (FALSE OR FALSE OR UNKNOWN) evaluates to NOT (UNKNOWN) = UNKNOWN. Because SQL filters out rows that are not strictly TRUE, the query silently returns zero rows!
-- NOT EXISTS is always immune to the NOT IN / NULL trap and generally performs identically or better.
