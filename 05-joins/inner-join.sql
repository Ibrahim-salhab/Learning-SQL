-- ============================================================
-- Topic: INNER JOIN
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Combining rows from two or more tables where matching keys satisfy the join predicate
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Basic two-table INNER JOIN with table aliases
-- ------------------------------------------------------------

SELECT
    o.order_id,
    o.order_date,
    o.total_amount,
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    c.email
FROM sales.orders AS o
INNER JOIN sales.customers AS c
    ON o.customer_id = c.customer_id;


-- ------------------------------------------------------------
-- Example 2: INNER JOIN with multiple join conditions (Composite Key)
-- ------------------------------------------------------------

SELECT
    inv.warehouse_id,
    inv.product_id,
    inv.quantity_on_hand,
    p.reorder_point,
    p.safety_stock
FROM inventory.warehouse_inventory AS inv
INNER JOIN inventory.product_reorder_rules AS p
    ON inv.warehouse_id = p.warehouse_id
   AND inv.product_id = p.product_id;


-- ------------------------------------------------------------
-- Example 3: INNER JOIN combined with row filtering and sorting
-- ------------------------------------------------------------

SELECT
    b.title,
    b.price,
    p.publisher_name,
    p.country
FROM library.books AS b
INNER JOIN library.publishers AS p
    ON b.publisher_id = p.publisher_id
WHERE b.price > 30.00
  AND p.country = 'United Kingdom'
ORDER BY b.price DESC;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- INNER JOIN returns ONLY rows where the ON predicate evaluates to TRUE in both tables.
-- If a row in Table A has no matching key in Table B, it is excluded from the final result set.
-- Always use explicit table aliases (e.g., AS o, AS c) and qualify every column name to prevent ambiguous column reference errors.
-- Avoid legacy comma-joins (e.g. FROM A, B WHERE A.id = B.id); explicit ANSI JOIN syntax separates join conditions from row filters.
-- If the join column in either table contains NULL, that row will NOT match because NULL = NULL evaluates to UNKNOWN.

-- Updated: refactor join aliases for readability
