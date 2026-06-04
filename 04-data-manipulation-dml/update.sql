-- ============================================================
-- Topic: UPDATE Statement (DML)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Modifying existing column values in one or more records
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Updating single column with specific condition
-- ------------------------------------------------------------

UPDATE inventory.products
SET unit_price = 49.99
WHERE product_id = 1042;


-- ------------------------------------------------------------
-- Example 2: Updating multiple columns and calculated values
-- ------------------------------------------------------------

UPDATE hr.employees
SET
    salary = salary * 1.08,
    job_title = 'Senior Database Engineer',
    last_review_date = CAST(GETDATE() AS DATE)
WHERE employee_id = 502;


-- ------------------------------------------------------------
-- Example 3: Conditional update using CASE expression
-- ------------------------------------------------------------

UPDATE sales.orders
SET shipping_fee = CASE
    WHEN total_amount >= 100.00 THEN 0.00
    WHEN total_amount >= 50.00  THEN 5.00
    ELSE 12.00
END
WHERE order_status = 'Pending';


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- CRITICAL SAFETY RULE: An UPDATE without a WHERE clause will overwrite EVERY row in the entire table.
-- Best practice workflow: Write and run a SELECT with the exact same WHERE clause first to verify which rows will be affected.
-- In T-SQL, updates can reference columns from other tables via UPDATE ... FROM ... JOIN syntax.
-- To update a column to NULL, specify SET column_name = NULL (column must be nullable).
