-- ============================================================
-- Topic: Date and Time Functions
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Extracting date components, calculating date intervals, truncating dates, and validating date expressions
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Date part extraction (DAY, MONTH, YEAR, DATEPART, DATENAME)
-- ------------------------------------------------------------

SELECT
    order_date,
    DAY(order_date) AS order_day_int,
    MONTH(order_date) AS order_month_int,
    YEAR(order_date) AS order_year_int,
    DATEPART(QUARTER, order_date) AS order_quarter,
    DATEPART(WEEK, order_date) AS order_week_of_year,
    DATENAME(MONTH, order_date) AS month_name_string, -- e.g. 'October'
    DATENAME(WEEKDAY, order_date) AS day_of_week_name  -- e.g. 'Tuesday'
FROM sales.orders;


-- ------------------------------------------------------------
-- Example 2: Date arithmetic with DATEADD and DATEDIFF
-- ------------------------------------------------------------

SELECT
    subscription_id,
    start_date,
    end_date,
    -- Add 30 days to start date:
    DATEADD(DAY, 30, start_date) AS grace_period_end,
    -- Add 1 year to start date:
    DATEADD(YEAR, 1, start_date) AS renewal_date,
    -- Calculate difference in days:
    DATEDIFF(DAY, start_date, end_date) AS total_subscription_days,
    -- Difference in completed months:
    DATEDIFF(MONTH, start_date, end_date) AS total_months
FROM billing.subscriptions;


-- ------------------------------------------------------------
-- Example 3: Date truncation and End-of-Month (DATETRUNC & EOMONTH)
-- ------------------------------------------------------------

SELECT
    payment_timestamp,
    -- Truncates timestamp to start of the current month (SQL Server 2022+):
    DATETRUNC(MONTH, payment_timestamp) AS month_beginning,
    -- Truncates timestamp to midnight of the current day:
    DATETRUNC(DAY, payment_timestamp) AS day_beginning,
    -- Returns the last calendar day of the month:
    EOMONTH(payment_timestamp) AS current_month_end,
    -- Returns the last day of the following month (+1 offset):
    EOMONTH(payment_timestamp, 1) AS next_month_end
FROM finance.payments;


-- ------------------------------------------------------------
-- Example 4: Validating date strings with ISDATE
-- ------------------------------------------------------------

SELECT
    raw_date_string,
    ISDATE(raw_date_string) AS is_valid_date -- Returns 1 if valid, 0 if invalid
FROM staging.unvalidated_leads
WHERE ISDATE(raw_date_string) = 1;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Extract Function Comparison:
--   - DAY(), MONTH(), YEAR(): Simple numeric helpers returning INT.
--   - DATEPART(part, date): Highly versatile, returns INT for any datepart (e.g. QUARTER, HOUR, MINUTE).
--   - DATENAME(part, date): Returns NVARCHAR string label (e.g., 'October', 'Friday') localized to current session language.
-- DATEDIFF Gotcha: DATEDIFF counts boundary crossings, NOT completed time periods! DATEDIFF(YEAR, '2024-12-31', '2025-01-01') returns 1, even though only 1 day elapsed.
-- DATETRUNC(datepart, date): Introduced in SQL Server 2022; standardizes resetting time/date granularities.
-- EOMONTH(start_date [, month_to_add]): Ideal for billing cycles and financial period closing dates.
