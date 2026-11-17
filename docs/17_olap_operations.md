# Iteration 17: OLAP Operations on the Taxi Warehouse

## What I worked on

In Iteration 16, I built a DuckDB star-schema warehouse with `fact_trips` and the dimensions `dim_date`, `dim_location`, `dim_payment`, and `dim_vendor`.

In this iteration, I used that warehouse to practise five OLAP operations: roll-up, drill-down, slice, dice, and pivot.

I did not create another dataset or change the warehouse tables. These were analytical queries over the existing warehouse.

## 1. Roll-up: pickup zones to boroughs

I grouped trips by pickup borough and calculated trip count and total recorded revenue.

The query returned:

| Pickup borough | Trips | Total revenue |
|---|---:|---:|
| Manhattan | 3,089,206 | 67,088,478.07 |
| Queens | 294,952 | 19,266,428.95 |
| Brooklyn | 66,046 | 1,791,131.25 |
| Bronx | 14,724 | 461,604.07 |
| Unknown | 8,141 | 225,274.06 |
| N/A | 1,380 | 123,597.06 |
| EWR | 377 | 35,565.38 |
| Staten Island | 254 | 9,227.03 |

This was an aggregation from individual pickup-location records to borough groups.

The query returned a result set. It did not create a new column or permanently materialize a borough summary table.

## 2. Drill-down: Manhattan to its pickup zones

I restricted the same analysis to Manhattan and grouped by both borough and zone.

The highest-volume zones in the returned output were:

| Manhattan pickup zone | Trips | Total revenue |
|---|---:|---:|
| Midtown Center | 169,977 | 3,892,581.32 |
| Upper East Side South | 163,702 | 3,152,979.73 |
| Upper East Side North | 155,644 | 3,068,104.42 |
| Times Sq/Theatre District | 125,828 | 3,173,675.64 |
| Penn Station/Madison Sq West | 119,130 | 2,720,326.24 |

At the low end of the returned Manhattan results, Inwood had 448 trips, Roosevelt Island had 232, and Inwood Hill Park had 36.

The output showed that demand was not evenly distributed across Manhattan zones.

For this exercise, drill-down was the move from a borough summary to the zone-level breakdown within a selected borough. The SQL is still `GROUP BY`; the change is the level of detail being examined.

## 3. Slice: one selected dimension value

I used payment type as the slice and selected source `payment_type = 1`, which the warehouse's payment dimension labels as Credit card.

The query joined `fact_trips` to `dim_payment`, filtered to that one payment code, and calculated trip count and average fare/total.

The practical point was to restrict the analysis to one value of a dimension.

I did not retain the numerical output in my iteration notes, so I am not recording unverified counts or averages here.

## 4. Dice: filters across multiple dimensions

I combined filters from three dimensions:

- Pickup location: Manhattan.
- Pickup date: weekdays (`is_weekend = FALSE`).
- Payment: source `payment_type = 1` (credit card).

The query grouped the remaining trips by weekday and calculated trip count and total revenue.

This narrowed the warehouse to a subset defined by multiple dimension conditions.

I did not retain the numerical output in my iteration notes, so I am not recording unverified weekday counts or revenue values here.

## 5. Pivot: compare categories across columns

The pivot exercise was intended to compare payment-type trip counts across weekdays.

Instead of returning one row for every weekday/payment-type pair, conditional aggregation places payment categories in separate result columns.

The SQL uses `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` expressions.

This is a pivot-like result built with conditional aggregation. It does not create a permanent pivot table.

An important warehouse detail is that `payment_key` is a generated warehouse key, while `payment_type` is the original source code.

I should filter and label source payment categories using `dim_payment.payment_type`, not assume that a particular surrogate key equals a source payment code.

The SQL file therefore joins `dim_payment` and pivots on `payment_type`. It also keeps a genuinely missing `payment_type` separate from source code `0`.

The pivot output was not retained in my notes, so I am not claiming specific weekday/payment patterns from it.

## What I took away

The five labels describe different ways of looking at a multidimensional dataset, but they are not five completely different SQL mechanisms:

- Roll-up and drill-down change the aggregation level.
- Slice and dice restrict the records using dimension values. Dice combines multiple conditions or dimensions.
- Pivot changes the layout of grouped results so categories can be compared across columns.

In these exercises, SQL `GROUP BY`, joins, `WHERE`, and conditional aggregation supplied the mechanics.

The OLAP terms describe the analytical perspective.

## Scope and limitations

- All queries read the existing `taxi_warehouse.duckdb` database. They do not modify its tables.
- The geography used in roll-up and drill-down is pickup geography, not drop-off geography.
- `total_amount` is the recorded trip total in the source data; this exercise does not establish driver income or profit.
- The slice, dice, and pivot numerical outputs were not captured in my notes. No results are invented for these exercises.
- The pivot is implemented with conditional aggregation rather than creating and storing a separate pivot table.

## Files

- SQL queries: `sql/17_olap_operations.sql`
- This learning record: `docs/17_olap_operations.md`

The SQL file contains each query as a separate section so that I can run and inspect them independently against the existing DuckDB warehouse.
