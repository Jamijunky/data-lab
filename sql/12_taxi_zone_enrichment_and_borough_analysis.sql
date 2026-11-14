-- Iteration 12: Taxi Zone Enrichment and Borough-Level Analysis
-- Trip dataset: January 2025 duration-cleaned Yellow Taxi data
-- Reference dataset: NYC TLC Taxi Zone Lookup


-- 1. Inspect the lookup table

SELECT *
FROM read_csv_auto('data/raw/taxi_zone_lookup.csv')
LIMIT 10;


-- 2. Check lookup table size and key uniqueness

SELECT
    COUNT(*) AS lookup_records,
    COUNT(DISTINCT LocationID) AS unique_location_ids,
    COUNT(*) - COUNT(DISTINCT LocationID) AS duplicate_location_ids
FROM read_csv_auto('data/raw/taxi_zone_lookup.csv');


-- 3. Inspect borough and service-zone categories

SELECT
    Borough,
    service_zone,
    COUNT(*) AS zone_count
FROM read_csv_auto('data/raw/taxi_zone_lookup.csv')
GROUP BY Borough, service_zone
ORDER BY Borough, service_zone;


-- 4. Check NULL values in the lookup table

SELECT
    COUNT(*) FILTER (WHERE LocationID IS NULL) AS missing_location_id,
    COUNT(*) FILTER (WHERE Borough IS NULL) AS missing_borough,
    COUNT(*) FILTER (WHERE Zone IS NULL) AS missing_zone,
    COUNT(*) FILTER (WHERE service_zone IS NULL) AS missing_service_zone
FROM read_csv_auto('data/raw/taxi_zone_lookup.csv');


-- 5. Check pickup IDs without a matching lookup entry

SELECT
    t.PULocationID,
    COUNT(*) AS trip_count
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet') t
LEFT JOIN read_csv_auto('data/raw/taxi_zone_lookup.csv') z
    ON t.PULocationID = z.LocationID
WHERE t.PULocationID IS NOT NULL
  AND z.LocationID IS NULL
GROUP BY t.PULocationID
ORDER BY trip_count DESC;


-- 6. Check drop-off IDs without a matching lookup entry

SELECT
    t.DOLocationID,
    COUNT(*) AS trip_count
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet') t
LEFT JOIN read_csv_auto('data/raw/taxi_zone_lookup.csv') z
    ON t.DOLocationID = z.LocationID
WHERE t.DOLocationID IS NOT NULL
  AND z.LocationID IS NULL
GROUP BY t.DOLocationID
ORDER BY trip_count DESC;


-- 7. Create enriched trip data
-- Two LEFT JOINs are required because each trip has two endpoints.

COPY (
    SELECT
        t.*,

        pu.Borough AS pickup_borough,
        pu.Zone AS pickup_zone,
        pu.service_zone AS pickup_service_zone,

        dst.Borough AS dropoff_borough,
        dst.Zone AS dropoff_zone,
        dst.service_zone AS dropoff_service_zone

    FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet') t

    LEFT JOIN read_csv_auto('data/raw/taxi_zone_lookup.csv') pu
        ON t.PULocationID = pu.LocationID

    LEFT JOIN read_csv_auto('data/raw/taxi_zone_lookup.csv') dst
        ON t.DOLocationID = dst.LocationID

) TO 'data/processed/yellow_tripdata_2025-01_enriched.parquet'
(FORMAT PARQUET);


-- 8. Validate enriched dataset record count

SELECT
    (SELECT COUNT(*)
     FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet'))
        AS original_records,

    (SELECT COUNT(*)
     FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet'))
        AS enriched_records;


-- 9. Pickup demand by borough

SELECT
    pickup_borough,
    COUNT(*) AS pickup_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY pickup_borough
ORDER BY pickup_count DESC;


-- 10. Drop-off demand by borough

SELECT
    dropoff_borough,
    COUNT(*) AS dropoff_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY dropoff_borough
ORDER BY dropoff_count DESC;


-- 11. Compare pickup and drop-off counts by borough

WITH pickup_counts AS (
    SELECT
        pickup_borough AS borough,
        COUNT(*) AS pickups
    FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
    GROUP BY pickup_borough
),
dropoff_counts AS (
    SELECT
        dropoff_borough AS borough,
        COUNT(*) AS dropoffs
    FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
    GROUP BY dropoff_borough
)
SELECT
    COALESCE(p.borough, d.borough) AS borough,
    COALESCE(p.pickups, 0) AS pickups,
    COALESCE(d.dropoffs, 0) AS dropoffs,
    COALESCE(p.pickups, 0) - COALESCE(d.dropoffs, 0) AS endpoint_difference
FROM pickup_counts p
FULL OUTER JOIN dropoff_counts d
    ON p.borough = d.borough
ORDER BY pickups DESC;


-- 12. Top pickup zones

SELECT
    pickup_borough,
    pickup_zone,
    PULocationID,
    COUNT(*) AS pickup_count
FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY pickup_borough, pickup_zone, PULocationID
ORDER BY pickup_count DESC
LIMIT 20;


-- 13. Top drop-off zones

SELECT
    dropoff_borough,
    dropoff_zone,
    DOLocationID,
    COUNT(*) AS dropoff_count
FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY dropoff_borough, dropoff_zone, DOLocationID
ORDER BY dropoff_count DESC
LIMIT 20;


-- 14. Trips between boroughs

SELECT
    pickup_borough,
    dropoff_borough,
    COUNT(*) AS trip_count,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration,
    ROUND(AVG(fare_amount), 2) AS avg_fare
FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY pickup_borough, dropoff_borough
ORDER BY trip_count DESC;


-- 15. Top origin-destination zone pairs

SELECT
    pickup_borough,
    pickup_zone,
    dropoff_borough,
    dropoff_zone,
    COUNT(*) AS trip_count,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration
FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY
    pickup_borough,
    pickup_zone,
    dropoff_borough,
    dropoff_zone
ORDER BY trip_count DESC
LIMIT 30;


-- 16. Average trip characteristics by pickup borough

SELECT
    pickup_borough,
    COUNT(*) AS trip_count,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(MEDIAN(trip_distance), 2) AS median_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration,
    ROUND(MEDIAN(trip_duration_minutes), 2) AS median_duration,
    ROUND(AVG(fare_amount), 2) AS avg_fare
FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY pickup_borough
ORDER BY trip_count DESC;


-- 17. Trips grouped by service-zone combination

SELECT
    pickup_service_zone,
    dropoff_service_zone,
    COUNT(*) AS trip_count,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration
FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY pickup_service_zone, dropoff_service_zone
ORDER BY trip_count DESC;


-- 18. Overall enrichment coverage

SELECT
    COUNT(*) AS total_trips,

    COUNT(*) FILTER (
        WHERE pickup_borough IS NOT NULL
    ) AS matched_pickups,

    COUNT(*) FILTER (
        WHERE pickup_borough IS NULL
    ) AS unmatched_pickups,

    COUNT(*) FILTER (
        WHERE dropoff_borough IS NOT NULL
    ) AS matched_dropoffs,

    COUNT(*) FILTER (
        WHERE dropoff_borough IS NULL
    ) AS unmatched_dropoffs

FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet');
