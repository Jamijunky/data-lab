-- Distance anomaly analysis
-- Dataset: NYC TLC Yellow Taxi, January 2025
-- Database engine: DuckDB

-- 1. Calculate average speed for trips with positive distance
--    and positive duration.

WITH trip_speeds AS (
    SELECT
        passenger_count,
        trip_distance,
        trip_duration_minutes,
        tpep_pickup_datetime,
        tpep_dropoff_datetime,
        trip_distance / (trip_duration_minutes / 60.0)
            AS average_speed_mph
    FROM read_parquet(
        'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
    )
    WHERE trip_distance > 0
      AND trip_duration_minutes > 0
)

-- 2. Distribution of average speeds.

SELECT
    CASE
        WHEN average_speed_mph <= 100 THEN '0-100 mph'
        WHEN average_speed_mph <= 200 THEN '100-200 mph'
        WHEN average_speed_mph <= 500 THEN '200-500 mph'
        ELSE '>500 mph'
    END AS speed_range,
    COUNT(*) AS trip_count,
    MIN(average_speed_mph) AS min_speed,
    MAX(average_speed_mph) AS max_speed
FROM trip_speeds
GROUP BY speed_range
ORDER BY min_speed;


-- 3. Count records exceeding the selected threshold.

SELECT
    COUNT(*) AS suspicious_trips
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE trip_distance > 0
  AND trip_duration_minutes > 0
  AND trip_distance / (trip_duration_minutes / 60.0) > 100;


-- 4. Inspect suspicious records.

SELECT
    passenger_count,
    trip_distance,
    trip_duration_minutes,
    trip_distance / (trip_duration_minutes / 60.0)
        AS average_speed_mph,
    tpep_pickup_datetime,
    tpep_dropoff_datetime
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE trip_distance > 0
  AND trip_duration_minutes > 0
  AND trip_distance / (trip_duration_minutes / 60.0) > 100
ORDER BY average_speed_mph DESC;


-- 5. Retrieve records valid under the selected distance rule.
-- This query does not overwrite the existing cleaned dataset.

SELECT *
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE trip_distance > 0
  AND trip_duration_minutes > 0
  AND trip_distance / (trip_duration_minutes / 60.0) <= 100;
