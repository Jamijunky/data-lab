-- Trip Duration Analysis
-- Dataset: NYC TLC Yellow Taxi, January 2025
-- Duration calculated from pickup and drop-off timestamps.

-- 1. Initial duration distribution
WITH durations AS (
    SELECT
        date_diff(
            'second',
            tpep_pickup_datetime,
            tpep_dropoff_datetime
        ) / 60.0 AS duration_minutes
    FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
    WHERE tpep_pickup_datetime >= TIMESTAMP '2025-01-01 00:00:00'
      AND tpep_pickup_datetime < TIMESTAMP '2025-02-01 00:00:00'
)
SELECT
    COUNT(*) AS total_trips,
    ROUND(AVG(duration_minutes), 2) AS average_duration,
    ROUND(MEDIAN(duration_minutes), 2) AS median_duration,
    ROUND(MIN(duration_minutes), 2) AS min_duration,
    ROUND(MAX(duration_minutes), 2) AS max_duration,
    ROUND(QUANTILE_CONT(duration_minutes, 0.25), 2) AS p25,
    ROUND(QUANTILE_CONT(duration_minutes, 0.50), 2) AS p50,
    ROUND(QUANTILE_CONT(duration_minutes, 0.75), 2) AS p75,
    ROUND(QUANTILE_CONT(duration_minutes, 0.90), 2) AS p90,
    ROUND(QUANTILE_CONT(duration_minutes, 0.95), 2) AS p95,
    ROUND(QUANTILE_CONT(duration_minutes, 0.99), 2) AS p99
FROM durations;


-- 2. Duration statistics after excluding negative durations
WITH durations AS (
    SELECT
        date_diff(
            'second',
            tpep_pickup_datetime,
            tpep_dropoff_datetime
        ) / 60.0 AS duration_minutes
    FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
    WHERE tpep_pickup_datetime >= TIMESTAMP '2025-01-01 00:00:00'
      AND tpep_pickup_datetime < TIMESTAMP '2025-02-01 00:00:00'
)
SELECT
    COUNT(*) AS valid_trips,
    ROUND(AVG(duration_minutes), 2) AS average_duration,
    ROUND(MEDIAN(duration_minutes), 2) AS median_duration,
    ROUND(MIN(duration_minutes), 2) AS min_duration,
    ROUND(MAX(duration_minutes), 2) AS max_duration,
    ROUND(QUANTILE_CONT(duration_minutes, 0.90), 2) AS p90,
    ROUND(QUANTILE_CONT(duration_minutes, 0.95), 2) AS p95,
    ROUND(QUANTILE_CONT(duration_minutes, 0.99), 2) AS p99
FROM durations
WHERE duration_minutes >= 0;


-- 3. Sensitivity of mean and median to long-duration trips
WITH durations AS (
    SELECT
        date_diff(
            'second',
            tpep_pickup_datetime,
            tpep_dropoff_datetime
        ) / 60.0 AS duration_minutes
    FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
    WHERE tpep_pickup_datetime >= TIMESTAMP '2025-01-01 00:00:00'
      AND tpep_pickup_datetime < TIMESTAMP '2025-02-01 00:00:00'
)
SELECT
    COUNT(*) FILTER (
        WHERE duration_minutes >= 0
    ) AS nonnegative_trips,

    ROUND(AVG(duration_minutes) FILTER (
        WHERE duration_minutes >= 0
    ), 2) AS original_mean,

    ROUND(AVG(duration_minutes) FILTER (
        WHERE duration_minutes BETWEEN 0 AND 120
    ), 2) AS mean_under_2h,

    ROUND(AVG(duration_minutes) FILTER (
        WHERE duration_minutes BETWEEN 0 AND 60
    ), 2) AS mean_under_1h,

    ROUND(MEDIAN(duration_minutes) FILTER (
        WHERE duration_minutes BETWEEN 0 AND 120
    ), 2) AS median_under_2h,

    COUNT(*) FILTER (
        WHERE duration_minutes > 120
    ) AS trips_over_2h,

    COUNT(*) FILTER (
        WHERE duration_minutes > 60
    ) AS trips_over_1h

FROM durations;
