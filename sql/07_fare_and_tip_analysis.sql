-- Iteration 7: Fare and Tip Analysis
-- Dataset: NYC Yellow Taxi January 2025
-- Source: Duration-cleaned Parquet dataset


-- 1. Baseline fare and tip statistics

SELECT
    COUNT(*) AS total_records,
    AVG(fare_amount) AS avg_fare,
    MEDIAN(fare_amount) AS median_fare,
    AVG(trip_distance) AS avg_distance,
    MEDIAN(trip_distance) AS median_distance,
    AVG(trip_duration_minutes) AS avg_duration,
    MEDIAN(trip_duration_minutes) AS median_duration
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE fare_amount >= 0
  AND trip_distance > 0
  AND trip_duration_minutes > 0;


-- 2. Fare and distance correlation
-- Excludes distance/speed anomalies identified in Iteration 5.

WITH valid_trips AS (
    SELECT
        fare_amount,
        trip_distance,
        trip_duration_minutes,
        trip_distance / (trip_duration_minutes / 60.0) AS avg_speed_mph
    FROM read_parquet(
        'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
    )
    WHERE fare_amount >= 0
      AND trip_distance > 0
      AND trip_duration_minutes > 0
)
SELECT
    COUNT(*) AS records_analyzed,
    CORR(fare_amount, trip_distance) AS fare_distance_correlation,
    CORR(fare_amount, trip_duration_minutes) AS fare_duration_correlation,
    CORR(trip_distance, trip_duration_minutes) AS distance_duration_correlation
FROM valid_trips
WHERE avg_speed_mph <= 100;


-- 3. Fare distribution by distance group

WITH valid_trips AS (
    SELECT
        fare_amount,
        trip_distance,
        trip_duration_minutes,
        trip_distance / (trip_duration_minutes / 60.0) AS avg_speed_mph
    FROM read_parquet(
        'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
    )
    WHERE fare_amount >= 0
      AND trip_distance > 0
      AND trip_duration_minutes > 0
),
distance_groups AS (
    SELECT
        *,
        CASE
            WHEN trip_distance <= 2 THEN '0-2 miles'
            WHEN trip_distance <= 5 THEN '2-5 miles'
            WHEN trip_distance <= 10 THEN '5-10 miles'
            WHEN trip_distance <= 20 THEN '10-20 miles'
            ELSE '20+ miles'
        END AS distance_group
    FROM valid_trips
    WHERE avg_speed_mph <= 100
)
SELECT
    distance_group,
    COUNT(*) AS trip_count,
    AVG(fare_amount) AS avg_fare,
    MEDIAN(fare_amount) AS median_fare,
    AVG(trip_distance) AS avg_distance,
    AVG(trip_duration_minutes) AS avg_duration
FROM distance_groups
GROUP BY distance_group
ORDER BY
    CASE distance_group
        WHEN '0-2 miles' THEN 1
        WHEN '2-5 miles' THEN 2
        WHEN '5-10 miles' THEN 3
        WHEN '10-20 miles' THEN 4
        ELSE 5
    END;


-- 4. Fare distribution by trip duration

SELECT
    CASE
        WHEN trip_duration_minutes <= 5 THEN '0-5 minutes'
        WHEN trip_duration_minutes <= 10 THEN '5-10 minutes'
        WHEN trip_duration_minutes <= 20 THEN '10-20 minutes'
        WHEN trip_duration_minutes <= 40 THEN '20-40 minutes'
        ELSE '40+ minutes'
    END AS duration_group,
    COUNT(*) AS trip_count,
    AVG(fare_amount) AS avg_fare,
    MEDIAN(fare_amount) AS median_fare,
    AVG(trip_distance) AS avg_distance
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE fare_amount >= 0
  AND trip_duration_minutes > 0
GROUP BY duration_group
ORDER BY
    CASE duration_group
        WHEN '0-5 minutes' THEN 1
        WHEN '5-10 minutes' THEN 2
        WHEN '10-20 minutes' THEN 3
        WHEN '20-40 minutes' THEN 4
        ELSE 5
    END;


-- 5. Tip summary by payment type

SELECT
    payment_type,
    COUNT(*) AS trip_count,
    COUNT(*) FILTER (
        WHERE tip_amount > 0
    ) AS positive_tip_records,
    COUNT(*) FILTER (
        WHERE tip_amount = 0
    ) AS zero_tip_records,
    AVG(tip_amount) AS avg_tip,
    MEDIAN(tip_amount) AS median_tip
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
GROUP BY payment_type
ORDER BY payment_type;


-- 6. Tip analysis for credit-card trips only
-- Payment type 1 = credit card.
-- Cash tips are not recorded in tip_amount.

SELECT
    COUNT(*) AS credit_card_trips,
    COUNT(*) FILTER (
        WHERE tip_amount > 0
    ) AS positive_tip_trips,
    COUNT(*) FILTER (
        WHERE tip_amount = 0
    ) AS zero_tip_trips,
    AVG(tip_amount) AS avg_recorded_tip,
    MEDIAN(tip_amount) AS median_recorded_tip,
    AVG(
        CASE
            WHEN fare_amount > 0
            THEN tip_amount / fare_amount * 100
        END
    ) AS avg_tip_percentage
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE payment_type = 1
  AND fare_amount > 0
  AND tip_amount >= 0;


-- 7. Tip percentage distribution
-- Only credit-card trips with positive fares and tips.

SELECT
    CASE
        WHEN tip_amount = 0 THEN '0%'
        WHEN tip_amount / fare_amount <= 0.10 THEN '0-10%'
        WHEN tip_amount / fare_amount <= 0.15 THEN '10-15%'
        WHEN tip_amount / fare_amount <= 0.20 THEN '15-20%'
        WHEN tip_amount / fare_amount <= 0.25 THEN '20-25%'
        ELSE '25%+'
    END AS tip_percentage_group,
    COUNT(*) AS trip_count
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE payment_type = 1
  AND fare_amount > 0
  AND tip_amount >= 0
GROUP BY tip_percentage_group
ORDER BY
    CASE tip_percentage_group
        WHEN '0%' THEN 1
        WHEN '0-10%' THEN 2
        WHEN '10-15%' THEN 3
        WHEN '15-20%' THEN 4
        WHEN '20-25%' THEN 5
        ELSE 6
    END;


-- 8. Tip amount by fare group
-- Credit-card transactions only.

SELECT
    CASE
        WHEN fare_amount <= 10 THEN '0-10 dollars'
        WHEN fare_amount <= 20 THEN '10-20 dollars'
        WHEN fare_amount <= 40 THEN '20-40 dollars'
        WHEN fare_amount <= 60 THEN '40-60 dollars'
        ELSE '60+ dollars'
    END AS fare_group,
    COUNT(*) AS trip_count,
    AVG(tip_amount) AS avg_tip,
    MEDIAN(tip_amount) AS median_tip,
    AVG(
        tip_amount / fare_amount * 100
    ) AS avg_tip_percentage
FROM read_parquet(
    'data/processed/yellow_tripdata_2025-01_cleaned.parquet'
)
WHERE payment_type = 1
  AND fare_amount > 0
  AND tip_amount >= 0
GROUP BY fare_group
ORDER BY
    CASE fare_group
        WHEN '0-10 dollars' THEN 1
        WHEN '10-20 dollars' THEN 2
        WHEN '20-40 dollars' THEN 3
        WHEN '40-60 dollars' THEN 4
        ELSE 5
    END;
