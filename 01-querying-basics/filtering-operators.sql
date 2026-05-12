-- ============================================================
-- Topic: Filtering Operators (IN, BETWEEN, AND, OR, NOT)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Advanced row-level filtering using list matching, boundary ranges, and compound boolean logic
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: IN operator with literal lists
-- ------------------------------------------------------------

SELECT
    book_id,
    title,
    genre,
    price
FROM publishing.catalog
WHERE genre IN ('Science Fiction', 'Cyberpunk', 'Fantasy');


-- ------------------------------------------------------------
-- Example 2: BETWEEN operator for inclusive range matching
-- ------------------------------------------------------------

-- Note: BETWEEN is inclusive of both lower and upper bounds
SELECT
    product_id,
    product_name,
    unit_price,
    reorder_level
FROM inventory.items
WHERE unit_price BETWEEN 20.00 AND 75.00;


-- ------------------------------------------------------------
-- Example 3: Compound boolean logic with NOT and parenthetical precedence
-- ------------------------------------------------------------

SELECT
    order_id,
    customer_id,
    order_status,
    total_amount
FROM sales.orders
WHERE order_status NOT IN ('Cancelled', 'Refunded')
  AND (total_amount > 500.00 OR customer_id IN (101, 108, 220));


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- IN is shorthand for multiple OR conditions (e.g., genre = 'A' OR genre = 'B').
-- BETWEEN syntax: expression BETWEEN low_val AND high_val is inclusive (equivalent to >= low_val AND <= high_val).
-- BETWEEN Gotcha with Dates: If comparing a DATETIME with time parts, '2024-01-01' to '2024-01-31' misses times after 00:00:00.000 on Jan 31. Prefer >= '2024-01-01' AND < '2024-02-01'.
-- NOT IN Gotcha with NULLs: If the list in NOT IN contains a single NULL value (e.g. NOT IN (1, 2, NULL)), the entire condition evaluates to UNKNOWN, returning 0 rows! Always filter out NULLs when using NOT IN with subqueries.
-- Logical precedence: NOT is evaluated first, then AND, then OR. Always use parentheses () to ensure predictable evaluation.
