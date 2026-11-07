# Initial Data Profiling

## Objective

Understand the structure, completeness, and basic quality of the NYC TLC Yellow Taxi January 2025 dataset before conducting deeper analysis.

## Dataset

- **Source:** NYC Taxi & Limousine Commission (TLC)
- **Dataset:** Yellow Taxi Trip Records, January 2025
- **Format:** Parquet
- **Engine:** DuckDB
- **Total records in file:** 3,475,226
- **January pickup records:** 3,475,204
- **Columns:** 20

The file contains 21 December 2024 boundary records and 1 February 2025 boundary record. Analyses targeting January use pickup timestamps from January 1 inclusive to February 1 exclusive.

## Methodology

The initial profiling included:

- Row count and timestamp range
- Missing-value analysis
- Passenger-count distribution
- Passenger-count missingness by vendor
- Trip distance and fare distributions
- Mean, median, and percentile comparisons
- Extreme trip-distance investigation

The raw Parquet file was queried directly using DuckDB and was not modified.

## Key Findings

### Passenger-count missingness

- 540,149 January records had missing passenger counts.
- This represents approximately 15.54% of January records.
- Missingness varied across vendors.
- Vendor 6 had missing passenger counts for all 489 records.
- Vendor 1 had a substantially higher zero-passenger reporting rate than Vendor 2.

Missing passenger counts were not replaced with an assumed value.

### Distance and fare distributions

Trips with missing passenger counts had:

- Average distance: 20.31 miles
- Median distance: 2.04 miles
- Average fare: $14.59
- Median fare: $14.04

Trips with reported passenger counts had:

- Average distance: 3.19 miles
- Median distance: 1.60 miles
- Average fare: $17.54
- Median fare: $12.10

The difference between mean and median distance indicates that extreme values influence the average.

### Extreme distances

Extreme trip distances were found across multiple vendors.

The largest recorded distances were physically implausible when compared with their recorded trip durations and fares. Some extreme records had missing passenger counts, but this was not exclusive to records with missing passenger counts.

## Interpretation

The dataset contains missing passenger-count values and extreme trip-distance records.

Vendor-level differences suggest that missingness may not be uniform across the dataset. However, the cause of these differences has not been established.

The presence of anomalies does not automatically justify deleting or modifying records.

## Limitations

- The investigation is exploratory.
- No official TLC validity thresholds were established for the unusual records.
- Vendor differences are descriptive and do not establish causation.
- The analysis does not establish why the anomalies occurred.

## Decision

Preserve the original dataset unchanged.

Continue analysis using explicit filters when necessary, while documenting the assumptions behind those filters.

## Concepts Practiced

- Data profiling
- SQL aggregation and filtering
- NULL handling
- Conditional aggregation
- Timestamp filtering
- Mean, median, and percentiles
- Vendor-level comparisons
- Exploratory anomaly detection
