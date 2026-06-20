-- ============================================================
-- Topic: CROSS JOIN (Cartesian Product)
-- Author: ibrahim-salhab
-- Dialect: T-SQL (Microsoft SQL Server)
-- Purpose: Producing the Cartesian product of two tables (pairing every row of table A with every row of table B)
-- ============================================================


-- ------------------------------------------------------------
-- Example 1: Generating a product SKU variant matrix
-- ------------------------------------------------------------

-- 4 sizes * 3 colors = 12 total product variant rows
SELECT
    s.size_code,
    s.size_label,
    c.color_code,
    c.color_name,
    'SKU-' + s.size_code + '-' + c.color_code AS generated_variant_sku
FROM catalog.apparel_sizes AS s
CROSS JOIN catalog.apparel_colors AS c;


-- ------------------------------------------------------------
-- Example 2: Generating a complete reporting calendar grid
-- ------------------------------------------------------------

-- Cross joining departments with past 12 months to guarantee zero-fill reporting
SELECT
    d.department_id,
    d.department_name,
    m.month_number,
    m.month_name
FROM hr.departments AS d
CROSS JOIN shared.reporting_months AS m;


-- ------------------------------------------------------------
-- Notes
-- ------------------------------------------------------------

-- Result set size: If Table A has M rows and Table B has N rows, a CROSS JOIN produces exactly M * N rows.
-- CROSS JOIN does NOT have an ON clause because it requires no match condition.
-- Valid business use cases:
--   - Combinatorial generation (sizes x colors, stores x days, questions x answer options)
--   - Generating date/time grids for complete time-series reporting where gaps must show 0.
-- Accidental Cartesian Gotcha: In legacy SQL syntax (FROM table_a, table_b), forgetting the WHERE join condition results in an unintended CROSS JOIN. On large production tables, this can produce billions of rows and exhaust server resources.
