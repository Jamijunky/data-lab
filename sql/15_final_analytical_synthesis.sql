-- Iteration 15: Final Analytical Synthesis
-- Dataset: January 2025 NYC Yellow Taxi
-- Uses the enriched Parquet dataset from Iteration 12.


-- 1. Overall dataset summary

SELECT
    COUNT(*) AS total_trips,
    COUNT(DISTINCT VendorID) AS unique_vendors,
    COUNT(DISTINCT PULocationID) AS unique_pickup_locations,
    COUNT(DISTINCT DOLocationID) AS unique_dropoff_locations,

    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(MEDIAN(trip_distance), 2) AS median_distance,

    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration,
    ROUND(MEDIAN(trip_duration_minutes), 2) AS median_duration,

    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(MEDIAN(fare_amount), 2) AS median_fare,

    ROUND(AVG(total_amount), 2) AS avg_total,
    ROUND(MEDIAN(total_amount), 2) AS median_total

FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet');


-- 2. Pickup demand by borough

SELECT
    pickup_borough,
    COUNT(*) AS trip_count,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS demand_percentage

FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY pickup_borough
ORDER BY trip_count DESC;


-- 3. Top 10 pickup zones

SELECT
    pickup_borough,
    pickup_zone,
    COUNT(*) AS trip_count

FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
WHERE pickup_borough IS NOT NULL
  AND pickup_zone IS NOT NULL
GROUP BY pickup_borough, pickup_zone
ORDER BY trip_count DESC
LIMIT 10;


-- 4. Demand by hour

SELECT
    EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
    COUNT(*) AS trip_count

FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY pickup_hour
ORDER BY pickup_hour;


-- 5. Demand by weekday

SELECT
    DAYNAME(tpep_pickup_datetime) AS weekday,
    COUNT(*) AS trip_count

FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY weekday
ORDER BY
    CASE weekday
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;


-- 6. Top origin-destination borough combinations

SELECT
    pickup_borough,
    dropoff_borough,
    COUNT(*) AS trip_count,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration

FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
WHERE pickup_borough IS NOT NULL
  AND dropoff_borough IS NOT NULL
GROUP BY pickup_borough, dropoff_borough
ORDER BY trip_count DESC;


-- 7. Rate code distribution

SELECT
    RatecodeID,
    COUNT(*) AS trip_count,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY RatecodeID
ORDER BY trip_count DESC;


-- 8. Financial summary by payment type

SELECT
    payment_type,
    COUNT(*) AS trip_count,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(MEDIAN(fare_amount), 2) AS median_fare,
    ROUND(AVG(tip_amount), 2) AS avg_recorded_tip,
    ROUND(AVG(total_amount), 2) AS avg_total,

    COUNT(*) FILTER (
        WHERE fare_amount < 0
    ) AS negative_fare_records

FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY payment_type
ORDER BY trip_count DESC;


-- 9. Data quality summary

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE passenger_count IS NULL
    ) AS missing_passenger_count,

    COUNT(*) FILTER (
        WHERE trip_distance <= 0
    ) AS nonpositive_distance,

    COUNT(*) FILTER (
        WHERE trip_duration_minutes <= 0
    ) AS nonpositive_duration,

    COUNT(*) FILTER (
        WHERE fare_amount < 0
    ) AS negative_fare,

    COUNT(*) FILTER (
        WHERE total_amount < 0
    ) AS negative_total,

    COUNT(*) FILTER (
        WHERE pickup_borough IS NULL
    ) AS unmatched_pickup_borough,

    COUNT(*) FILTER (
        WHERE dropoff_borough IS NULL
    ) AS unmatched_dropoff_borough

FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet');


-- 10. Top 10 zones by pickup demand within each borough

WITH zone_demand AS (
    SELECT
        pickup_borough,
        pickup_zone,
        COUNT(*) AS trip_count

    FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
    WHERE pickup_borough IS NOT NULL
      AND pickup_zone IS NOT NULL
    GROUP BY pickup_borough, pickup_zone
),
ranked_zones AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY pickup_borough
            ORDER BY trip_count DESC, pickup_zone
        ) AS zone_rank
    FROM zone_demand
)
SELECT *
FROM ranked_zones
WHERE zone_rank <= 10
ORDER BY pickup_borough, zone_rank;


-- 11. Daily trip volume with cumulative total

WITH daily_demand AS (
    SELECT
        CAST(tpep_pickup_datetime AS DATE) AS pickup_date,
        COUNT(*) AS trip_count

    FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
    GROUP BY pickup_date
)
SELECT
    pickup_date,
    trip_count,

    SUM(trip_count) OVER (
        ORDER BY pickup_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_trips

FROM daily_demand
ORDER BY pickup_date;


-- 12. Final pipeline record-count verification

SELECT
    'Raw' AS dataset_stage,
    COUNT(*) AS record_count
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')

UNION ALL

SELECT
    'Cleaned',
    COUNT(*)
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')

UNION ALL

SELECT
    'Enriched',
    COUNT(*)
FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet');
