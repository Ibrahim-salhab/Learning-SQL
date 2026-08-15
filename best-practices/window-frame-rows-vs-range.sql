-- ============================================================
-- Best Practice: Explicit Window Framing (ROWS vs RANGE)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Preventing unintended tied calculations and avoiding expensive on-disk tempdb spools by using ROWS instead of default RANGE
-- ============================================================


-- ------------------------------------------------------------
-- Less Ideal: Defaulting to implicit RANGE framing
-- ------------------------------------------------------------

-- Risk 1: Performance degradation (forces On-Disk Spool operator in Tempdb)
-- Risk 2: Logic error with ties (tied transaction_dates share the exact same cumulative sum!)
SELECT
    transaction_id,
    transaction_date,
    amount,
    SUM(amount) OVER(
        ORDER BY transaction_date
        -- Implicitly evaluates as: RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS untuned_running_total
FROM banking.daily_ledger;


-- ------------------------------------------------------------
-- Preferred: Explicitly specify ROWS framing
-- ------------------------------------------------------------

-- Executes as an In-Memory Stream Aggregate (drastically faster)
-- Accurately calculates strictly row-by-row regardless of duplicate dates
SELECT
    transaction_id,
    transaction_date,
    amount,
    SUM(amount) OVER(
        ORDER BY transaction_date, transaction_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS optimized_running_total
FROM banking.daily_ledger;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- The Default Frame Trap:
--   - In standard SQL, whenever an ORDER BY clause is present inside an OVER() function without a frame, the default frame is:
--     `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`
--   - RANGE evaluates logically based on value equality. If three rows share the identical transaction_date, all three rows will display the SUM of all three rows combined!
-- Performance Impact in SQL Server:
--   - RANGE framing cannot be processed in-memory as a stream; the engine must create an on-disk worktable in Tempdb to evaluate peer groups.
--   - ROWS framing operates as a pure streaming operator with zero tempdb I/O overhead.
-- Golden Rule: Whenever you write an aggregate window function with ORDER BY, always explicitly append `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`.
