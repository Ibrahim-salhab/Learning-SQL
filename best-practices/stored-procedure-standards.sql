-- ============================================================
-- Best Practice: Production Stored Procedure Standards
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Professional coding standards, defensive settings, and transaction handling in stored procedures
-- ============================================================


-- ------------------------------------------------------------
-- The Gold-Standard Stored Procedure Template
-- ------------------------------------------------------------

CREATE OR ALTER PROCEDURE sales.usp_standard_procedure_template
    @input_id     INT,
    @output_flag  BIT OUTPUT
AS
BEGIN
    -- 1. Standard Session Headers
    SET NOCOUNT ON;          -- Eliminates extra network packets for row counts
    SET XACT_ABORT ON;       -- Immediately terminates batch and rolls back on severe errors

    -- 2. Initialize Output Variables
    SET @output_flag = 0;

    -- 3. Parameter Validation Guard Clauses
    IF @input_id <= 0
    BEGIN
        THROW 50001, 'Invalid input identifier provided.', 1;
        RETURN;
    END;

    -- 4. Structured Transaction & Exception Block
    BEGIN TRY
        BEGIN TRANSACTION;

            -- DML / Business Logic statements here...

            SET @output_flag = 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- 5. Safe Rollback Check
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- 6. Log or Re-throw
        THROW;
    END CATCH;

END;
GO


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Schema Qualification: Always qualify stored procedures and referenced tables with their schema (e.g. `sales.usp_...`, NOT just `usp_...`). This avoids schema resolution cache misses and prevents execution plan fragmentation.
-- Naming Conventions: Avoid the prefix `sp_` for user stored procedures. In SQL Server, `sp_` signifies a system stored procedure located in the `master` database; SQL Server checks `master` first before checking the user database! Use `usp_` (User Stored Procedure).
-- Parameter Sniffing Defensive Tip: If a stored procedure experiences erratic execution times depending on passed parameters, assign parameters to local variables inside the procedure body before filtering (e.g. `DECLARE @local_id INT = @input_id;`).
