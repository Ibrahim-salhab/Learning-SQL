-- ============================================================
-- Topic: Real-World CASE Use Cases & Conditional Aggregations
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Practical business applications of CASE: data categorization, value mapping, conditional counting/pivoting, and NULL handling
-- ============================================================


-- ------------------------------------------------------------
-- Use Case 1: Continuous Data Categorization (Age Bucketing)
-- ------------------------------------------------------------

SELECT
    member_id,
    first_name,
    last_name,
    DATEDIFF(YEAR, birth_date, GETDATE()) AS current_age,
    CASE
        WHEN DATEDIFF(YEAR, birth_date, GETDATE()) < 18 THEN 'Minor (< 18)'
        WHEN DATEDIFF(YEAR, birth_date, GETDATE()) BETWEEN 18 AND 35 THEN 'Young Adult (18-35)'
        WHEN DATEDIFF(YEAR, birth_date, GETDATE()) BETWEEN 36 AND 60 THEN 'Middle-Aged (36-60)'
        ELSE 'Senior (60+)'
    END AS demographic_segment
FROM membership.users;


-- ------------------------------------------------------------
-- Use Case 2: Conditional Aggregation (Pivoting rows into columns)
-- ------------------------------------------------------------

-- Summarizing order counts by status in a single consolidated row per department
SELECT
    department_id,
    COUNT(order_id) AS total_orders,
    SUM(CASE WHEN order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN order_status = 'Pending'   THEN 1 ELSE 0 END) AS pending_orders,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN order_status = 'Delivered' THEN total_amount ELSE 0.00 END) AS delivered_revenue
FROM sales.orders
GROUP BY department_id;


-- ------------------------------------------------------------
-- Use Case 3: Custom NULL & Fallback Handling in Reporting
-- ------------------------------------------------------------

SELECT
    project_id,
    project_name,
    completion_date,
    CASE
        WHEN completion_date IS NOT NULL THEN 'Completed'
        WHEN target_deadline < CAST(GETDATE() AS DATE) THEN 'Overdue'
        ELSE 'In Progress'
    END AS project_lifecycle_state
FROM enterprise.projects;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Conditional Aggregation Pattern: Combining SUM(CASE WHEN ... THEN 1 ELSE 0 END) with GROUP BY allows aggregating specific subsets of data into distinct columns without writing multiple queries.
-- Null Sensitivity: In Searched CASE, always use IS NULL or IS NOT NULL; writing WHEN col = NULL will never evaluate to TRUE.
-- Order of When Clauses: Place narrower, more specific conditions before broader ones to ensure correct evaluation order.
