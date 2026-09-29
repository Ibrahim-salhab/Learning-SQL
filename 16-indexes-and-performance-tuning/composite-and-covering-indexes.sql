-- ============================================================
-- Topic: Composite Indexes & Covering Indexes with INCLUDE
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Optimizing multi-column predicates and eliminating Key Lookups using covering non-clustered indexes
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Composite Index & Leftmost Prefix Rule
-- ------------------------------------------------------------

-- Key Column Ordering: (department_id, job_title)
CREATE NONCLUSTERED INDEX ix_employees_dept_title
ON hr.employees (department_id, job_title);

-- CAN use index seek (Leftmost column department_id is filtered):
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE department_id = 4;

-- CAN use index seek (Both composite key columns filtered):
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE department_id = 4 AND job_title = 'Senior Developer';

-- CANNOT use index seek (Leading column department_id is missing -> Full Scan):
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE job_title = 'Senior Developer';


-- ------------------------------------------------------------
-- Example 2: Covering Index with INCLUDE Clause
-- ------------------------------------------------------------

-- Solves Key Lookups completely by attaching non-key payload columns only to the LEAF level
CREATE NONCLUSTERED INDEX ix_orders_customer_date_COVERING
ON sales.orders (customer_id, order_date)
INCLUDE (total_amount, order_status);

-- Pure Index Seek (Covering Index):
-- All required columns (customer_id, order_date, total_amount, order_status) are in the index.
-- Zero Key Lookups required!
SELECT
    order_id,
    order_date,
    total_amount,
    order_status
FROM sales.orders
WHERE customer_id = 1042
  AND order_date >= '2024-01-01';


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Leftmost Prefix Rule:
--   - A composite index on (A, B, C) can satisfy searches on:
--     1. A
--     2. A, B
--     3. A, B, C
--   - It CANNOT seek directly on B, C, or (B, C) alone.
--   - Cardinality rule: Place the column with the highest selectivity (most distinct values) first unless range queries dictate otherwise.
-- Covering Index with INCLUDE:
--   - Key columns (in parenthesis) are stored at ALL B-Tree levels (used for navigation and sorting).
--   - INCLUDE columns are stored ONLY at the leaf level (pure payload).
--   - Benefits of INCLUDE over wide composite keys:
--     1. Keeps upper B-Tree levels narrow, allowing more keys per page (shallower tree depth).
--     2. Allows including data types that are illegal in index keys (e.g. VARCHAR(MAX), XML).
