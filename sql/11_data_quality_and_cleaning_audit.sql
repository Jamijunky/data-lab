-- Iteration 11: Data Quality and Cleaning Audit
-- Dataset: January 2025 NYC Yellow Taxi
-- Source: duration-cleaned Parquet dataset
--
-- This audit identifies issues. It does not automatically delete records.


-- 1. Completeness audit
-- Count missing values in important columns.

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (WHERE VendorID IS NULL) AS missing_vendor_id,
    COUNT(*) FILTER (WHERE tpep_pickup_datetime IS NULL) AS missing_pickup_datetime,
    COUNT(*) FILTER (WHERE tpep_dropoff_datetime IS NULL) AS missing_dropoff_datetime,
    COUNT(*) FILTER (WHERE passenger_count IS NULL) AS missing_passenger_count,
    COUNT(*) FILTER (WHERE trip_distance IS NULL) AS missing_trip_distance,
    COUNT(*) FILTER (WHERE RatecodeID IS NULL) AS missing_ratecode_id,
    COUNT(*) FILTER (WHERE PULocationID IS NULL) AS missing_pickup_location,
    COUNT(*) FILTER (WHERE DOLocationID IS NULL) AS missing_dropoff_location,
    COUNT(*) FILTER (WHERE fare_amount IS NULL) AS missing_fare_amount,
    COUNT(*) FILTER (WHERE total_amount IS NULL) AS missing_total_amount

FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet');


-- 2. Timestamp and duration validity
-- Check chronological relationships and nonpositive durations.

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE tpep_dropoff_datetime < tpep_pickup_datetime
    ) AS negative_duration_records,

    COUNT(*) FILTER (
        WHERE tpep_dropoff_datetime = tpep_pickup_datetime
    ) AS zero_duration_records,

    COUNT(*) FILTER (
        WHERE tpep_dropoff_datetime > tpep_pickup_datetime
    ) AS positive_duration_records,

    MIN(trip_duration_minutes) AS minimum_duration,
    MAX(trip_duration_minutes) AS maximum_duration

FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet');


-- 3. Numeric domain checks
-- Identify negative and zero values without assuming all are invalid.

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (WHERE passenger_count < 0) AS negative_passenger_count,
    COUNT(*) FILTER (WHERE passenger_count = 0) AS zero_passenger_count,

    COUNT(*) FILTER (WHERE trip_distance < 0) AS negative_distance,
    COUNT(*) FILTER (WHERE trip_distance = 0) AS zero_distance,

    COUNT(*) FILTER (WHERE fare_amount < 0) AS negative_fare,
    COUNT(*) FILTER (WHERE fare_amount = 0) AS zero_fare,

    COUNT(*) FILTER (WHERE total_amount < 0) AS negative_total,
    COUNT(*) FILTER (WHERE total_amount = 0) AS zero_total

FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet');


-- 4. Extreme distance and speed audit
-- Speed is calculated only when duration and distance are positive.

WITH trip_metrics AS (
    SELECT
        trip_distance,
        trip_duration_minutes,

        trip_distance / (trip_duration_minutes / 60.0) AS speed_mph

    FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
    WHERE trip_distance > 0
      AND trip_duration_minutes > 0
)
SELECT
    COUNT(*) AS eligible_records,

    COUNT(*) FILTER (WHERE trip_distance > 100) AS distance_over_100,
    COUNT(*) FILTER (WHERE trip_distance > 1000) AS distance_over_1000,
    COUNT(*) FILTER (WHERE trip_distance > 10000) AS distance_over_10000,

    COUNT(*) FILTER (WHERE speed_mph > 100) AS speed_over_100_mph,
    COUNT(*) FILTER (WHERE speed_mph > 200) AS speed_over_200_mph,
    COUNT(*) FILTER (WHERE speed_mph > 500) AS speed_over_500_mph,

    MAX(trip_distance) AS maximum_distance,
    MAX(speed_mph) AS maximum_speed

FROM trip_metrics;


-- 5. Cross-column timestamp consistency
-- Compare stored duration with duration derived from timestamps.

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE ABS(
            trip_duration_minutes
            - DATE_DIFF(
                'second',
                tpep_pickup_datetime,
                tpep_dropoff_datetime
            ) / 60.0
        ) > 0.001
    ) AS duration_mismatches,

    MAX(ABS(
        trip_duration_minutes
        - DATE_DIFF(
            'second',
            tpep_pickup_datetime,
            tpep_dropoff_datetime
        ) / 60.0
    )) AS maximum_duration_difference

FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
WHERE tpep_pickup_datetime IS NOT NULL
  AND tpep_dropoff_datetime IS NOT NULL
  AND trip_duration_minutes IS NOT NULL;


-- 6. Fare component reconciliation
-- COALESCE treats missing components as zero for this test.
-- This is an analytical assumption, not proof that NULL means zero.

WITH reconciliation AS (
    SELECT
        total_amount,

        COALESCE(fare_amount, 0)
        + COALESCE(extra, 0)
        + COALESCE(mta_tax, 0)
        + COALESCE(tip_amount, 0)
        + COALESCE(tolls_amount, 0)
        + COALESCE(improvement_surcharge, 0)
        + COALESCE(congestion_surcharge, 0)
        + COALESCE(airport_fee, 0)
        + COALESCE(cbd_congestion_fee, 0) AS reconstructed_total

    FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
)
SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE total_amount IS NULL
    ) AS missing_recorded_total,

    COUNT(*) FILTER (
        WHERE total_amount IS NOT NULL
          AND ABS(total_amount - reconstructed_total) <= 0.01
    ) AS matching_records,

    COUNT(*) FILTER (
        WHERE total_amount IS NOT NULL
          AND ABS(total_amount - reconstructed_total) > 0.01
    ) AS records_with_difference,

    ROUND(AVG(
        total_amount - reconstructed_total
    ), 4) AS average_difference

FROM reconciliation
WHERE total_amount IS NOT NULL;


-- 7. Candidate duplicate detection
-- This is a candidate key, not a guaranteed unique trip identifier.

WITH candidate_groups AS (
    SELECT
        VendorID,
        tpep_pickup_datetime,
        tpep_dropoff_datetime,
        PULocationID,
        DOLocationID,
        passenger_count,
        trip_distance,
        fare_amount,
        total_amount,
        COUNT(*) AS occurrences

    FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')

    GROUP BY
        VendorID,
        tpep_pickup_datetime,
        tpep_dropoff_datetime,
        PULocationID,
        DOLocationID,
        passenger_count,
        trip_distance,
        fare_amount,
        total_amount

    HAVING COUNT(*) > 1
)
SELECT
    COUNT(*) AS repeated_groups,
    SUM(occurrences) AS records_in_repeated_groups,
    SUM(occurrences - 1) AS excess_occurrences,
    MAX(occurrences) AS maximum_occurrences
FROM candidate_groups;


-- 8. Domain and category checks
-- Inspect distinct values before deciding which are invalid.

SELECT
    'VendorID' AS column_name,
    CAST(VendorID AS VARCHAR) AS column_value,
    COUNT(*) AS record_count
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY VendorID

UNION ALL

SELECT
    'RatecodeID',
    CAST(RatecodeID AS VARCHAR),
    COUNT(*)
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY RatecodeID

UNION ALL

SELECT
    'payment_type',
    CAST(payment_type AS VARCHAR),
    COUNT(*)
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY payment_type

ORDER BY column_name, record_count DESC;


-- 9. Consolidated record-level quality flags
-- Flags are independent. A record can have multiple flags.

WITH flagged_trips AS (
    SELECT
        *,

        passenger_count IS NULL AS missing_passenger_count,

        trip_distance IS NULL
            OR trip_distance < 0 AS invalid_distance,

        trip_distance = 0 AS zero_distance,

        tpep_pickup_datetime IS NULL
            OR tpep_dropoff_datetime IS NULL
            OR tpep_dropoff_datetime < tpep_pickup_datetime
            AS invalid_timestamps,

        trip_duration_minutes <= 0 AS nonpositive_duration,

        trip_distance > 100 AS extreme_distance,

        CASE
            WHEN trip_duration_minutes > 0
             AND trip_distance > 0
            THEN trip_distance / (trip_duration_minutes / 60.0) > 100
            ELSE FALSE
        END AS extreme_speed,

        fare_amount < 0 AS negative_fare,

        total_amount < 0 AS negative_total,

        PULocationID IS NULL AS missing_pickup_location,

        DOLocationID IS NULL AS missing_dropoff_location

    FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
)
SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (WHERE missing_passenger_count) AS missing_passenger_count,
    COUNT(*) FILTER (WHERE invalid_distance) AS invalid_distance,
    COUNT(*) FILTER (WHERE zero_distance) AS zero_distance,
    COUNT(*) FILTER (WHERE invalid_timestamps) AS invalid_timestamps,
    COUNT(*) FILTER (WHERE nonpositive_duration) AS nonpositive_duration,
    COUNT(*) FILTER (WHERE extreme_distance) AS extreme_distance,
    COUNT(*) FILTER (WHERE extreme_speed) AS extreme_speed,
    COUNT(*) FILTER (WHERE negative_fare) AS negative_fare,
    COUNT(*) FILTER (WHERE negative_total) AS negative_total,
    COUNT(*) FILTER (WHERE missing_pickup_location) AS missing_pickup_location,
    COUNT(*) FILTER (WHERE missing_dropoff_location) AS missing_dropoff_location

FROM flagged_trips;
