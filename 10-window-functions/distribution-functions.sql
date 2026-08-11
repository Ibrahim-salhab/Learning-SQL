-- ============================================================
-- Topic: Window Distribution Functions (NTILE, CUME_DIST, PERCENT_RANK)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Dividing result sets into statistical buckets, calculating cumulative distributions, and relative rank percentiles
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: NTILE for Bucketing and Quartiles
-- ------------------------------------------------------------

-- Segmenting customers into 4 spending quartiles (1 = Lowest 25%, 4 = Top 25%)
SELECT
    customer_id,
    annual_spend,
    NTILE(4) OVER(ORDER BY annual_spend ASC) AS spending_quartile,
    NTILE(10) OVER(ORDER BY annual_spend ASC) AS spending_decile
FROM sales.customer_summaries;


-- ------------------------------------------------------------
-- Example 2: CUME_DIST vs PERCENT_RANK
-- ------------------------------------------------------------

-- Student test scores across university courses
SELECT
    course_id,
    student_id,
    exam_score,
    -- CUME_DIST: Cumulative distribution (Number of rows with values <= current row / Total rows)
    -- Range: 0 < CUME_DIST <= 1.0 (e.g., 0.80 means 80% of students scored at or below this score)
    CUME_DIST() OVER(PARTITION BY course_id ORDER BY exam_score ASC) AS cumulative_distribution,
    -- PERCENT_RANK: Relative rank of a row within partition: (Rank - 1) / (Total rows - 1)
    -- Range: 0 <= PERCENT_RANK <= 1.0 (Top score is 1.0, lowest score is 0.0)
    PERCENT_RANK() OVER(PARTITION BY course_id ORDER BY exam_score ASC) AS relative_percent_rank
FROM academic.exam_results;


-- ------------------------------------------------------------
-- Example 3: Segmenting Workloads for Parallel Processing
-- ------------------------------------------------------------

-- Splitting 10,000 batch jobs evenly across 4 worker threads
SELECT
    job_id,
    job_type,
    created_at,
    NTILE(4) OVER(ORDER BY job_id) AS assigned_worker_thread_id
FROM processing.batch_queue;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- NTILE(n) Bucketing Logic:
--   - Divides partition rows as evenly as possible into n groups.
--   - If rows are not evenly divisible, larger groups come FIRST (e.g. 10 rows in NTILE(4) gives group sizes: 3, 3, 2, 2).
-- CUME_DIST() (Cumulative Distribution):
--   - Formula: (Count of rows with value <= current row value) / (Total rows in partition).
--   - Tied values always produce identical CUME_DIST results (evaluated at the highest tie position).
-- PERCENT_RANK() (Relative Percentile):
--   - Formula: (RANK - 1) / (Total rows in partition - 1).
--   - The lowest value in any partition always receives a PERCENT_RANK of 0.0.
