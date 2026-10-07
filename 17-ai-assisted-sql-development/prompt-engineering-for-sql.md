# AI-Assisted SQL Engineering & Prompt Framework

A practical guide for SQL developers and database administrators on leveraging Large Language Models (LLMs like ChatGPT and GitHub Copilot) for code generation, query tuning, schema design, and debugging.

---

## 1. ChatGPT vs. GitHub Copilot for SQL

| Feature / Dimension | GitHub Copilot | ChatGPT / Claude |
| :--- | :--- | :--- |
| **Primary Environment** | Inside IDE (VS Code, Azure Data Studio, SSMS extensions) | Dedicated Chat / Browser Interface |
| **Context Window** | Active file, open tabs, nearby comments | Full conversation history, pasted schemas, execution plans |
| **Best Used For** | Real-time query autocomplete, typing boilerplate, fast inline functions | Architecture design, complex query debugging, refactoring, index strategies |
| **Execution Plan Analysis** | Limited | Exceptional (interprets XML / text execution plans) |

---

## 2. The 5-Part Prompt Engineering Framework for SQL

When asking an AI model to write or optimize SQL, use this high-yield structured format:

```text
1. ROLE & DIALECT:
   "You are an expert Microsoft SQL Server (T-SQL) Database Administrator."

2. CONTEXT & SCHEMA:
   Provide explicit DDL, table relationships, primary/foreign keys, and data types:
   "Here is the schema for our sales system:
    CREATE TABLE sales.orders (order_id INT PRIMARY KEY, customer_id INT, total_amount DECIMAL(10,2), order_date DATE);"

3. GOAL & BUSINESS LOGIC:
   "Write a query that calculates a 30-day rolling average of total_amount per customer."

4. CONSTRAINTS & EDGE CASES:
   "Must be SARGable, must use explicit ROWS framing for window functions, and must safely handle customers with 0 orders using COALESCE."

5. OUTPUT FORMAT:
   "Return clean, formatted SQL with uppercase keywords and concise bulleted comments."
```

---

## 3. High-Yield Prompts for SQL Developers

### A. Query Performance Tuning Prompt
```text
I have a slow-running T-SQL query that performs a clustered index scan on a table with 15 million rows.
Here is the query:
[PASTE QUERY]

Here are the table definitions and existing non-clustered indexes:
[PASTE DDL AND INDEXES]

Identify any non-SARGable expressions, suggest composite or covering index definitions (with INCLUDE columns), and explain why the rewrite improves the execution plan.
```

### B. Execution Plan Diagnostic Prompt
```text
Analyze this actual execution plan output. The query is suffering from a heavy Hash Match and Tempdb spill.
[PASTE STATISTICS IO / TIME OUTPUT OR EXECUTION PLAN XML]
What is causing the cardinality misestimation, and how can I resolve the memory grant bottleneck?
```

### C. Complex Window Function & CTE Prompt
```text
I need to write a T-SQL query using a recursive CTE to solve an organizational reporting tree problem.
Here is the employees table:
employee_id INT, manager_id INT, full_name NVARCHAR(100), job_title NVARCHAR(50).

Write a recursive CTE that:
1. Traverses the hierarchy from the top executive (manager_id IS NULL).
2. Calculates the organizational depth level (0, 1, 2...).
3. Concatenates the reporting path (e.g. 'CEO -> VP -> Director -> Manager').
4. Includes OPTION (MAXRECURSION 100) to protect against circular references.
```

### D. Stored Procedure & Error Handling Boilerplate Prompt
```text
Generate a production-ready T-SQL stored procedure named sales.usp_process_invoice.
Requirements:
1. Accept @order_id INT as an input parameter.
2. Return @invoice_number NVARCHAR(50) as an OUTPUT parameter.
3. Wrap all operations inside a BEGIN TRY ... BEGIN CATCH block with an explicit transaction.
4. Check @@TRANCOUNT before calling ROLLBACK.
5. Re-throw errors using THROW;
6. Include SET NOCOUNT ON and SET XACT_ABORT ON.
```

---

## 4. Prompts for Accelerated SQL Learning

- **Gotcha Discovery:**
  > *"What are the 3 most common gotchas or silent logic bugs developers encounter when using `NOT IN` with subqueries in SQL Server?"*
- **Cross-Dialect Translation:**
  > *"Translate this PostgreSQL query using `DISTINCT ON` and `STRING_AGG` into performant T-SQL compatible with SQL Server 2019."*
- **Mental Model Explanation:**
  > *"Explain the difference between `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` and `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` using an ASCII diagram with duplicate dates."*
