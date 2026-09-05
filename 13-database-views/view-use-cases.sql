-- ============================================================
-- Topic: Real-World View Use Cases & Security
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Practical use cases for views: hiding relational complexity, row/column security, localization, and data warehouse abstractions
-- ============================================================


-- ------------------------------------------------------------
-- Use Case 1: Hiding Query Complexity (Denormalization for BI Analysts)
-- ------------------------------------------------------------

CREATE OR ALTER VIEW analytics.vw_order_details_flattened
AS
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    p.product_id,
    p.product_name,
    cat.category_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total
FROM sales.orders AS o
INNER JOIN sales.customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN inventory.products AS p
    ON oi.product_id = p.product_id
INNER JOIN inventory.categories AS cat
    ON p.category_id = cat.category_id;
GO


-- ------------------------------------------------------------
-- Use Case 2: Data Security & Column/Row-Level Masking
-- ------------------------------------------------------------

-- Hiding sensitive columns (e.g., Social Security Numbers, base salary) from general staff
CREATE OR ALTER VIEW hr.vw_public_employee_directory
AS
SELECT
    employee_id,
    first_name,
    last_name,
    email,
    department_id,
    job_title,
    office_location
    -- Omit: salary, ssn, bank_account_number
FROM hr.employees
WHERE is_active = 1; -- Row-level security: only show active personnel
GO


-- ------------------------------------------------------------
-- Use Case 3: Multi-Language / Localized Attribute Aliasing
-- ------------------------------------------------------------

CREATE OR ALTER VIEW localization.vw_products_arabic
AS
SELECT
    product_id AS [رقم_المنتج],
    product_name AS [اسم_المنتج],
    unit_price AS [السعر_الفردي],
    stock_quantity AS [الكمية_المتوفرة]
FROM inventory.products;
GO


-- ------------------------------------------------------------
-- Use Case 4: Data Warehouse Semantic Layer
-- ------------------------------------------------------------

-- Serving conformed dimensions to BI reporting tools without exposing underlying staging tables
CREATE OR ALTER VIEW dwh.vw_dim_customer
AS
SELECT
    customer_id,
    first_name,
    last_name,
    country,
    COALESCE(loyalty_segment, 'Standard') AS customer_tier,
    CAST(registration_date AS DATE) AS member_since_date
FROM staging.cleaned_customers;
GO


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Security Principle of Least Privilege:
--   - Grant end-users `SELECT` permission on the view, while revoking `SELECT` on the underlying physical base tables. This enforces row- and column-level access control without custom application logic.
-- Abstraction & Decoupling:
--   - If the underlying physical schema changes (e.g. splitting a table or renaming a column), updating the view definition preserves compatibility for downstream reports and applications without breaking them.
-- View Performance Caution:
--   - Avoid "nested views" (a view querying another view querying another view). Deep view nesting obstructs the SQL Server query optimizer from generating efficient execution plans.
