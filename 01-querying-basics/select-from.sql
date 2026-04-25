-- ============================================================
-- Topic: SELECT & FROM Fundamentals
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Retrieving data, selecting specific columns, applying column aliases, and computed expressions
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Selecting specific columns
-- ------------------------------------------------------------

SELECT
    product_id,
    product_name,
    unit_price,
    stock_quantity
FROM inventory.products;


-- ------------------------------------------------------------
-- Example 2: Column aliasing and computed expressions
-- ------------------------------------------------------------

SELECT
    order_id,
    unit_price,
    quantity,
    unit_price * quantity AS line_total,
    discount_rate,
    (unit_price * quantity) * (1 - discount_rate) AS discounted_total
FROM sales.order_items;


-- ------------------------------------------------------------
-- Example 3: String concatenation and literals
-- ------------------------------------------------------------

SELECT
    employee_id,
    first_name + ' ' + last_name AS full_name,
    job_title,
    'Active' AS employee_status
FROM hr.employees;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- FROM specifies the target table/view; SELECT specifies which columns/expressions to output.
-- Use AS to provide clear, descriptive aliases for computed columns or renamed attributes.
-- Computed columns evaluate on a per-row basis at retrieval time (does not alter stored data).
-- In T-SQL, string concatenation uses + operator (CONCAT() is also available and handles NULL values safely).
-- SQL is case-insensitive for keywords by default, but maintaining UPPERCASE for keywords improves readability.
