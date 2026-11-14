-- Iteration 13: Advanced Analytical SQL
-- Dataset: January 2025 NYC Yellow Taxi enriched data


-- 1. CTE: Calculate pickup demand by borough, then rank boroughs.

WITH borough_demand AS (
    SELECT
        pickup_borough,
        COUNT(*) AS trip_count
    FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
    GROUP BY pickup_borough
),
ranked_boroughs AS (
    SELECT
        pickup_borough,
        trip_count,
        RANK() OVER (ORDER BY trip_count DESC) AS demand_rank
    FROM borough_demand
)
SELECT *
FROM ranked_boroughs
ORDER BY demand_rank;


-- 2. Top five pickup zones within each borough.
-- RANK preserves ties, so more than five rows may be returned per borough.

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
        RANK() OVER (
            PARTITION BY pickup_borough
            ORDER BY trip_count DESC
        ) AS zone_rank
    FROM zone_demand
)
SELECT *
FROM ranked_zones
WHERE zone_rank <= 5
ORDER BY pickup_borough, zone_rank;


-- 3. Exactly five pickup zones per borough using ROW_NUMBER.
-- Ties are resolved alphabetically by zone name.

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
        ) AS row_num
    FROM zone_demand
)
SELECT *
FROM ranked_zones
WHERE row_num <= 5
ORDER BY pickup_borough, row_num;


-- 4. Daily demand with running total and previous-day comparison.

WITH daily_demand AS (
    SELECT
        CAST(tpep_pickup_datetime AS DATE) AS pickup_date,
        COUNT(*) AS trip_count
    FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
    GROUP BY pickup_date
),
daily_comparison AS (
    SELECT
        pickup_date,
        trip_count,

        SUM(trip_count) OVER (
            ORDER BY pickup_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_total,

        LAG(trip_count) OVER (
            ORDER BY pickup_date
        ) AS previous_day_trips

    FROM daily_demand
)
SELECT
    pickup_date,
    trip_count,
    running_total,
    previous_day_trips,

    trip_count - previous_day_trips AS daily_change,

    ROUND(
        100.0 * (trip_count - previous_day_trips)
        / NULLIF(previous_day_trips, 0),
        2
    ) AS percentage_change

FROM daily_comparison
ORDER BY pickup_date;


-- 5. Rank the busiest hours separately for each weekday.

WITH hourly_demand AS (
    SELECT
        DAYNAME(tpep_pickup_datetime) AS weekday,
        EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
        COUNT(*) AS trip_count
    FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
    GROUP BY weekday, pickup_hour
),
ranked_hours AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY weekday
            ORDER BY trip_count DESC, pickup_hour
        ) AS hour_rank
    FROM hourly_demand
)
SELECT *
FROM ranked_hours
WHERE hour_rank <= 3
ORDER BY weekday, hour_rank;


-- 6. Compare each zone's demand with its borough's average zone demand.

WITH zone_demand AS (
    SELECT
        pickup_borough,
        pickup_zone,
        COUNT(*) AS trip_count
    FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
    WHERE pickup_borough IS NOT NULL
      AND pickup_zone IS NOT NULL
    GROUP BY pickup_borough, pickup_zone
)
SELECT
    pickup_borough,
    pickup_zone,
    trip_count,

    ROUND(
        AVG(trip_count) OVER (
            PARTITION BY pickup_borough
        ),
        2
    ) AS borough_average_zone_demand,

    ROUND(
        trip_count - AVG(trip_count) OVER (
            PARTITION BY pickup_borough
        ),
        2
    ) AS difference_from_borough_average

FROM zone_demand
ORDER BY pickup_borough, trip_count DESC;


-- 7. Trip duration percentiles by pickup borough.

SELECT
    pickup_borough,
    COUNT(*) AS trip_count,

    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration,
    ROUND(MEDIAN(trip_duration_minutes), 2) AS median_duration,

    ROUND(
        QUANTILE_CONT(trip_duration_minutes, 0.90),
        2
    ) AS percentile_90_duration,

    ROUND(
        QUANTILE_CONT(trip_duration_minutes, 0.95),
        2
    ) AS percentile_95_duration

FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
WHERE pickup_borough IS NOT NULL
  AND trip_duration_minutes > 0
GROUP BY pickup_borough
ORDER BY trip_count DESC;


-- 8. Rank common origin-destination pairs within each pickup borough.

WITH route_demand AS (
    SELECT
        pickup_borough,
        pickup_zone,
        dropoff_borough,
        dropoff_zone,
        COUNT(*) AS trip_count
    FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
    WHERE pickup_borough IS NOT NULL
      AND pickup_zone IS NOT NULL
      AND dropoff_borough IS NOT NULL
      AND dropoff_zone IS NOT NULL
    GROUP BY
        pickup_borough,
        pickup_zone,
        dropoff_borough,
        dropoff_zone
),
ranked_routes AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY pickup_borough
            ORDER BY trip_count DESC,
                     pickup_zone,
                     dropoff_zone
        ) AS route_rank
    FROM route_demand
)
SELECT *
FROM ranked_routes
WHERE route_rank <= 5
ORDER BY pickup_borough, route_rank;


-- 9. Compare each trip's fare with the average fare in its pickup borough.
-- This query preserves individual trip rows.

SELECT
    pickup_borough,
    pickup_zone,
    fare_amount,

    ROUND(
        AVG(fare_amount) OVER (
            PARTITION BY pickup_borough
        ),
        2
    ) AS borough_average_fare,

    ROUND(
        fare_amount - AVG(fare_amount) OVER (
            PARTITION BY pickup_borough
        ),
        2
    ) AS difference_from_borough_average

FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
WHERE pickup_borough IS NOT NULL
  AND fare_amount IS NOT NULL
LIMIT 100;


-- 10. Compare each borough's share of total pickup demand.

WITH borough_demand AS (
    SELECT
        pickup_borough,
        COUNT(*) AS trip_count
    FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
    WHERE pickup_borough IS NOT NULL
    GROUP BY pickup_borough
)
SELECT
    pickup_borough,
    trip_count,

    ROUND(
        100.0 * trip_count
        / SUM(trip_count) OVER (),
        2
    ) AS demand_percentage,

    SUM(trip_count) OVER (
        ORDER BY trip_count DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_trips

FROM borough_demand
ORDER BY trip_count DESC;


-- 11. Compare RANK, DENSE_RANK, and ROW_NUMBER.
-- All three use the same ordering, but handle ties differently.

WITH zone_demand AS (
    SELECT
        pickup_borough,
        pickup_zone,
        COUNT(*) AS trip_count
    FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
    WHERE pickup_borough IS NOT NULL
      AND pickup_zone IS NOT NULL
    GROUP BY pickup_borough, pickup_zone
)
SELECT
    pickup_borough,
    pickup_zone,
    trip_count,

    ROW_NUMBER() OVER (
        PARTITION BY pickup_borough
        ORDER BY trip_count DESC
    ) AS row_number_rank,

    RANK() OVER (
        PARTITION BY pickup_borough
        ORDER BY trip_count DESC
    ) AS rank_value,

    DENSE_RANK() OVER (
        PARTITION BY pickup_borough
        ORDER BY trip_count DESC
    ) AS dense_rank_value

FROM zone_demand
ORDER BY pickup_borough, trip_count DESC;


-- 12. Compare hourly demand with the previous hour within each weekday.

WITH hourly_demand AS (
    SELECT
        DAYNAME(tpep_pickup_datetime) AS weekday,
        EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
        COUNT(*) AS trip_count
    FROM read_parquet('data/processed/yellow_tripdata_2025-01_enriched.parquet')
    GROUP BY weekday, pickup_hour
)
SELECT
    weekday,
    pickup_hour,
    trip_count,

    LAG(trip_count) OVER (
        PARTITION BY weekday
        ORDER BY pickup_hour
    ) AS previous_hour_trips,

    trip_count - LAG(trip_count) OVER (
        PARTITION BY weekday
        ORDER BY pickup_hour
    ) AS change_from_previous_hour

FROM hourly_demand
ORDER BY weekday, pickup_hour;
