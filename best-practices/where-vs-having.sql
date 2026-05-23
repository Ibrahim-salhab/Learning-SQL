-- ============================================================
-- Best Practice: WHERE vs HAVING Filtering Placement
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Placing filter conditions in the correct clause to maximize performance and query efficiency
-- ============================================================


-- ------------------------------------------------------------
-- Less Ideal: Filtering row-level predicates in HAVING
-- ------------------------------------------------------------

-- Forces database to aggregate ALL departments first before discarding inactive ones
SELECT
    department_id,
    AVG(salary) AS avg_salary
FROM hr.employees
GROUP BY department_id, is_active
HAVING is_active = 1
   AND AVG(salary) > 60000;


-- ------------------------------------------------------------
-- Preferred: Filter row attributes in WHERE, filter aggregates in HAVING
-- ------------------------------------------------------------

-- Filters raw rows BEFORE grouping, drastically reducing workload on grouping engine
SELECT
    department_id,
    AVG(salary) AS avg_salary
FROM hr.employees
WHERE is_active = 1
GROUP BY department_id
HAVING AVG(salary) > 60000;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Execution efficiency: WHERE executes before GROUP BY; HAVING executes after GROUP BY.
-- Rule of thumb: If a condition does NOT involve an aggregate function (e.g., SUM, COUNT, AVG), it belongs in the WHERE clause.
-- Reducing the number of input rows via WHERE speeds up sorting, hashing, and memory allocation during the aggregation phase.
-- Use HAVING exclusively for conditions evaluated against aggregated results (e.g., COUNT(*) >= 5).
