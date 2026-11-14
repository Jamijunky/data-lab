-- Iteration 14: Pipeline Validation
-- Run after executing python/14_taxi_data_pipeline.py


-- 1. Compare record counts across pipeline stages

SELECT 'Raw' AS stage, COUNT(*) AS records
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')

UNION ALL

SELECT 'January cleaned' AS stage, COUNT(*) AS records
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')

UNION ALL

SELECT 'Geographically enriched' AS stage, COUNT(*) AS records
FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet');


-- 2. Inspect cleaned dataset schema

DESCRIBE
SELECT *
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet');


-- 3. Inspect enriched dataset schema

DESCRIBE
SELECT *
FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet');


-- 4. Check duration validity

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE trip_duration_minutes < 0
    ) AS negative_duration,
    COUNT(*) FILTER (
        WHERE trip_duration_minutes = 0
    ) AS zero_duration,
    COUNT(*) FILTER (
        WHERE trip_duration_minutes > 0
    ) AS positive_duration
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet');


-- 5. Check enrichment coverage

SELECT
    COUNT(*) AS total_records,
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


-- 6. Check that pickup dates are within January 2025

SELECT
    MIN(tpep_pickup_datetime) AS first_pickup,
    MAX(tpep_pickup_datetime) AS last_pickup,
    COUNT(*) FILTER (
        WHERE tpep_pickup_datetime < TIMESTAMP '2025-01-01 00:00:00'
           OR tpep_pickup_datetime >= TIMESTAMP '2025-02-01 00:00:00'
    ) AS outside_january
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet');


-- 7. Inspect trip volume by pickup borough

SELECT
    pickup_borough,
    COUNT(*) AS trip_count
FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
GROUP BY pickup_borough
ORDER BY trip_count DESC;
