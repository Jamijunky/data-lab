-- Iteration 6: Financial Anomaly Analysis
-- Dataset: NYC Yellow Taxi January 2025
-- Source: Duration-cleaned Parquet dataset


-- 1. Overall financial anomaly counts

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE passenger_count IS NULL
    ) AS missing_passenger_count,
    COUNT(*) FILTER (
        WHERE passenger_count = 0
    ) AS zero_passenger_count,
    COUNT(*) FILTER (
        WHERE trip_distance IS NULL
    ) AS missing_trip_distance,
    COUNT(*) FILTER (
        WHERE trip_distance = 0
    ) AS zero_trip_distance,
    COUNT(*) FILTER (
        WHERE trip_distance < 0
    ) AS negative_trip_distance,
    COUNT(*) FILTER (
        WHERE fare_amount < 0
    ) AS negative_fare_amount,
    COUNT(*) FILTER (
        WHERE total_amount < 0
    ) AS negative_total_amount
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
);


-- 2. Financial anomalies grouped by payment type

SELECT
    payment_type,
    COUNT(*) AS records,
    COUNT(*) FILTER (
        WHERE fare_amount < 0
    ) AS negative_fares,
    COUNT(*) FILTER (
        WHERE total_amount < 0
    ) AS negative_totals,
    AVG(fare_amount) AS avg_fare,
    AVG(total_amount) AS avg_total
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE fare_amount < 0
   OR total_amount < 0
GROUP BY payment_type
ORDER BY records DESC;


-- 3. Financial anomalies grouped by vendor

SELECT
    VendorID,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE fare_amount < 0
    ) AS negative_fare_records,
    COUNT(*) FILTER (
        WHERE total_amount < 0
    ) AS negative_total_records,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE fare_amount < 0
        ) / COUNT(*),
        4
    ) AS negative_fare_percentage
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
GROUP BY VendorID
ORDER BY VendorID;


-- 4. Payment type distribution within Vendor 2

SELECT
    payment_type,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE fare_amount < 0
    ) AS negative_fare_records,
    COUNT(*) FILTER (
        WHERE total_amount < 0
    ) AS negative_total_records,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE fare_amount < 0
        ) / COUNT(*),
        4
    ) AS negative_fare_percentage
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE VendorID = 2
GROUP BY payment_type
ORDER BY payment_type;


-- 5. Trip characteristics for negative-fare records

SELECT
    payment_type,
    COUNT(*) AS negative_fare_records,
    COUNT(*) FILTER (
        WHERE trip_distance = 0
    ) AS zero_distance_records,
    COUNT(*) FILTER (
        WHERE trip_distance > 0
    ) AS positive_distance_records,
    COUNT(*) FILTER (
        WHERE trip_duration_minutes < 1
    ) AS duration_under_one_minute,
    COUNT(*) FILTER (
        WHERE trip_duration_minutes >= 1
    ) AS duration_at_least_one_minute,
    AVG(trip_distance) AS avg_distance,
    AVG(trip_duration_minutes) AS avg_duration
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE fare_amount < 0
GROUP BY payment_type
ORDER BY negative_fare_records DESC;


-- 6. Most negative total amount records

SELECT
    VendorID,
    payment_type,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    trip_distance,
    trip_duration_minutes,
    fare_amount,
    tip_amount,
    improvement_surcharge,
    total_amount
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE total_amount < 0
ORDER BY total_amount ASC
LIMIT 20;


-- 7. Repeated negative fare values

SELECT
    fare_amount,
    COUNT(*) AS record_count,
    AVG(total_amount) AS avg_total,
    MIN(total_amount) AS min_total,
    MAX(total_amount) AS max_total
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE fare_amount < 0
GROUP BY fare_amount
ORDER BY record_count DESC
LIMIT 20;
