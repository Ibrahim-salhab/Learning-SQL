-- ============================================================
-- Topic: Recursive Common Table Expressions (Recursive CTE)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Querying hierarchical structures, organizational reporting trees, and generating dynamic sequences
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Organizational Hierarchy Traversal (Manager -> Employee)
-- ------------------------------------------------------------

;WITH org_hierarchy AS (
    -- 1. ANCHOR MEMBER: Find top-level executive (CEO / Manager is NULL)
    SELECT
        employee_id,
        first_name + ' ' + last_name AS employee_name,
        manager_id,
        job_title,
        0 AS hierarchy_level,
        CAST(first_name + ' ' + last_name AS NVARCHAR(MAX)) AS reporting_path
    FROM hr.employees
    WHERE manager_id IS NULL

    UNION ALL

    -- 2. RECURSIVE MEMBER: Join employee records to their upstream manager in the CTE
    SELECT
        e.employee_id,
        e.first_name + ' ' + e.last_name AS employee_name,
        e.manager_id,
        e.job_title,
        oh.hierarchy_level + 1 AS hierarchy_level,
        CAST(oh.reporting_path + ' -> ' + e.first_name + ' ' + e.last_name AS NVARCHAR(MAX)) AS reporting_path
    FROM hr.employees AS e
    INNER JOIN org_hierarchy AS oh
        ON e.manager_id = oh.employee_id
)
SELECT
    employee_id,
    employee_name,
    job_title,
    hierarchy_level,
    reporting_path
FROM org_hierarchy
ORDER BY hierarchy_level, employee_id;


-- ------------------------------------------------------------
-- Example 2: Generating a Sequential Date Range (Dynamic Calendar)
-- ------------------------------------------------------------

-- Generates all calendar dates between Start Date and End Date without physical tables
DECLARE @start_date DATE = '2024-01-01';
DECLARE @end_date   DATE = '2024-01-15';

;WITH calendar_generator AS (
    -- Anchor: First date in sequence
    SELECT @start_date AS calendar_date

    UNION ALL

    -- Recursive member: Increment date by 1 day until reaching end date
    SELECT DATEADD(DAY, 1, calendar_date)
    FROM calendar_generator
    WHERE calendar_date < @end_date
)
SELECT
    calendar_date,
    DATENAME(WEEKDAY, calendar_date) AS day_of_week_name,
    DATEPART(WEEK, calendar_date) AS week_of_year
FROM calendar_generator
OPTION (MAXRECURSION 1000); -- Protects against infinite loops


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Anatomy of a Recursive CTE:
--   1. Anchor Member: An initial query that returns the starting result set (e.g., roots of trees, start values).
--   2. UNION ALL: The operator binding the anchor to the recursive step (must be UNION ALL; standard UNION is illegal).
--   3. Recursive Member: A query that references the CTE itself, executing iteratively until it returns an empty set.
--   4. Termination Condition: A WHERE clause inside the recursive member that stops recursion.
-- Recursion Safeguards (MAXRECURSION):
--   - SQL Server defaults to a maximum recursion limit of 100 iterations.
--   - If recursion exceeds 100 without terminating, Error 530 is thrown to prevent infinite loops.
--   - Override the limit using query hints: `OPTION (MAXRECURSION n)` where n is 0 to 32,767 (0 = infinite / no limit; use 0 with extreme caution).
-- Data Type Alignment Gotcha:
--   - Anchor and recursive members must match data types strictly. When building string paths, CAST the anchor string to NVARCHAR(MAX) to avoid length mismatch errors.
