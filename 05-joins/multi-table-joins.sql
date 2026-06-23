-- ============================================================
-- Topic: Multi-Table Joins & Junction Tables
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Joining three or more tables across primary/foreign key relationships and many-to-many bridge tables
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Three-table relational join (Customer -> Orders -> OrderItems)
-- ------------------------------------------------------------

SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    o.order_id,
    o.order_date,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS item_subtotal
FROM sales.customers AS c
INNER JOIN sales.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';


-- ------------------------------------------------------------
-- Example 2: Resolving a Many-to-Many relationship via Junction Table
-- ------------------------------------------------------------

-- Students <-> StudentCourses (Junction) <-> Courses
SELECT
    s.student_id,
    s.first_name + ' ' + s.last_name AS student_name,
    c.course_code,
    c.course_name,
    c.credit_hours,
    sc.semester,
    sc.grade
FROM academic.students AS s
INNER JOIN academic.student_courses AS sc
    ON s.student_id = sc.student_id
INNER JOIN academic.courses AS c
    ON sc.course_id = c.course_id
WHERE sc.semester = 'Fall 2024';


-- ------------------------------------------------------------
-- Example 3: Mixing INNER and LEFT joins safely
-- ------------------------------------------------------------

-- Patient visit with mandatory doctor and optional insurance claim
SELECT
    v.visit_id,
    v.visit_date,
    p.patient_name,
    d.doctor_name,
    d.specialty,
    ins.claim_status,
    ins.approved_amount
FROM clinic.patient_visits AS v
INNER JOIN clinic.patients AS p
    ON v.patient_id = p.patient_id
INNER JOIN clinic.doctors AS d
    ON v.doctor_id = d.doctor_id
LEFT JOIN insurance.claims AS ins
    ON v.visit_id = ins.visit_id;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- In relational theory, joins are commutative, but in query design, order matters for readability and OUTER join semantics.
-- Order matters when mixing INNER and LEFT joins: If an INNER JOIN is placed after a LEFT JOIN referencing the right table, it will filter out NULL rows and convert the earlier LEFT JOIN into an INNER JOIN.
-- Every table joined introduces an ON clause condition; verify all join keys link to the appropriate upstream table.
-- Many-to-Many (N:M) relationships always require a junction (bridge) table with two foreign keys linking the parent entities.
