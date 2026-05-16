-- ============================================================
-- Topic: WHERE Clause & Row Filtering
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Filtering table rows based on scalar conditions before grouping or aggregation
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Basic comparison operators
-- ------------------------------------------------------------

SELECT
    book_id,
    title,
    price,
    publication_year
FROM library.books
WHERE price >= 25.00
  AND publication_year <> 2020;


-- ------------------------------------------------------------
-- Example 2: Operator precedence (AND before OR) and grouping with parentheses
-- ------------------------------------------------------------

-- Target: Find active books in Fiction or Science categories
SELECT
    book_id,
    title,
    category,
    is_available
FROM library.books
WHERE (category = 'Fiction' OR category = 'Science')
  AND is_available = 1;


-- ------------------------------------------------------------
-- Example 3: Handling NULL values
-- ------------------------------------------------------------

-- NULL check requires IS NULL or IS NOT NULL
SELECT
    member_id,
    first_name,
    last_name,
    phone_number
FROM library.members
WHERE phone_number IS NOT NULL;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- WHERE filters individual rows before any GROUP BY, aggregation, or SELECT column projection occurs.
-- Precedence rule: NOT evaluates first, followed by AND, then OR. Always use parentheses () when combining AND and OR to avoid logic bugs.
-- Comparison operators: =, <>, !=, <, >, <=, >=. Preferred ANSI standard for "not equal" is <>.
-- NULL Gotcha: In three-valued logic (TRUE, FALSE, UNKNOWN), column = NULL or column <> NULL always evaluates to UNKNOWN, which produces 0 rows. Always use IS NULL or IS NOT NULL.
-- Column aliases defined in SELECT cannot be referenced in the WHERE clause because WHERE executes before SELECT.

-- Updated: refactor comments and formatting in filtering notes
