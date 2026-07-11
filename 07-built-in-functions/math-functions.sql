-- ============================================================
-- Topic: Built-In Numeric & Mathematical Functions
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Mathematical calculations, rounding, bounds checking, and precision handling
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Rounding, ceiling, and flooring
-- ------------------------------------------------------------

SELECT
    shipping_weight,
    ROUND(shipping_weight, 2) AS rounded_2_decimals,
    ROUND(shipping_weight, 0) AS rounded_nearest_integer,
    ROUND(shipping_weight, 1, 1) AS truncated_1_decimal, -- Third argument != 0 truncates instead of rounding
    CEILING(shipping_weight) AS smallest_integer_gte,
    FLOOR(shipping_weight) AS largest_integer_lte
FROM logistics.shipment_packages;


-- ------------------------------------------------------------
-- Example 2: Absolute value, powers, and square roots
-- ------------------------------------------------------------

SELECT
    variance_amount,
    ABS(variance_amount) AS absolute_variance,
    POWER(dimension_length, 2) AS surface_area,
    SQRT(area_sq_meters) AS estimated_side_length
FROM finance.reconciliation_items;


-- ------------------------------------------------------------
-- Example 3: The Integer Division Gotcha & Safe Division
-- ------------------------------------------------------------

-- In SQL Server, dividing an INT by an INT yields an INT (5 / 2 = 2, NOT 2.5)
SELECT
    total_sales_count,
    active_days,
    -- Truncated integer division:
    total_sales_count / active_days AS unsafe_avg_daily_sales,
    -- Accurate decimal division via implicit cast:
    (total_sales_count * 1.0) / active_days AS accurate_avg_daily_sales
FROM sales.monthly_summaries;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Integer Division Trap: In T-SQL, INT / INT returns an INT with the fractional remainder truncated (e.g. 7 / 4 = 1). Multiply by 1.0 or CAST to DECIMAL before dividing.
-- ROUND(numeric_expression, length [, function]):
--   - If the 3rd argument is omitted or 0, it rounds to the nearest value.
--   - If the 3rd argument is any non-zero value, it TRUNCATES without rounding.
-- CEILING() returns the smallest integer greater than or equal to the numeric expression.
-- FLOOR() returns the largest integer less than or equal to the numeric expression.
-- ABS() converts negative numbers to positive values (useful for tolerance comparisons).
