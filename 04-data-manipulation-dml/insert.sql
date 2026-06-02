-- ============================================================
-- Topic: INSERT Statement (DML)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Inserting new rows into a table using explicit values or query projections
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Single-row insert with explicit column list
-- ------------------------------------------------------------

INSERT INTO sales.customers (
    first_name,
    last_name,
    email,
    phone
)
VALUES (
    'Maya',
    'Haddad',
    'maya.haddad@example.com',
    '+962-79-1234567'
);


-- ------------------------------------------------------------
-- Example 2: Multi-row insert (batch inserting)
-- ------------------------------------------------------------

INSERT INTO sales.customers (first_name, last_name, email, phone)
VALUES
    ('Tariq', 'Zaid', 'tariq.zaid@example.com', '+962-79-2345678'),
    ('Rania', 'Khoury', 'rania.khoury@example.com', NULL),
    ('Omar', 'Nasser', 'omar.nasser@example.com', '+962-79-3456789');


-- ------------------------------------------------------------
-- Example 3: INSERT INTO ... SELECT (table-to-table copy)
-- ------------------------------------------------------------

INSERT INTO sales.vip_customers (
    customer_id,
    first_name,
    last_name,
    total_lifetime_spend
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_lifetime_spend
FROM sales.customers AS c
INNER JOIN sales.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING SUM(o.total_amount) >= 5000.00;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Always explicitly specify the target column list. Omitting column names (e.g., INSERT INTO table VALUES (...)) makes code brittle to schema changes.
-- Columns defined with IDENTITY or DEFAULT values should normally be omitted from the column list.
-- Inserting into an IDENTITY column directly will fail unless IDENTITY_INSERT is set to ON for that specific table.
-- T-SQL allows inserting up to 1,000 rows in a single VALUES clause statement.
