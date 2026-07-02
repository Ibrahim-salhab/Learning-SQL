-- ============================================================
-- Topic: SET Operators - INTERSECT & EXCEPT
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Finding common rows across queries (INTERSECT) or rows unique to the first query (EXCEPT)
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: INTERSECT (Set Intersection)
-- ------------------------------------------------------------

-- Target: Find customers who placed orders in BOTH 2023 AND 2024
SELECT
    customer_id
FROM sales.orders
WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01'

INTERSECT

SELECT
    customer_id
FROM sales.orders
WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01';


-- ------------------------------------------------------------
-- Example 2: EXCEPT (Set Difference / Subtraction)
-- ------------------------------------------------------------

-- Target: Find products in the general catalog that have NEVER been ordered
SELECT
    product_id
FROM catalog.products

EXCEPT

SELECT
    product_id
FROM sales.order_items;


-- ------------------------------------------------------------
-- Example 3: Order dependence in EXCEPT
-- ------------------------------------------------------------

-- Query A EXCEPT Query B != Query B EXCEPT Query A
-- Students registered in Spring 2024 but NOT Fall 2024
SELECT student_id, course_id FROM academic.enrollments WHERE semester = 'Spring 2024'
EXCEPT
SELECT student_id, course_id FROM academic.enrollments WHERE semester = 'Fall 2024';


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- INTERSECT returns only distinct rows that exist in BOTH the left and right query results.
-- EXCEPT returns distinct rows that exist in the FIRST query but do NOT exist in the second query.
-- Asymmetry: INTERSECT is commutative (A INTERSECT B = B INTERSECT A). EXCEPT is NOT commutative (A EXCEPT B != B EXCEPT A).
-- NULL Handling: Unlike standard comparison operators (=), SET operators treat NULL values as equal to each other when deduplicating and matching rows.
-- Dialect Note: Oracle uses MINUS instead of EXCEPT. T-SQL, PostgreSQL, and SQLite use EXCEPT.
