-- ============================================================
-- Topic: Pattern Matching with LIKE & Wildcards
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Searching text strings using wildcard characters and character sets
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Standard wildcards (% for multi-character, _ for single-character)
-- ------------------------------------------------------------

-- % matches zero or more arbitrary characters
SELECT
    customer_id,
    first_name,
    last_name,
    email
FROM sales.customers
WHERE email LIKE '%@gmail.com';

-- _ matches exactly one single character
SELECT
    product_id,
    sku_code,
    description
FROM inventory.products
WHERE sku_code LIKE 'AB-__-XYZ'; -- e.g., 'AB-01-XYZ', 'AB-99-XYZ'


-- ------------------------------------------------------------
-- Example 2: T-SQL specific character set ranges [ ] and exclusions [^ ]
-- ------------------------------------------------------------

-- Matches last names starting with letters A through D
SELECT
    employee_id,
    first_name,
    last_name
FROM hr.employees
WHERE last_name LIKE '[A-D]%';

-- Matches postal codes where the first character is NOT a digit
SELECT
    location_id,
    postal_code,
    city
FROM logistics.warehouses
WHERE postal_code LIKE '[^0-9]%';


-- ------------------------------------------------------------
-- Example 3: Escaping literal wildcard characters
-- ------------------------------------------------------------

-- Find discount codes that literally contain the '%' character
SELECT
    promo_id,
    promo_code,
    discount_rate
FROM sales.promotions
WHERE promo_code LIKE '%!%%' ESCAPE '!';


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- % = 0 or more characters.
-- _ = exactly one character.
-- [charlist] = any single character in the bracketed list or range (T-SQL specific).
-- [^charlist] = any single character NOT in the bracketed list (T-SQL specific).
-- ESCAPE clause: Designates an escape character so wildcards (% or _) can be matched as literal characters.
-- Performance Gotcha: Leading wildcards (e.g. LIKE '%term') cannot use standard B-Tree indexes and force a full table/index scan (non-sargable).
-- Case-sensitivity: LIKE honors the collation of the column/database. Default SQL Server collation (e.g., Latin1_General_CI_AS) is Case-Insensitive (CI).
