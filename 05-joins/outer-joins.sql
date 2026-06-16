-- ============================================================
-- Topic: OUTER JOINs (LEFT, RIGHT, FULL)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Preserving unmatched rows from one or both tables alongside matching rows
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: LEFT OUTER JOIN (All left rows preserved)
-- ------------------------------------------------------------

-- Returns ALL customers, showing order data if available or NULL if no orders exist
SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
    ON c.customer_id = o.customer_id
ORDER BY c.customer_id;


-- ------------------------------------------------------------
-- Example 2: RIGHT OUTER JOIN (All right rows preserved)
-- ------------------------------------------------------------

-- Returns ALL sales territories, even those currently without assigned sales representatives
SELECT
    e.employee_id,
    e.first_name + ' ' + e.last_name AS representative_name,
    t.territory_id,
    t.territory_name
FROM hr.employees AS e
RIGHT JOIN sales.territories AS t
    ON e.territory_id = t.territory_id;


-- ------------------------------------------------------------
-- Example 3: FULL OUTER JOIN (Preserves all rows from both tables)
-- ------------------------------------------------------------

-- Compares catalog products against physical stock items, showing matched, catalog-only, and uncatalogued inventory
SELECT
    p.product_id AS catalog_product_id,
    p.product_name,
    i.product_id AS stock_product_id,
    i.warehouse_id,
    i.quantity_on_hand
FROM inventory.products AS p
FULL OUTER JOIN inventory.warehouse_stock AS i
    ON p.product_id = i.product_id;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- LEFT JOIN preserves every row from the left table. Unmatched rows from the right table are populated with NULL values.
-- RIGHT JOIN is the symmetric opposite of LEFT JOIN. In practice, professional teams strongly prefer standardizing on LEFT JOIN for readability.
-- FULL JOIN returns all matching rows, plus unmatched rows from the left (with right-side NULLs), plus unmatched rows from the right (with left-side NULLs).
-- Filter placement trap: Placing a right-table condition in the WHERE clause (e.g. WHERE o.total_amount > 100) will filter out the NULLs, accidentally converting your LEFT JOIN into an INNER JOIN! Move such conditions to the ON clause if you want to keep unmatched left rows.
