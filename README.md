# Data Engineering Learning Lab

A hands-on learning repository focused on data engineering, analytics,
data warehousing, SQL, Python, and related data technologies.

The project uses real-world datasets to explore data processing,
data quality, analytical queries, and engineering concepts.

## Current Dataset

NYC Yellow Taxi Trip Records - January 2025

Source:
https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

## Current Progress

- Set up Python virtual environment
- Installed DuckDB, Pandas, and PyArrow
- Inspected Parquet dataset metadata
- Queried the dataset using DuckDB
- Investigated missing passenger-count values
- Analyzed passenger-count distribution

## Project Structure

- `data/`: Local datasets, excluded from Git
- `sql/`: SQL analysis
- `python/`: Python scripts
- `notebooks/`: Exploratory analysis
- `docs/`: Concepts, explanations, and learning notes

## Reproducibility

Download the dataset from the official NYC TLC source.
Raw and processed datasets are intentionally excluded from Git.

This repository documents an ongoing learning process.

## Current Progress: Initial Data Profiling

Dataset: NYC TLC Yellow Taxi Trip Records, January 2025.

### Dataset Overview

- Total records in the Parquet file: 3,475,226
- January 2025 pickup records: 3,475,204
- December 2024 boundary records: 21
- February 2025 boundary records: 1
- January passenger-count missingness: 540,149 records (15.54%)

The file was checked against its actual pickup timestamps rather than relying exclusively on its filename.

### Data Quality Investigation

Initial profiling covered:

- Dataset row count and timestamp range
- Missing-value analysis
- Passenger-count distribution
- Unusual passenger-count values
- Missingness by vendor
- Trip distance and fare distributions
- Mean versus median comparisons
- Distance percentiles
- Extreme trip-distance records

### Key Findings

- Passenger-count missingness varies across vendors.
- Vendor 1 has a substantially higher zero-passenger reporting rate than Vendor 2.
- Vendor 6 has missing passenger counts for all 489 records in this dataset.
- Missing passenger counts should not automatically be imputed with the most common value.
- Extreme trip distances exist in multiple vendors.
- Some extreme distances coincide with missing passenger counts, but the relationship is not exclusive.
- The extreme distance records appear inconsistent with their recorded trip durations and fares.

Suspicious records are being investigated rather than automatically deleted or modified. The raw dataset remains unchanged.

### Concepts Practiced

- SQL aggregation and filtering
- GROUP BY and conditional aggregation
- NULL handling
- Date and timestamp filtering
- Half-open timestamp intervals
- Mean, median, and percentiles
- Data profiling and anomaly detection
- Vendor-level comparisons
- Exploratory data analysis with DuckDB

## Analysis Reports

Detailed methodology, findings, and limitations are documented separately from the SQL queries.

- [Initial Data Profiling](docs/01_initial_profiling.md)
- [Trip Duration Analysis](docs/02_trip_duration_analysis.md)

## SQL Queries

- [Initial Data Profiling Queries](sql/01_data_profiling.sql)

## Analysis Reports

Detailed methodology, findings, and limitations are documented separately from the SQL queries.

- [Initial Data Profiling](docs/01_initial_profiling.md)
- [Trip Duration Analysis](docs/02_trip_duration_analysis.md)

## SQL Queries

- [Initial Data Profiling Queries](sql/01_data_profiling.sql)
- [Trip Duration Analysis Queries](sql/02_trip_duration_analysis.sql)
