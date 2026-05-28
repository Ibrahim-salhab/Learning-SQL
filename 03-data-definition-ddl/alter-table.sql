-- ============================================================
-- Topic: ALTER TABLE Operations (DDL)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Modifying existing table structure, columns, and constraints without recreating the table
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Adding a new column
-- ------------------------------------------------------------

ALTER TABLE sales.customers
ADD loyalty_tier VARCHAR(20) NULL;


-- ------------------------------------------------------------
-- Example 2: Modifying an existing column data type or nullability
-- ------------------------------------------------------------

-- Expanding phone number length and maintaining NULL allowance
ALTER TABLE sales.customers
ALTER COLUMN phone VARCHAR(30) NULL;


-- ------------------------------------------------------------
-- Example 3: Adding a constraint to an existing table
-- ------------------------------------------------------------

ALTER TABLE sales.customers
ADD CONSTRAINT chk_customers_loyalty_tier
    CHECK (loyalty_tier IN ('Bronze', 'Silver', 'Gold', 'Platinum') OR loyalty_tier IS NULL);


-- ------------------------------------------------------------
-- Example 4: Dropping a column and constraint
-- ------------------------------------------------------------

-- First drop dependent constraint, then drop column
ALTER TABLE sales.customers
DROP CONSTRAINT chk_customers_loyalty_tier;

ALTER TABLE sales.customers
DROP COLUMN loyalty_tier;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Adding a NOT NULL column to a table with existing rows will fail unless a DEFAULT constraint is provided.
-- Modifying column data types (ALTER COLUMN in SQL Server):
--   - Narrowing a data type (e.g., VARCHAR(50) -> VARCHAR(20)) fails if existing data exceeds the new size.
--   - Dialect syntax: SQL Server uses ALTER TABLE tbl ALTER COLUMN col TYPE; PostgreSQL uses ALTER TABLE tbl ALTER COLUMN col TYPE; MySQL uses ALTER TABLE tbl MODIFY COLUMN col TYPE.
-- You cannot drop a column that is referenced by an index, primary key, foreign key, or check constraint until the constraint is dropped first.
