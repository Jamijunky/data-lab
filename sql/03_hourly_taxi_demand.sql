-- Analysis: Hourly taxi pickup demand
-- Dataset: NYC Yellow Taxi, January 2025
-- Purpose: Count pickups by hour of day

SELECT
    EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
    COUNT(*) AS total_trips
FROM read_parquet('data/raw/yellow_tripdata_2025-01.parquet')
WHERE tpep_pickup_datetime >= TIMESTAMP '2025-01-01 00:00:00'
  AND tpep_pickup_datetime < TIMESTAMP '2025-02-01 00:00:00'
GROUP BY pickup_hour
ORDER BY pickup_hour;

