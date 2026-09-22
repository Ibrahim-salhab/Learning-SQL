-- ============================================================
-- Topic: Database Triggers (DML AFTER & INSTEAD OF)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Automating audit trail logging and enforcing complex integrity rules via INSERTED and DELETED pseudo-tables
-- ============================================================


-- ------------------------------------------------------------
-- Example: AFTER UPDATE Audit Log Trigger
-- ------------------------------------------------------------

-- Audit table to capture historical salary modifications
CREATE TABLE hr.employee_salary_audit_log (
    audit_id         INT IDENTITY(1, 1) PRIMARY KEY,
    employee_id      INT            NOT NULL,
    old_salary       DECIMAL(12, 2) NOT NULL,
    new_salary       DECIMAL(12, 2) NOT NULL,
    changed_by_user  NVARCHAR(128)  NOT NULL DEFAULT SUSER_SNAME(),
    changed_at       DATETIME2      NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE OR ALTER TRIGGER hr.trg_after_employee_salary_update
ON hr.employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only proceed if the salary column was actually modified in this statement
    IF NOT UPDATE(salary)
        RETURN;

    -- Compare DELETED (pre-update state) with INSERTED (post-update state)
    INSERT INTO hr.employee_salary_audit_log (
        employee_id,
        old_salary,
        new_salary
    )
    SELECT
        d.employee_id,
        d.salary AS old_salary,
        i.salary AS new_salary
    FROM deleted AS d
    INNER JOIN inserted AS i
        ON d.employee_id = i.employee_id
    WHERE d.salary <> i.salary; -- Capture only actual numeric changes

END;
GO


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- What is a Trigger?
--   - A special type of stored procedure that automatically executes ("fires") in response to a database event (INSERT, UPDATE, DELETE).
-- Pseudo-Tables (INSERTED and DELETED):
--   - INSERT: Contains newly inserted rows in `inserted`. `deleted` is empty.
--   - DELETE: Contains deleted rows in `deleted`. `inserted` is empty.
--   - UPDATE: Evaluates as a DELETE followed by an INSERT. `deleted` contains the old values; `inserted` contains the new values.
-- AFTER vs INSTEAD OF Triggers:
--   - AFTER (FOR) Triggers: Fire AFTER all constraints (foreign keys, checks) have been validated and the action has been written to the transaction log.
--   - INSTEAD OF Triggers: Intercept the DML operation and execute IN PLACE OF the statement (frequently used to make complex multi-table views updatable).
-- Performance Caution:
--   - Triggers execute within the SAME transaction as the calling statement. Slow triggers directly slow down every single INSERT/UPDATE/DELETE.
--   - Set-based processing: NEVER assume a trigger only processes 1 row. Triggers must always join to `inserted`/`deleted` to handle bulk multi-row operations.
