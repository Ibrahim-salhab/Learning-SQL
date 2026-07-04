-- ============================================================
-- Topic: Real-World SET Operator Use Cases & Delta Detection
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Practical applications of SET operators for data reconciliation, audit logging, and detecting row-level changes (deltas)
-- ============================================================


-- ------------------------------------------------------------
-- Use Case 1: Combining disparate datasets with unified schema
-- ------------------------------------------------------------

-- Creating a unified transaction activity stream from credit card and bank transfer logs
SELECT
    transaction_id,
    account_id,
    transaction_date,
    amount,
    'Credit Card' AS payment_channel
FROM payments.card_transactions
WHERE transaction_date >= CAST(GETDATE() AS DATE)

UNION ALL

SELECT
    transfer_id AS transaction_id,
    account_id,
    transfer_date AS transaction_date,
    transfer_amount AS amount,
    'Wire Transfer' AS payment_channel
FROM payments.bank_transfers
WHERE transfer_date >= CAST(GETDATE() AS DATE);


-- ------------------------------------------------------------
-- Use Case 2: Delta Detection between daily staging snapshot and production table
-- ------------------------------------------------------------

-- Step A: Detect rows added or updated in staging (Present in Staging, missing from Production)
SELECT
    employee_id,
    department_id,
    job_title,
    salary
FROM staging.daily_employee_feed

EXCEPT

SELECT
    employee_id,
    department_id,
    job_title,
    salary
FROM hr.employees;


-- ------------------------------------------------------------
-- Use Case 3: Bidirectional Delta Detection (New, Deleted, or Altered rows)
-- ------------------------------------------------------------

-- Identify discrepancies in either direction between snapshot yesterday and snapshot today
(
    SELECT product_id, stock_quantity, unit_price, 'Present in Yesterday Only' AS diff_type
    FROM inventory.snapshot_yesterday
    EXCEPT
    SELECT product_id, stock_quantity, unit_price, 'Present in Yesterday Only' AS diff_type
    FROM inventory.snapshot_today
)
UNION ALL
(
    SELECT product_id, stock_quantity, unit_price, 'Present in Today Only' AS diff_type
    FROM inventory.snapshot_today
    EXCEPT
    SELECT product_id, stock_quantity, unit_price, 'Present in Today Only' AS diff_type
    FROM inventory.snapshot_yesterday
);


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Delta detection via EXCEPT evaluates the full row across all projected columns, making it ideal for change detection in ETL / data warehousing pipelines.
-- SET operators treat two rows as identical if all column values match, including matching NULL with NULL.
-- In production ETL pipelines, delta detection with EXCEPT helps determine whether an incoming staging record requires an INSERT, an UPDATE, or can be skipped.
