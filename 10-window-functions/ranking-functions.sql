-- ============================================================
-- Topic: Window Ranking Functions (ROW_NUMBER, RANK, DENSE_RANK)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Ranking rows within partitions, handling ties, Top-N filtering, and row deduplication
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Comparison of ROW_NUMBER vs RANK vs DENSE_RANK
-- ------------------------------------------------------------

-- Note the differences when salaries are tied:
SELECT
    employee_id,
    first_name + ' ' + last_name AS employee_name,
    department_id,
    salary,
    -- Strictly sequential, no ties (1, 2, 3, 4, 5...)
    ROW_NUMBER() OVER(PARTITION BY department_id ORDER BY salary DESC) AS row_num,
    -- Tied values share rank; skips subsequent ranks (e.g. 1, 2, 2, 4...)
    RANK() OVER(PARTITION BY department_id ORDER BY salary DESC) AS rank_with_gaps,
    -- Tied values share rank; no gaps in sequence (e.g. 1, 2, 2, 3...)
    DENSE_RANK() OVER(PARTITION BY department_id ORDER BY salary DESC) AS dense_rank_continuous
FROM hr.employees;


-- ------------------------------------------------------------
-- Example 2: Use Case - Top-N Analysis (Top 2 highest revenue products per category)
-- ------------------------------------------------------------

-- Window functions cannot go in WHERE, so we wrap the ranking in a CTE or Subquery:
WITH ranked_catalog AS (
    SELECT
        category_id,
        product_id,
        product_name,
        unit_price,
        DENSE_RANK() OVER(PARTITION BY category_id ORDER BY unit_price DESC) AS price_rank
    FROM inventory.products
)
SELECT
    category_id,
    product_id,
    product_name,
    unit_price,
    price_rank
FROM ranked_catalog
WHERE price_rank <= 2
ORDER BY category_id, price_rank;


-- ------------------------------------------------------------
-- Example 3: Use Case - Identifying and Deduplicating Staging Records
-- ------------------------------------------------------------

-- Identifying duplicates by natural key (email) keeping only the latest updated record
WITH ranked_duplicates AS (
    SELECT
        lead_id,
        email,
        phone,
        submitted_at,
        ROW_NUMBER() OVER(
            PARTITION BY email
            ORDER BY submitted_at DESC, lead_id DESC
        ) AS duplicate_sequence
    FROM staging.web_leads
)
SELECT
    lead_id,
    email,
    phone,
    submitted_at
FROM ranked_duplicates
WHERE duplicate_sequence = 1; -- Keep newest; filter out duplicate_sequence > 1


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Ranking Differences Summary:
--   - ROW_NUMBER(): Always generates unique consecutive integers (1, 2, 3...). Arbitrary tie-breaker if ORDER BY has duplicate values.
--   - RANK(): Gives identical rank to ties, then SKIPS rank values for the number of ties (e.g., 1, 2, 2, 4).
--   - DENSE_RANK(): Gives identical rank to ties, but does NOT skip numbers (e.g., 1, 2, 2, 3).
-- Filtering Rule: Window functions cannot be directly filtered in WHERE (e.g., WHERE ROW_NUMBER() = 1 is invalid). Always wrap the window function inside a CTE or Derived Table first.
-- Deduplication Pattern:
--   `DELETE FROM cte WHERE duplicate_sequence > 1;` in T-SQL directly removes duplicate physical rows using CTE references.
