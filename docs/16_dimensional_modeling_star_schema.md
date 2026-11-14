# Iteration 16: Dimensional Modeling and Building a Star-Schema Warehouse

## 1. Objective

This iteration takes the enriched NYC Yellow Taxi dataset used throughout the first fifteen iterations and reorganizes it into a small analytical warehouse in DuckDB.

Until now, most analysis was performed directly against one wide enriched Parquet file. That was convenient for exploration, but the file mixed trip measurements with descriptive attributes such as location names, payment codes, and vendor identifiers.

The purpose of this iteration is to separate the measurable trip event from the descriptive context used to analyze it.

The result is a star-schema warehouse containing one fact table and four dimensions:

- `fact_trips`
- `dim_date`
- `dim_location`
- `dim_payment`
- `dim_vendor`

This document records the problem, the decisions, the implementation sequence, the validation strategy, the trade-offs, and the limitations. It is intended to let a reader reconstruct the work without needing the original step-by-step conversation.

## 2. Where we started

The source for this iteration was:

`data/processed/yellow_tripdata_2025-01_enriched.parquet`

This file was produced by the earlier Python and DuckDB processing pipeline. That workflow read the raw January 2025 Yellow Taxi Parquet file, filtered pickup dates to January, removed records whose drop-off timestamp preceded pickup, and enriched pickup and drop-off location IDs using the TLC Taxi Zone Lookup reference data.

The established record counts were:

| Processing stage | Records |
|---|---:|
| Raw dataset | 3,475,226 |
| January pickup records | 3,475,204 |
| Duration-cleaned records | 3,475,080 |
| Geographically enriched records | 3,475,080 |

The earlier pipeline also reported zero unmatched pickup locations and zero unmatched drop-off locations.

Before designing the warehouse, we inspected the real source schema using DuckDB's `DESCRIBE` statement. The source contained:

- Vendor and payment identifiers.
- Pickup and drop-off timestamps.
- Passenger count and trip distance.
- Rate code and store-and-forward flag.
- Pickup and drop-off location IDs.
- Fare, tip, tax, toll, surcharge, and total amount columns.
- Derived trip duration.
- Enriched pickup and drop-off borough, zone, and service-zone attributes.

Inspecting the actual schema was necessary. We did not want to design a model around columns that were not present or misunderstand how the existing enriched dataset was structured.

## 3. The modeling problem

A source trip row contains several kinds of information together. For example, it has the event timestamps, pickup and drop-off places, payment code, vendor, distance, duration, fare, and total amount.

For an analytical warehouse, we want to distinguish two things:

**The business event:** a taxi trip and its measurable values.

**The descriptive context:** the date, location, payment method, and vendor information that helps explain and group those trips.

Dimensional modeling gives us a practical way to organize these two kinds of information. The fact table represents the event. Dimension tables describe the context around it.

The purpose is not to split tables just for the sake of normalization. The purpose is to create a model that is easier to query consistently for analytical questions.

## 4. The first and most important decision: grain

Before selecting columns, we defined the grain of the fact table.

> One row in `fact_trips` represents one row from the enriched source dataset, corresponding to one taxi trip record.

This is the grain of the fact table.

It is not one row per day, one row per borough, or one row per payment method. Those would be aggregated datasets with different grains.

Defining the grain first prevents mixing levels of detail. It also gives us a clear validation condition: the number of rows in the fact table should match the number of rows in the enriched source.

We deliberately chose not to aggregate trips together. This warehouse preserves trip-level detail.

## 5. Designing the fact table

The fact table stores the trip event, its measurements, and keys to the dimensions.

### 5.1 Measures

The following source values are retained as measures:

- `passenger_count`
- `trip_distance`
- `trip_duration_minutes`
- `fare_amount`
- `extra_amount`
- `mta_tax`
- `tip_amount`
- `tolls_amount`
- `improvement_surcharge`
- `total_amount`
- `congestion_surcharge`
- `airport_fee`
- `cbd_congestion_fee`

These values can be analyzed with aggregations such as `SUM`, `AVG`, `MIN`, `MAX`, and percentile calculations. The appropriate aggregation depends on the question. For example, total fare can be summed, while average trip duration is usually more meaningful than summing durations across unrelated trips.

### 5.2 Dimension keys

The fact table references the dimensions through:

- `pickup_date_key`
- `dropoff_date_key`
- `pickup_location_key`
- `dropoff_location_key`
- `payment_key`
- `vendor_key`

Pickup and drop-off are separate roles. Both location keys reference the same `dim_location` table, and both date keys reference the same `dim_date` table. Reusing one dimension in multiple roles is called a *role-playing dimension*.

### 5.3 Other source attributes

`RatecodeID` and `store_and_fwd_flag` remain in the fact table as source attributes. We did not create separate dimensions for every categorical column. The first model is intentionally limited to the dimensions that support the main analytical questions.

The original pickup and drop-off timestamps also remain in the fact table. The date keys support calendar analysis, while the full timestamps preserve the exact time of each trip and allow hour-level analysis.

## 6. Designing the dimensions

### 6.1 `dim_date`

The date dimension supplies calendar attributes:

| Column | Meaning |
|---|---|
| `date_key` | Integer key in YYYYMMDD format |
| `date_value` | Actual calendar date |
| `year_number` | Year |
| `month_number` | Month number |
| `day_of_month` | Day within the month |
| `weekday_name` | Weekday name |
| `weekday_number` | ISO weekday number |
| `quarter_number` | Calendar quarter |
| `month_name` | Month name |
| `is_weekend` | Saturday or Sunday indicator |

For example, 14 January 2025 has the date key `20250114`.

The calendar is generated from the earliest pickup date through the latest drop-off date in the source. This avoids assuming that every trip starts and ends on the same calendar date.

A special `date_key = 0` row represents a missing or unknown timestamp. The date dimension is at day-level grain. We did not add an hour-level time dimension because the original timestamps remain available in the fact table.

### 6.2 `dim_location`

The location dimension combines the descriptive attributes of pickup and drop-off locations:

| Column | Meaning |
|---|---|
| `location_key` | Warehouse-generated surrogate key |
| `location_id` | Original TLC location identifier |
| `borough` | Borough |
| `zone` | Taxi zone name |
| `service_zone` | Service-zone classification |

To build it, pickup and drop-off location records are combined with `UNION ALL`. The combined records are grouped by `location_id`, producing one row per non-null location ID.

A generated `location_key` is used internally by the warehouse. The original `location_id` is retained for traceability.

A special row with `location_key = 0` represents a missing location identifier. Actual source IDs are not overwritten with zero.

We use one location dimension for both pickup and drop-off because both attributes describe the same kind of entity: a TLC taxi zone. The fact table simply references that dimension twice.

### 6.3 `dim_payment`

The payment dimension contains:

| Column | Meaning |
|---|---|
| `payment_key` | Warehouse-generated surrogate key |
| `payment_type` | Original source payment code |
| `payment_description` | Readable description |

The dimension is generated from the distinct non-null payment codes present in the source.

The implementation labels common codes as follows: 1 is Credit card, 2 is Cash, 3 is No charge, and 4 is Dispute. Code 0 is retained as an actual source code and described as Unknown / unspecified. Code 5 is retained with a conservative Unknown / other code label. Code 6 is labeled Voided trip if present. Other codes receive a generic label.

A separate `payment_key = 0` member represents a genuinely missing payment type.

This distinction is important: a source value of zero is not the same thing as SQL `NULL`. We preserve both cases separately.

### 6.4 `dim_vendor`

The vendor dimension contains:

| Column | Meaning |
|---|---|
| `vendor_key` | Warehouse-generated surrogate key |
| `VendorID` | Original source vendor identifier |
| `vendor_description` | Generic readable label |

The dimension is generated from distinct non-null vendor IDs in the source. It uses labels such as `Vendor 1` rather than inventing company names that are not present in the enriched dataset.

A `vendor_key = 0` row represents a missing vendor ID.

## 7. Natural keys and surrogate keys

The source already contains identifiers such as `PULocationID`, `DOLocationID`, `payment_type`, and `VendorID`. These are source or business identifiers.

For location, payment, and vendor, we generate separate warehouse keys. The fact table stores those warehouse keys, while the dimension tables retain the original identifiers.

This separates the warehouse's internal references from source-system identifiers and makes it easier to integrate additional source systems later.

The date dimension uses a date-derived YYYYMMDD key. This is a readable date key rather than a randomly generated surrogate.

The source does not contain a unique trip identifier. We therefore generate a `trip_key` for each fact row using `ROW_NUMBER()` over the source attributes. This key identifies rows in the generated warehouse snapshot; it is not an official TLC trip ID and should not be treated as a durable business identifier across independent rebuilds. If exact duplicate source rows exist, they have no distinct source identity available to preserve.

## 8. Why this is a star schema

`fact_trips` sits in the center and connects directly to the four dimensions. Descriptive attributes remain together in their dimensions rather than being split into additional normalized hierarchy tables.

For example, borough and service-zone information remain in `dim_location`. We do not create a separate borough table in this first model.

This is a star schema. We chose it because it is straightforward to understand and convenient for analytical queries. A snowflake design would add more joins and complexity without a demonstrated need in this iteration.

## 9. Implementation sequence

The implementation is split into two files:

- `sql/16_build_taxi_warehouse.sql` creates the dimensions and fact table.
- `python/16_build_taxi_warehouse.py` runs the SQL through DuckDB and performs validation checks.

The generated database is:

`data/processed/taxi_warehouse.duckdb`

The SQL creates the tables in dependency order:

1. `dim_date`
2. `dim_location`
3. `dim_payment`
4. `dim_vendor`
5. `fact_trips`

The dimensions are created first because the fact table needs their keys.

The fact table is then built from the enriched Parquet source. It assigns a `trip_key`, joins pickup and drop-off timestamps to `dim_date`, joins both location IDs to `dim_location`, and joins payment and vendor identifiers to their dimensions.

The joins are `LEFT JOIN`s. This is deliberate: a trip should not disappear merely because a dimension lookup is missing. Missing or unmatched dimension references are mapped to the explicit key-zero member.

The transformation does not apply new cleaning rules. It preserves the enriched source population, including unusual measurements and missing source values.

## 10. How to run it

From the repository root:

```bash
cd ~/data-lab
source .venv/bin/activate
python python/16_build_taxi_warehouse.py
