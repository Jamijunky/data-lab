-- Weekday vs Weekend Hourly Taxi Demand
-- Dataset: NYC TLC Yellow Taxi, January 2025
-- Compare average hourly pickups across weekdays and weekends.

WITH daily_hourly AS (
    SELECT
        CAST(tpep_pickup_datetime AS DATE) AS pickup_date,
        EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,

        CASE
            WHEN EXTRACT(DOW FROM tpep_pickup_datetime) IN (0, 6)
                THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type,

        COUNT(*) AS hourly_pickups

    FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')

    WHERE tpep_pickup_datetime >= TIMESTAMP '2025-01-01 00:00:00'
      AND tpep_pickup_datetime < TIMESTAMP '2025-02-01 00:00:00'

    GROUP BY pickup_date, pickup_hour, day_type
)

SELECT
    day_type,
    pickup_hour,
    ROUND(AVG(hourly_pickups), 0) AS avg_hourly_pickups

FROM daily_hourly

GROUP BY day_type, pickup_hour

ORDER BY pickup_hour, day_type;

