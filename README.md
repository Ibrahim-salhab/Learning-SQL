# SQL Learning Journey & Comprehensive Knowledge Base

Personal notes, production query patterns, advanced database architectures, and end-to-end analytical projects documenting my continuous SQL learning journey.

- **Author:** `ibrahim-salhab`
- **Primary Dialect:** T-SQL (Microsoft SQL Server / SSMS)
- **Objective:** Maintain an enterprise-grade SQL reference guide, performance playbook, and full-stack project portfolio.

---

## Repository Structure

```text
Learning-SQL/
├── 01-querying-basics/
│   ├── select-from.sql                  # Projections, column aliases, expressions
│   ├── distinct.sql                     # Eliminating row duplicates & NULL handling
│   ├── top-rows.sql                     # TOP, PERCENT, WITH TIES (and LIMIT comparison)
│   ├── query-execution-order.sql        # Written order vs Logical engine evaluation
│   ├── where-clause.sql                 # Row filtering, operators, precedence, NULL checks
│   ├── filtering-operators.sql          # IN, BETWEEN, compound boolean logic, NOT
│   ├── pattern-matching-like.sql        # LIKE wildcards (%, _, [], [^]), ESCAPE clause
│   └── order-by.sql                     # Sorting ASC/DESC, multi-column, expressions
│
├── 02-grouping-and-aggregation/
│   ├── group-by.sql                     # Grouping rows, aggregates (COUNT, SUM, AVG, MIN, MAX)
│   └── having.sql                       # Group-level filtering on aggregated results
│
├── 03-data-definition-ddl/
│   ├── create-table.sql                 # CREATE TABLE, IDENTITY, data types, constraints
│   ├── alter-table.sql                  # ADD, ALTER, DROP columns & constraints
│   └── drop-table.sql                   # DROP TABLE, IF EXISTS, referential dependencies
│
├── 04-data-manipulation-dml/
│   ├── insert.sql                       # Single-row, multi-row, and INSERT INTO SELECT
│   ├── update.sql                       # Row updates, expressions, CASE logic
│   └── delete.sql                       # Row deletion with WHERE, DELETE vs TRUNCATE
│
├── 05-joins/
│   ├── inner-join.sql                   # Matching rows, composite join keys, table aliases
│   ├── outer-joins.sql                  # LEFT, RIGHT, FULL OUTER joins & unmatched rows
│   ├── anti-joins.sql                   # LEFT, RIGHT, and FULL anti-joins (WHERE IS NULL)
│   ├── cross-join.sql                   # Cartesian products, SKU matrix generation, date grids
│   └── multi-table-joins.sql            # 3+ table chains, junction tables, join order
│
├── 06-set-operators/
│   ├── union-and-union-all.sql          # Vertical rowset concatenation & deduplication
│   ├── intersect-and-except.sql         # Set intersection & set difference / subtraction
│   └── delta-detection-use-cases.sql    # Data reconciliation, audit logs, staging deltas
│
├── 07-built-in-functions/
│   ├── string-functions.sql             # CONCAT, TRIM, REPLACE, LEN vs DATALENGTH, SUBSTRING
│   ├── math-functions.sql               # ROUND, CEILING, FLOOR, ABS, integer division gotcha
│   ├── date-and-time-functions.sql      # DAY/MONTH/YEAR, DATEPART, DATETRUNC, EOMONTH, DATEDIFF
│   └── type-casting-and-formatting.sql  # CAST, CONVERT (styles), FORMAT (cultures)
│
├── 08-null-handling/
│   ├── coalesce-and-isnull.sql          # ISNULL vs COALESCE, data type truncation trap
│   ├── null-in-operations.sql           # NULL in math, joins, sorting, and aggregations
│   └── nullif-and-blank-handling.sql    # Divide-by-zero defense, NULL vs '' vs ' ', sanitization
│
├── 09-conditional-logic/
│   ├── case-expressions.sql             # Simple vs Searched CASE, evaluation rules
│   └── case-use-cases.sql               # Categorization, value mapping, conditional aggregation
│
├── 10-window-functions/
│   ├── window-functions-basics.sql      # OVER() clause, PARTITION BY, ORDER BY, Framing
│   ├── window-aggregates.sql            # Running totals, moving averages, rolling bounds
│   ├── ranking-functions.sql            # ROW_NUMBER, RANK, DENSE_RANK, deduplication, Top-N
│   ├── distribution-functions.sql       # NTILE bucketing, CUME_DIST, PERCENT_RANK
│   └── value-functions.sql              # LEAD, LAG, FIRST_VALUE, LAST_VALUE, MoM growth
│
├── 11-subqueries/
│   ├── subquery-basics-and-types.sql    # Scalar, multi-row, table-valued (SELECT/FROM/WHERE)
│   ├── set-comparison-subqueries.sql    # IN, ANY/SOME, ALL operators
│   └── correlated-subqueries-and-exists.sql # Correlated execution, EXISTS vs NOT EXISTS
│
├── 12-common-table-expressions-cte/
│   ├── cte-fundamentals.sql             # Standalone, multiple, chained/nested CTE patterns
│   └── recursive-cte.sql                # Anchor/recursive members, hierarchies, date sequences
│
├── 13-database-views/
│   ├── views-fundamentals.sql           # 3-Level schema architecture, CREATE/ALTER/DROP
│   └── view-use-cases.sql               # Complexity masking, row/column security, localization
│
├── 14-tables-and-storage-strategies/
│   ├── select-into-ctas.sql             # CTAS equivalent, table snapshots, minimal logging
│   ├── temporary-tables.sql             # #local_temp, ##global_temp, @table variables
│   └── storage-constructs-comparison.sql# Comprehensive matrix: Tables vs Views vs CTEs vs Temps
│
├── 15-programmability-procedures-and-triggers/
│   ├── stored-procedures-basics.sql     # Input/Output parameters, local variables, execution
│   ├── control-flow-and-error-handling.sql # IF/ELSE, TRY...CATCH, THROW, @@TRANCOUNT
│   └── database-triggers.sql            # AFTER & INSTEAD OF triggers, INSERTED/DELETED tables
│
├── 16-indexes-and-performance-tuning/
│   ├── index-types-and-b-trees.sql      # Heaps, Clustered vs Nonclustered, Key lookups
│   ├── composite-and-covering-indexes.sql # Leftmost prefix rule, covering indexes with INCLUDE
│   ├── specialized-indexes.sql          # Filtered indexes, Unique constraints, Columnstore (CCI)
│   ├── index-maintenance-and-monitoring.sql # DMVs: usage stats, missing indexes, REBUILD/REORGANIZE
│   ├── execution-plans-and-query-hints.sql # Join physical operators, plan hints, WITH (NOLOCK)
│   ├── table-partitioning.sql           # Partition functions, schemes, partition elimination
│   └── comprehensive-tuning-checklist.sql # Full query tuning & optimization cheat sheet
│
├── 17-ai-assisted-sql-development/
│   └── prompt-engineering-for-sql.md    # 5-part prompting framework, query tuning prompts
│
├── 18-data-warehouse-etl-project/
│   ├── 01-architecture-and-ddl/
│   │   ├── bronze-layer-ddl.sql         # Raw permissive staging tables
│   │   ├── silver-layer-ddl.sql         # Cleaned, conformed relational entities
│   │   └── gold-layer-star-schema.sql   # Kimball Star Schema (Dim_Customers, Products, Fact_Sales)
│   ├── 02-etl-pipelines/
│   │   ├── sp-load-bronze.sql           # Ingestion stored procedure
│   │   ├── sp-load-silver.sql           # Cleansing, type casting & deduplication pipeline
│   │   └── sp-load-gold.sql             # Surrogate key resolution & dimensional load
│   └── 03-data-catalog/
│       └── data-catalog-and-lineage.md  # Data dictionary, architecture diagrams & lineage
│
├── 19-exploratory-data-analysis-project/
│   ├── 01-data-exploration/
│   │   └── database-and-dimension-exploration.sql # Dimensions vs Measures, completeness
│   ├── 02-analytical-deep-dives/
│   │   ├── magnitude-and-ranking-analysis.sql # Top revenue drivers & Pareto (80/20) analysis
│   │   ├── time-series-and-cumulative-analysis.sql # MoM variance & YTD cumulative trends
│   │   └── segmentation-and-part-to-whole.sql # RFM customer segmentation & contribution %
│   └── 03-executive-reporting/
│       ├── customer-insights-report.sql # 360-degree customer cohort view
│       └── product-performance-report.sql # Product velocity & category share view
│
├── best-practices/
│   ├── avoid-select-star.sql            # Explicit columns vs wildcard projection
│   ├── safe-updates-and-deletes.sql     # Verification workflows, transaction safeguards
│   ├── where-vs-having.sql              # Early row filtering vs aggregate group filtering
│   ├── join-selection-guide.sql         # Choosing the right join type & indexing foreign keys
│   ├── union-vs-union-all.sql           # Defaulting to UNION ALL for execution efficiency
│   ├── sargable-queries-and-functions.sql # SARGability: preserving B-Tree index seeks
│   ├── null-defensive-patterns.sql      # Safe division, zero handling, NOT IN / NULL trap
│   ├── window-frame-rows-vs-range.sql   # ROWS vs RANGE: avoiding tempdb spooling on ties
│   ├── exists-vs-in-subqueries.sql      # Short-circuiting & three-valued logic immunity
│   ├── cte-vs-subquery-vs-temp-table.sql# Decision guide: CTE vs derived table vs #temp
│   ├── view-design-and-security.sql     # Single-layer views, SCHEMABINDING & security
│   ├── stored-procedure-standards.sql   # Gold standard procedure template & SET NOCOUNT ON
│   └── indexing-strategy-rules.sql      # The 5 Golden Rules of indexing & write overhead
│
└── README.md
```

---

## Master Progress Checklist (100% Complete)

- [x] **01. Foundations & Querying:** `SELECT`, `FROM`, `DISTINCT`, `TOP`, `ORDER BY`, `WHERE`, `IN`, `BETWEEN`, `LIKE`, Execution Order
- [x] **02. Aggregations & Grouping:** `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- [x] **03. DDL Operations:** `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`, Constraints, `IDENTITY`
- [x] **04. DML Operations:** `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`
- [x] **05. Relational Joins:** `INNER`, `LEFT`, `RIGHT`, `FULL OUTER`, `ANTI JOIN`, `CROSS JOIN`, Multi-table chains
- [x] **06. SET Operators:** `UNION`, `UNION ALL`, `INTERSECT`, `EXCEPT`, Delta Detection
- [x] **07. Built-in Functions:** Strings, Math, Date/Time, `CAST`, `CONVERT`, `FORMAT`
- [x] **08. NULL Handling:** `ISNULL`, `COALESCE`, `NULLIF`, Math Propagation, Three-Valued Logic
- [x] **09. Conditional Logic:** Simple & Searched `CASE`, Conditional Aggregation
- [x] **10. Window Functions:** Analytics, Aggregates, `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`, `LEAD`/`LAG`, `FIRST_VALUE`/`LAST_VALUE`
- [x] **11. Subqueries:** Scalar, Multi-row, Table-Valued, Correlated, `EXISTS`, `ANY`/`ALL`
- [x] **12. Common Table Expressions:** Standalone, Multiple, Chained/Nested, Recursive CTEs
- [x] **13. Database Views:** 3-Level Architecture, Query Expansion, Security Masking, Localization
- [x] **14. Storage Strategies:** `SELECT INTO` (CTAS), `#temp` tables, Table Variables `@table`
- [x] **15. Programmability:** Stored Procedures, Input/Output Parameters, `TRY...CATCH`, `THROW`, DML Triggers
- [x] **16. Performance & Indexing:** Heaps, Clustered/Nonclustered B-Trees, Covering Indexes with `INCLUDE`, Columnstore (CCI), DMVs, Partitioning, Execution Plans
- [x] **17. AI & SQL:** Prompt engineering framework, query tuning, and code review prompts
- [x] **18. Data Warehouse Project:** Complete Medallion Architecture (Bronze, Silver, Gold ETL pipeline)
- [x] **19. Business Analytics Project:** Full Exploratory Data Analysis (EDA) suite, RFM segmentation, and Executive Views
- [x] **Best Practices Collection:** 13 dedicated, battle-tested optimization guides

---

## Acknowledgments & Recommended Courses

This repository represents my continuous journey in mastering database engineering, advanced SQL programming, query optimization, and data warehousing.

Throughout this learning path, one foundational course that provided immense practical depth, structured clarity, and real-world database design insights is:

- **[The Complete SQL Bootcamp (30 Hours): Go from Zero to Hero](https://www.udemy.com/course/the-complete-sql-bootcamp-30-hours-go-from-zero-to-hero)** on Udemy.

It served as an outstanding reference and catalyst for structuring many of the advanced scenarios, ETL pipelines, and performance concepts implemented across this knowledge base.
