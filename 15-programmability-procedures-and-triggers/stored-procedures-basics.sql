-- ============================================================
-- Topic: Stored Procedures Fundamentals & Parameters
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Creating modular procedural routines with input/output parameters, local variables, and multi-query batches
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Stored Procedure with Input & Output Parameters
-- ------------------------------------------------------------

CREATE OR ALTER PROCEDURE sales.usp_get_customer_metrics
    @customer_id         INT,                          -- Input parameter
    @min_order_date      DATE = '2020-01-01',          -- Input parameter with default value
    @total_orders        INT OUTPUT,                   -- Output parameter
    @total_revenue       DECIMAL(12, 2) OUTPUT         -- Output parameter
AS
BEGIN
    -- Professional Standard: Suppresses "x rows affected" messages to save network traffic
    SET NOCOUNT ON;

    -- Local variable declarations
    DECLARE @is_active_customer BIT = 0;

    -- Query 1: Validate customer existence
    SELECT @is_active_customer = is_active
    FROM sales.customers
    WHERE customer_id = @customer_id;

    IF @is_active_customer IS NULL
    BEGIN
        -- Customer not found: Return early with zero values
        SET @total_orders = 0;
        SET @total_revenue = 0.00;
        RETURN;
    END;

    -- Query 2: Aggregate metrics into output parameters
    SELECT
        @total_orders = COUNT(order_id),
        @total_revenue = ISNULL(SUM(total_amount), 0.00)
    FROM sales.orders
    WHERE customer_id = @customer_id
      AND order_date >= @min_order_date;

    -- Query 3: Multi-query output returning the latest 5 orders directly as a resultset
    SELECT TOP (5)
        order_id,
        order_date,
        total_amount,
        order_status
    FROM sales.orders
    WHERE customer_id = @customer_id
    ORDER BY order_date DESC;

END;
GO


-- ------------------------------------------------------------
-- Example 2: Executing Stored Procedure and Receiving Outputs
-- ------------------------------------------------------------

DECLARE @orders_out  INT;
DECLARE @revenue_out DECIMAL(12, 2);

EXEC sales.usp_get_customer_metrics
    @customer_id    = 1042,
    @min_order_date = '2023-01-01',
    @total_orders   = @orders_out OUTPUT,
    @total_revenue  = @revenue_out OUTPUT;

-- Inspect output parameter values:
SELECT
    @orders_out AS customer_total_orders,
    @revenue_out AS customer_total_revenue;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Benefits of Stored Procedures:
--   - Security: Users can be granted EXECUTE permissions without granting direct table read/write access.
--   - Plan Caching: SQL Server caches the compiled execution plan for repeated high-performance executions.
--   - Reduced Network Traffic: Complex multi-step operations execute on the server rather than sending multiple network round-trips.
-- SET NOCOUNT ON: Always include this at the top of every stored procedure body. It prevents DONE_IN_PROC messages from being transmitted to the client for every statement.
-- Parameter Sniffing Gotcha: The compiled execution plan is optimized based on the parameters passed during the FIRST execution. If first parameters are atypical, consider using `WITH RECOMPILE` or local variable copies.
