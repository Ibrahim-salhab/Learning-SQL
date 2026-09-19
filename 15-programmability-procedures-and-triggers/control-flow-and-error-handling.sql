-- ============================================================
-- Topic: Procedural Control Flow & Error Handling (TRY...CATCH)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Branching logic with IF/ELSE, transactional integrity, and enterprise error handling with TRY/CATCH and THROW
-- ============================================================


-- ------------------------------------------------------------
-- Example: Financial Account Transfer Procedure with Full Error Handling
-- ------------------------------------------------------------

CREATE OR ALTER PROCEDURE banking.usp_transfer_funds
    @source_account_id INT,
    @target_account_id INT,
    @transfer_amount   DECIMAL(12, 2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- Automatically rolls back transaction on fatal errors

    -- 1. Input Validation with IF/ELSE
    IF @transfer_amount <= 0.00
    BEGIN
        THROW 50001, 'Transfer amount must be strictly greater than zero.', 1;
        RETURN;
    END;

    IF @source_account_id = @target_account_id
    BEGIN
        THROW 50002, 'Source and target account IDs cannot be identical.', 1;
        RETURN;
    END;

    -- 2. Structured Error Handling Block
    BEGIN TRY
        BEGIN TRANSACTION;

            -- Check for sufficient funds
            DECLARE @current_balance DECIMAL(12, 2);

            SELECT @current_balance = balance
            FROM banking.accounts WITH (UPDLOCK, ROWLOCK)
            WHERE account_id = @source_account_id;

            IF @current_balance IS NULL
            BEGIN
                THROW 50003, 'Source account does not exist.', 1;
            END;

            IF @current_balance < @transfer_amount
            BEGIN
                THROW 50004, 'Insufficient funds for requested transfer.', 1;
            END;

            -- Deduct from Source Account
            UPDATE banking.accounts
            SET balance = balance - @transfer_amount
            WHERE account_id = @source_account_id;

            -- Credit Target Account
            UPDATE banking.accounts
            SET balance = balance + @transfer_amount
            WHERE account_id = @target_account_id;

            -- Audit log insertion
            INSERT INTO banking.transaction_ledger (
                source_id,
                target_id,
                amount,
                transferred_at
            )
            VALUES (
                @source_account_id,
                @target_account_id,
                @transfer_amount,
                SYSDATETIME()
            );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Ensure active transaction is rolled back on any caught error
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        -- Capture detailed error diagnostic metadata
        DECLARE @err_num  INT            = ERROR_NUMBER();
        DECLARE @err_msg  NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @err_line INT            = ERROR_LINE();

        -- Re-throw the error to the calling client application
        THROW;
    END CATCH;

END;
GO


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Structured Error Functions (Available exclusively within a CATCH block):
--   - ERROR_NUMBER(): Returns the internal numeric code of the error.
--   - ERROR_MESSAGE(): Returns the complete text message of the error.
--   - ERROR_SEVERITY(): Returns severity level (11-16 are standard user-correctable errors).
--   - ERROR_STATE(): Returns the state number of the error.
--   - ERROR_LINE(): Returns the exact physical line number where failure occurred.
-- THROW vs RAISERROR:
--   - `THROW;` without arguments re-raises the original caught exception, preserving the exact stack trace.
--   - THROW enforces modern error standards and honors `SET XACT_ABORT ON` properly, making it the preferred standard over legacy RAISERROR.
-- Transaction Counter (@@TRANCOUNT):
--   - Always check `IF @@TRANCOUNT > 0` before calling `ROLLBACK TRANSACTION` in CATCH blocks to prevent Msg 3903 ("The ROLLBACK TRANSACTION request has no corresponding BEGIN TRANSACTION").
