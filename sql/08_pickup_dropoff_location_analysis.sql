-- Iteration 8: Pickup and Drop-off Location Analysis
-- Dataset: NYC Yellow Taxi January 2025
-- Source: Duration-cleaned Parquet dataset


-- 1. Check location data quality

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE PULocationID IS NULL
    ) AS missing_pickup_location,
    COUNT(*) FILTER (
        WHERE DOLocationID IS NULL
    ) AS missing_dropoff_location,
    COUNT(*) FILTER (
        WHERE PULocationID IS NOT NULL
          AND DOLocationID IS NOT NULL
    ) AS records_with_both_locations
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
);


-- 2. Pickup demand by location

SELECT
    PULocationID,
    COUNT(*) AS pickup_count
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE PULocationID IS NOT NULL
GROUP BY PULocationID
ORDER BY pickup_count DESC
LIMIT 20;


-- 3. Drop-off demand by location

SELECT
    DOLocationID,
    COUNT(*) AS dropoff_count
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE DOLocationID IS NOT NULL
GROUP BY DOLocationID
ORDER BY dropoff_count DESC
LIMIT 20;


-- 4. Compare pickup and drop-off counts by location

WITH pickup_counts AS (
    SELECT
        PULocationID AS location_id,
        COUNT(*) AS pickup_count
    FROM read_parquet(
        'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
    )
    WHERE PULocationID IS NOT NULL
    GROUP BY PULocationID
),
dropoff_counts AS (
    SELECT
        DOLocationID AS location_id,
        COUNT(*) AS dropoff_count
    FROM read_parquet(
        'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
    )
    WHERE DOLocationID IS NOT NULL
    GROUP BY DOLocationID
)
SELECT
    COALESCE(p.location_id, d.location_id) AS location_id,
    COALESCE(p.pickup_count, 0) AS pickup_count,
    COALESCE(d.dropoff_count, 0) AS dropoff_count,
    COALESCE(p.pickup_count, 0)
        - COALESCE(d.dropoff_count, 0) AS pickup_dropoff_difference
FROM pickup_counts p
FULL OUTER JOIN dropoff_counts d
    ON p.location_id = d.location_id
ORDER BY pickup_dropoff_difference DESC;


-- 5. Most frequent pickup-dropoff pairs

SELECT
    PULocationID,
    DOLocationID,
    COUNT(*) AS trip_count,
    AVG(trip_distance) AS avg_trip_distance,
    MEDIAN(trip_distance) AS median_trip_distance,
    AVG(trip_duration_minutes) AS avg_duration_minutes
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE PULocationID IS NOT NULL
  AND DOLocationID IS NOT NULL
GROUP BY
    PULocationID,
    DOLocationID
ORDER BY trip_count DESC
LIMIT 20;


-- 6. Pickup demand by hour

SELECT
    EXTRACT(
        HOUR FROM tpep_pickup_datetime
    ) AS pickup_hour,
    COUNT(*) AS pickup_count
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE PULocationID IS NOT NULL
GROUP BY pickup_hour
ORDER BY pickup_hour;


-- 7. Pickup demand by location and hour

SELECT
    PULocationID,
    EXTRACT(
        HOUR FROM tpep_pickup_datetime
    ) AS pickup_hour,
    COUNT(*) AS pickup_count
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE PULocationID IS NOT NULL
GROUP BY
    PULocationID,
    pickup_hour
ORDER BY
    PULocationID,
    pickup_hour;


-- 8. Locations with the greatest pickup activity during each hour

WITH hourly_location_demand AS (
    SELECT
        PULocationID,
        EXTRACT(
            HOUR FROM tpep_pickup_datetime
        ) AS pickup_hour,
        COUNT(*) AS pickup_count
    FROM read_parquet(
        'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
    )
    WHERE PULocationID IS NOT NULL
    GROUP BY
        PULocationID,
        pickup_hour
),
ranked_locations AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY pickup_hour
            ORDER BY pickup_count DESC
        ) AS location_rank
    FROM hourly_location_demand
)
SELECT
    pickup_hour,
    PULocationID,
    pickup_count
FROM ranked_locations
WHERE location_rank <= 5
ORDER BY
    pickup_hour,
    location_rank;


-- 9. Average trip characteristics by pickup location

SELECT
    PULocationID,
    COUNT(*) AS trip_count,
    AVG(trip_distance) AS avg_trip_distance,
    MEDIAN(trip_distance) AS median_trip_distance,
    AVG(trip_duration_minutes) AS avg_duration_minutes,
    MEDIAN(trip_duration_minutes) AS median_duration_minutes
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE PULocationID IS NOT NULL
  AND trip_distance > 0
  AND trip_duration_minutes > 0
GROUP BY PULocationID
HAVING COUNT(*) >= 100
ORDER BY trip_count DESC
LIMIT 20;
