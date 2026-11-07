-- NYC Yellow Taxi Data: Initial Data Profiling
-- Dataset: yellow_tripdata_2025-01.parquet

-- 1. Dataset overview: date range and row count
SELECT
    MIN(tpep_pickup_datetime) AS earliest_pickup,
    MAX(tpep_pickup_datetime) AS latest_pickup,
    COUNT(*) AS total_rows
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet');


-- 2. Trips by pickup month
SELECT
    DATE_TRUNC('month', tpep_pickup_datetime) AS month,
    COUNT(*) AS trips
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
GROUP BY month
ORDER BY month;


-- 3. Missing-value analysis
SELECT
    COUNT(*) AS total_trips,
    COUNT(*) FILTER (WHERE passenger_count IS NULL) AS missing_passenger_count,
    COUNT(*) FILTER (WHERE fare_amount IS NULL) AS missing_fare_amount,
    COUNT(*) FILTER (WHERE trip_distance IS NULL) AS missing_trip_distance,
    COUNT(*) FILTER (WHERE tpep_pickup_datetime IS NULL) AS missing_pickup_datetime
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet');


-- 4. Passenger-count distribution
SELECT
    passenger_count,
    COUNT(*) AS trip_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
GROUP BY passenger_count
ORDER BY passenger_count;


-- 5. Passenger-count anomalies
SELECT
    COUNT(*) FILTER (WHERE passenger_count = 0) AS zero_passenger_trips,
    COUNT(*) FILTER (WHERE passenger_count < 0) AS negative_passenger_trips,
    COUNT(*) FILTER (WHERE passenger_count > 6) AS passenger_count_above_6,
    COUNT(*) FILTER (WHERE passenger_count IS NOT NULL) AS known_passenger_counts
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet');


-- 6. Passenger-count missingness by vendor
SELECT
    VendorID,
    COUNT(*) AS total_trips,
    COUNT(*) FILTER (WHERE passenger_count IS NULL) AS missing_passenger_count,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE passenger_count IS NULL) / COUNT(*),
        2
    ) AS missing_percentage,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE passenger_count = 0) / COUNT(*),
        3
    ) AS zero_passenger_percentage,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE passenger_count = 1) / COUNT(*),
        2
    ) AS one_passenger_percentage
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
GROUP BY VendorID
ORDER BY VendorID;


-- 7. January-only passenger-count missingness
SELECT
    COUNT(*) AS january_trips,
    COUNT(*) FILTER (WHERE passenger_count IS NULL) AS missing_passenger_count,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE passenger_count IS NULL) / COUNT(*),
        2
    ) AS missing_percentage
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
WHERE tpep_pickup_datetime >= TIMESTAMP '2025-01-01 00:00:00'
  AND tpep_pickup_datetime < TIMESTAMP '2025-02-01 00:00:00';


-- 8. Distance and fare statistics by passenger-count availability
SELECT
    CASE
        WHEN passenger_count IS NULL THEN 'Missing'
        ELSE 'Reported'
    END AS passenger_status,
    COUNT(*) AS trips,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(MEDIAN(trip_distance), 2) AS median_distance,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(MEDIAN(fare_amount), 2) AS median_fare
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
WHERE tpep_pickup_datetime >= TIMESTAMP '2025-01-01 00:00:00'
  AND tpep_pickup_datetime < TIMESTAMP '2025-02-01 00:00:00'
GROUP BY passenger_status
ORDER BY passenger_status;


-- 9. Distance percentiles by passenger-count availability
SELECT
    CASE
        WHEN passenger_count IS NULL THEN 'Missing'
        ELSE 'Reported'
    END AS passenger_status,
    COUNT(*) AS trips,
    ROUND(quantile_cont(trip_distance, 0.50), 2) AS p50,
    ROUND(quantile_cont(trip_distance, 0.90), 2) AS p90,
    ROUND(quantile_cont(trip_distance, 0.95), 2) AS p95,
    ROUND(quantile_cont(trip_distance, 0.99), 2) AS p99,
    ROUND(MAX(trip_distance), 2) AS max_distance
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
WHERE tpep_pickup_datetime >= TIMESTAMP '2025-01-01 00:00:00'
  AND tpep_pickup_datetime < TIMESTAMP '2025-02-01 00:00:00'
GROUP BY passenger_status
ORDER BY passenger_status;


-- 10. Count suspicious distances
SELECT
    CASE
        WHEN passenger_count IS NULL THEN 'Missing'
        ELSE 'Reported'
    END AS passenger_status,
    COUNT(*) AS total_trips,
    COUNT(*) FILTER (WHERE trip_distance > 100) AS above_100_miles,
    COUNT(*) FILTER (WHERE trip_distance > 500) AS above_500_miles,
    COUNT(*) FILTER (WHERE trip_distance > 1000) AS above_1000_miles
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
WHERE tpep_pickup_datetime >= TIMESTAMP '2025-01-01 00:00:00'
  AND tpep_pickup_datetime < TIMESTAMP '2025-02-01 00:00:00'
GROUP BY passenger_status
ORDER BY passenger_status;


-- 11. Inspect the 15 largest trips
SELECT
    VendorID,
    passenger_count,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    ROUND(trip_distance, 2) AS distance_miles,
    date_diff(
        'minute',
        tpep_pickup_datetime,
        tpep_dropoff_datetime
    ) AS duration_minutes,
    fare_amount,
    total_amount
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
WHERE tpep_pickup_datetime >= TIMESTAMP '2025-01-01 00:00:00'
  AND tpep_pickup_datetime < TIMESTAMP '2025-02-01 00:00:00'
ORDER BY trip_distance DESC
LIMIT 15;


-- 12. Extreme distances by vendor and passenger-count availability
SELECT
    VendorID,
    CASE
        WHEN passenger_count IS NULL THEN 'Missing'
        ELSE 'Reported'
    END AS passenger_status,
    COUNT(*) AS suspicious_trips,
    ROUND(MIN(trip_distance), 2) AS min_distance,
    ROUND(MAX(trip_distance), 2) AS max_distance,
    ROUND(AVG(trip_distance), 2) AS avg_distance
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
WHERE trip_distance > 1000
GROUP BY VendorID, passenger_status
ORDER BY VendorID, passenger_status;
