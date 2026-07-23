-- ============================================================
-- Topic: NULL Behavior in Operations, Aggregations, Joins & Sorting
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Understanding how NULL propagates through math, joins, aggregations, and sort operations
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: NULL in Arithmetic Calculations (NULL Propagation)
-- ------------------------------------------------------------

-- Any basic arithmetic with NULL results in NULL!
SELECT
    product_id,
    base_price,
    shipping_fee,
    tax_amount,
    -- If tax_amount is NULL, total becomes NULL:
    base_price + shipping_fee + tax_amount AS unsafe_total_price,
    -- Defensive calculation using COALESCE/ISNULL:
    base_price + ISNULL(shipping_fee, 0.00) + ISNULL(tax_amount, 0.00) AS safe_total_price
FROM sales.invoices;


-- ------------------------------------------------------------
-- Example 2: NULL in Aggregation Functions (COUNT, SUM, AVG)
-- ------------------------------------------------------------

SELECT
    department_id,
    COUNT(*) AS count_all_rows,                     -- Counts every row (including NULLs)
    COUNT(commission_pct) AS count_non_null_comm,    -- Ignores rows where commission_pct IS NULL
    AVG(commission_pct) AS avg_commission_only_with_comm, -- Divides sum only by non-null rows!
    AVG(ISNULL(commission_pct, 0.0)) AS avg_commission_across_all_staff
FROM hr.employees
GROUP BY department_id;


-- ------------------------------------------------------------
-- Example 3: NULL in Joins (Equality vs UNKNOWN)
-- ------------------------------------------------------------

-- In SQL, NULL = NULL evaluates to UNKNOWN (neither TRUE nor FALSE).
-- Standard equality joins on nullable columns will DROP rows where both sides are NULL:
SELECT
    a.item_id,
    b.item_id
FROM warehouse.inventory_a AS a
INNER JOIN warehouse.inventory_b AS b
    -- To match rows where both location_code values are NULL:
    ON (a.location_code = b.location_code OR (a.location_code IS NULL AND b.location_code IS NULL));


-- ------------------------------------------------------------
-- Example 4: NULL in Sorting (ORDER BY)
-- ------------------------------------------------------------

-- In SQL Server, NULL values sort as the lowest possible values:
-- Ascending (ASC): NULLs appear at the TOP
-- Descending (DESC): NULLs appear at the BOTTOM
SELECT
    lead_id,
    lead_name,
    expected_deal_size
FROM crm.sales_leads
ORDER BY expected_deal_size ASC;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Math Propagation Rule: NULL + 10 = NULL; NULL * 5 = NULL; NULL / 2 = NULL. Always use ISNULL/COALESCE when doing arithmetic with nullable columns.
-- Aggregation Rule:
--   - COUNT(*) counts rows regardless of column values.
--   - Aggregate functions (SUM, AVG, MIN, MAX, COUNT(col)) completely ignore NULL values.
--   - Gotcha: AVG(commission) calculates SUM(commission) / COUNT(commission), NOT SUM / COUNT(*). If you need NULLs counted as 0, use AVG(ISNULL(col, 0)).
-- Join Rule: NULL is never equal to another NULL in standard relational comparisons.
-- Sorting Rule: SQL Server does not support NULLS FIRST / NULLS LAST syntax natively; use CASE expressions in ORDER BY if custom NULL placement is required.
