-- Iteration 10: Time-Based Demand and Fare Analysis
-- Dataset: January 2025 NYC Yellow Taxi
-- Source: duration-cleaned Parquet dataset


-- 1. Demand by hour
SELECT
    EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
    COUNT(*) AS trip_count
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY pickup_hour
ORDER BY pickup_hour;


-- 2. Demand by weekday
SELECT
    DAYNAME(tpep_pickup_datetime) AS weekday,
    COUNT(*) AS trip_count
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
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


-- 3. Demand by weekday and hour
SELECT
    DAYNAME(tpep_pickup_datetime) AS weekday,
    EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
    COUNT(*) AS trip_count
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY weekday, pickup_hour
ORDER BY
    CASE weekday
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END,
    pickup_hour;


-- 4. Weekday versus weekend demand
SELECT
    CASE
        WHEN DAYOFWEEK(tpep_pickup_datetime) IN (0, 6)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS trip_count,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(MEDIAN(trip_distance), 2) AS median_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration,
    ROUND(MEDIAN(trip_duration_minutes), 2) AS median_duration
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY day_type;


-- 5. Trip characteristics by hour
SELECT
    EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
    COUNT(*) AS trip_count,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(MEDIAN(trip_distance), 2) AS median_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration,
    ROUND(MEDIAN(trip_duration_minutes), 2) AS median_duration
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY pickup_hour
ORDER BY pickup_hour;


-- 6. Fare characteristics by hour
SELECT
    EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
    COUNT(*) AS trip_count,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(MEDIAN(fare_amount), 2) AS median_fare,
    ROUND(AVG(total_amount), 2) AS avg_total,
    ROUND(MEDIAN(total_amount), 2) AS median_total
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY pickup_hour
ORDER BY pickup_hour;


-- 7. Fare characteristics by weekday
SELECT
    DAYNAME(tpep_pickup_datetime) AS weekday,
    COUNT(*) AS trip_count,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(MEDIAN(fare_amount), 2) AS median_fare,
    ROUND(AVG(total_amount), 2) AS avg_total,
    ROUND(MEDIAN(total_amount), 2) AS median_total
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
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


-- 8. Fare characteristics by weekday and hour
SELECT
    DAYNAME(tpep_pickup_datetime) AS weekday,
    EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
    COUNT(*) AS trip_count,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(MEDIAN(fare_amount), 2) AS median_fare,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY weekday, pickup_hour
HAVING COUNT(*) >= 100
ORDER BY
    CASE weekday
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END,
    pickup_hour;


-- 9. Recorded credit-card tips by hour
-- Cash tips are not included in tip_amount.
SELECT
    EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
    COUNT(*) AS credit_card_trips,
    COUNT(*) FILTER (WHERE tip_amount > 0) AS trips_with_recorded_tip,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE tip_amount > 0) / COUNT(*),
        2
    ) AS recorded_tip_rate,
    ROUND(AVG(tip_amount), 2) AS avg_recorded_tip,
    ROUND(MEDIAN(tip_amount), 2) AS median_recorded_tip
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
WHERE payment_type = 1
GROUP BY pickup_hour
ORDER BY pickup_hour;


-- 10. Demand by date
SELECT
    CAST(tpep_pickup_datetime AS DATE) AS pickup_date,
    COUNT(*) AS trip_count,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration,
    ROUND(AVG(fare_amount), 2) AS avg_fare
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY pickup_date
ORDER BY pickup_date;


-- 11. Compare rush-hour periods with other hours
-- Rush-hour definition here is an analytical choice:
-- weekday 7-10 AM and 4-7 PM.
WITH classified_trips AS (
    SELECT
        *,
        CASE
            WHEN DAYOFWEEK(tpep_pickup_datetime) NOT IN (0, 6)
                AND (
                    EXTRACT(HOUR FROM tpep_pickup_datetime) BETWEEN 7 AND 9
                    OR EXTRACT(HOUR FROM tpep_pickup_datetime) BETWEEN 16 AND 18
                )
            THEN 'Weekday rush hour'
            ELSE 'Other periods'
        END AS time_period
    FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
)
SELECT
    time_period,
    COUNT(*) AS trip_count,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(MEDIAN(trip_distance), 2) AS median_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration,
    ROUND(MEDIAN(trip_duration_minutes), 2) AS median_duration,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(MEDIAN(fare_amount), 2) AS median_fare
FROM classified_trips
GROUP BY time_period;
