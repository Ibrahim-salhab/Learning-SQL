-- ============================================================
-- Best Practice: Safe Execution of UPDATE and DELETE
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Defensive coding habits to eliminate accidental data loss during record modifications
-- ============================================================


-- ------------------------------------------------------------
-- Risk Pattern: Direct, unverified destructive query
-- ------------------------------------------------------------

-- High Risk: Typo in condition or accidental execution wipes unintended rows
-- DELETE FROM sales.orders WHERE customer_id = 104 AND total_amount = 0;


-- ------------------------------------------------------------
-- Preferred Defensive Workflow: Verify before modifying
-- ------------------------------------------------------------

-- Step 1: Run SELECT using the exact same WHERE clause to verify candidate rows
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    order_status
FROM sales.orders
WHERE customer_id = 104
  AND total_amount = 0;

-- Step 2: Wrap destructive modification inside an explicit transaction
BEGIN TRANSACTION;

    UPDATE sales.orders
    SET order_status = 'Cancelled'
    WHERE customer_id = 104
      AND total_amount = 0;

    -- Step 3: Inspect affected row count (@@ROWCOUNT) before committing
    -- If row count matches expectations:
    COMMIT TRANSACTION;

    -- If row count does NOT match expectations:
    -- ROLLBACK TRANSACTION;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Always test your WHERE clause in a SELECT statement prior to running an UPDATE or DELETE.
-- Utilizing explicit transactions (BEGIN TRAN / COMMIT / ROLLBACK) provides a safety net against unintended operations.
-- Inspect @@ROWCOUNT in SQL Server immediately following an operation to confirm the number of rows modified matches your expectations.
-- SSMS Safety Tip: Some teams keep "SET NOCOUNT OFF" and enable auto-rollback templates for production maintenance scripts.
