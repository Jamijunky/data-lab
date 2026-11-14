# Iteration 13: Advanced Analytical SQL

## Objective

The objective of this iteration is to develop the ability to solve more complex analytical problems using SQL.

Earlier iterations primarily used filtering, grouping, aggregation, and joins. These operations are essential, but many analytical questions require comparing individual rows, calculating rankings, building cumulative metrics, or organizing multi-stage queries.

This iteration introduces Common Table Expressions, window functions, ranking, and analytical comparisons.

## Common Table Expressions

A Common Table Expression (CTE) is a named temporary result set defined using the `WITH` clause.

CTEs allow complex SQL queries to be divided into logical stages. Instead of writing one large query with deeply nested subqueries, each stage can perform a specific transformation.

For example, one CTE can calculate trip metrics, another can aggregate them by borough, and the final query can rank the boroughs.

CTEs improve readability and make analytical logic easier to maintain. They do not automatically make a query faster.

## Window Functions

Window functions perform calculations across a related set of rows without collapsing those rows into one result per group.

This is the main distinction between ordinary aggregation and window aggregation.

A `GROUP BY` query that calculates the number of trips per borough returns one row per borough. A window function can calculate the same borough-level count while retaining every individual trip row.

The `OVER` clause defines the window over which the calculation is performed.

### PARTITION BY

`PARTITION BY` divides rows into independent groups for window calculations.

For example, partitioning by pickup borough means that each borough is processed independently.

A ranking within each borough can therefore restart from rank 1 for every borough.

### ORDER BY

Within a window function, `ORDER BY` defines the order in which rows are processed.

This is essential for operations such as running totals, ranking, and comparing the current row with previous or subsequent rows.

### ROW_NUMBER, RANK, and DENSE_RANK

These functions assign rankings to rows.

`ROW_NUMBER()` assigns a unique sequential number to every row within its window, even when values are tied.

`RANK()` assigns equal ranks to tied values and leaves gaps after ties.

`DENSE_RANK()` also assigns equal ranks to tied values but does not leave gaps.

The choice depends on the analytical requirement.

## Running Aggregates

Window functions can calculate cumulative values.

For example, a running total of daily trips can show how many trips have occurred from the beginning of the month up to each date.

Unlike a normal monthly aggregate, a running total preserves the daily breakdown while providing cumulative context.

The ordering column and window frame must be defined carefully. An explicit frame such as `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` makes the intended cumulative calculation clear.

## LAG and LEAD

`LAG()` accesses a value from a preceding row in the ordered window.

`LEAD()` accesses a value from a following row.

These functions are useful for comparing consecutive observations.

For example, daily trip counts can be compared with the previous day's count to calculate absolute and percentage changes.

The ordering must be deterministic. If multiple rows share the same ordering value, additional columns may be needed to establish a stable order.

## Conditional Ranking

Ranking can be combined with partitioning to answer questions such as:

- Which are the top five pickup zones within each borough?
- Which borough has the highest demand for each hour?
- Which origin-destination pairs are most frequent within each pickup borough?

This is more flexible than applying one global `LIMIT`, because ranking can restart independently within each group.

## Percentiles and Distribution Analysis

Averages do not describe the entire distribution of a variable.

Median and percentile calculations help understand how observations are distributed.

For example, the 90th percentile of trip duration indicates a duration at or below which approximately 90% of observations fall.

These measures are useful when a dataset contains skewed values or extreme observations.

## Analytical Query Design

Advanced analytical SQL often follows a multi-stage structure:

1. Filter the relevant records.
2. Calculate derived metrics.
3. Aggregate observations at the required level.
4. Apply window functions to compare or rank results.
5. Filter or format the final output.

CTEs help organize these stages into understandable sections.

The goal is to make the logic explicit rather than compressing everything into one difficult query.

## Analytical Conclusions

This iteration expands SQL from basic aggregation into multi-stage analytical query construction.

CTEs provide structure, window functions preserve row-level detail while adding group-level calculations, ranking identifies top observations within groups, and LAG and LEAD enable comparisons across ordered records.

These techniques are widely useful in reporting, analytics, data transformation, and data engineering workflows.

## Limitations

Window calculations depend on the chosen partition and ordering. Incorrect ordering can produce misleading rankings or cumulative results.

Percentiles and averages are descriptive statistics and do not establish causal relationships.

Ranking results may also be affected by ties, so the choice between ROW_NUMBER, RANK, and DENSE_RANK must match the question.

## Learning Reflection

The most important change in this iteration is learning to think in terms of analytical stages and row relationships.

Instead of only asking how many records belong to each group, advanced SQL allows us to ask how each record compares with its group, how values evolve over time, and which observations rank highest within a category.

These techniques provide the foundation for more sophisticated analytical transformations and repeatable data processing pipelines.
