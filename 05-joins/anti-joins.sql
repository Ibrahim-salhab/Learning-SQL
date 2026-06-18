-- ============================================================
-- Topic: ANTI JOINs (Left, Right, Full Anti Joins)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Returning rows from one table that have NO corresponding match in another table
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: LEFT ANTI JOIN
-- ------------------------------------------------------------

-- Target: Find customers who have never placed an order
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
    ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;


-- ------------------------------------------------------------
-- Example 2: RIGHT ANTI JOIN
-- ------------------------------------------------------------

-- Target: Find supplier companies that currently have no products listed in our catalog
SELECT
    s.supplier_id,
    s.company_name,
    s.contact_email
FROM inventory.products AS p
RIGHT JOIN procurement.suppliers AS s
    ON p.supplier_id = s.supplier_id
WHERE p.supplier_id IS NULL;


-- ------------------------------------------------------------
-- Example 3: FULL ANTI JOIN (Exclusive disjunction / XOR)
-- ------------------------------------------------------------

-- Target: Find products that exist ONLY in the catalog OR ONLY in the legacy warehouse ledger, but not both
SELECT
    c.product_sku AS catalog_sku,
    c.product_name AS catalog_name,
    l.legacy_sku,
    l.legacy_name
FROM catalog.products AS c
FULL OUTER JOIN legacy.warehouse_records AS l
    ON c.product_sku = l.legacy_sku
WHERE c.product_sku IS NULL
   OR l.legacy_sku IS NULL;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- SQL does not have a native "ANTI JOIN" keyword; it is implemented via an OUTER JOIN combined with a WHERE ... IS NULL filter on the opposing table's primary/foreign key.
-- Always test IS NULL against a non-nullable column (ideally the Primary Key) of the joined table to avoid false positives from legitimately nullable columns.
-- LEFT ANTI JOIN is commonly used for:
--   - Identifying dormant/churned users
--   - Finding unreferenced lookup codes or orphaned child records
--   - Data reconciliation and audit queries
-- Anti joins can also be expressed with NOT EXISTS or NOT IN, but LEFT JOIN ... WHERE ... IS NULL often optimizes very well when the joining key is indexed.
