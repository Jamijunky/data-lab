-- Iteration 9: Rate Code and Fare Component Analysis
-- Dataset: January 2025 NYC Yellow Taxi
-- Source: duration-cleaned Parquet dataset

-- 1. Rate code distribution
SELECT
    RatecodeID,
    COUNT(*) AS trip_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY RatecodeID
ORDER BY trip_count DESC;


-- 2. Trip characteristics by rate code
SELECT
    RatecodeID,
    COUNT(*) AS trip_count,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(MEDIAN(trip_distance), 2) AS median_distance,
    ROUND(AVG(trip_duration_minutes), 2) AS avg_duration,
    ROUND(MEDIAN(trip_duration_minutes), 2) AS median_duration,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(MEDIAN(fare_amount), 2) AS median_fare,
    ROUND(AVG(total_amount), 2) AS avg_total
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY RatecodeID
ORDER BY trip_count DESC;


-- 3. Fare and total amount distribution by rate code
SELECT
    RatecodeID,
    COUNT(*) AS trip_count,
    MIN(fare_amount) AS min_fare,
    QUANTILE_CONT(fare_amount, 0.25) AS q1_fare,
    MEDIAN(fare_amount) AS median_fare,
    QUANTILE_CONT(fare_amount, 0.75) AS q3_fare,
    MAX(fare_amount) AS max_fare,
    MIN(total_amount) AS min_total,
    MEDIAN(total_amount) AS median_total,
    MAX(total_amount) AS max_total
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY RatecodeID
ORDER BY trip_count DESC;


-- 4. Summary of individual fare components
SELECT
    COUNT(*) AS total_trips,

    COUNT(*) FILTER (WHERE fare_amount > 0) AS positive_fare,
    COUNT(*) FILTER (WHERE fare_amount = 0) AS zero_fare,
    COUNT(*) FILTER (WHERE fare_amount < 0) AS negative_fare,

    COUNT(*) FILTER (WHERE extra > 0) AS trips_with_extra,
    COUNT(*) FILTER (WHERE mta_tax > 0) AS trips_with_mta_tax,
    COUNT(*) FILTER (WHERE tip_amount > 0) AS trips_with_tip,
    COUNT(*) FILTER (WHERE tolls_amount > 0) AS trips_with_tolls,
    COUNT(*) FILTER (WHERE improvement_surcharge > 0) AS trips_with_improvement_surcharge,
    COUNT(*) FILTER (WHERE congestion_surcharge > 0) AS trips_with_congestion_surcharge,
    COUNT(*) FILTER (WHERE airport_fee > 0) AS trips_with_airport_fee,
    COUNT(*) FILTER (WHERE cbd_congestion_fee > 0) AS trips_with_cbd_fee

FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet');


-- 5. Average and median fare component amounts
SELECT
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(MEDIAN(fare_amount), 2) AS median_fare,

    ROUND(AVG(extra), 2) AS avg_extra,
    ROUND(MEDIAN(extra), 2) AS median_extra,

    ROUND(AVG(mta_tax), 2) AS avg_mta_tax,
    ROUND(MEDIAN(mta_tax), 2) AS median_mta_tax,

    ROUND(AVG(tip_amount), 2) AS avg_tip,
    ROUND(MEDIAN(tip_amount), 2) AS median_tip,

    ROUND(AVG(tolls_amount), 2) AS avg_tolls,
    ROUND(MEDIAN(tolls_amount), 2) AS median_tolls,

    ROUND(AVG(improvement_surcharge), 2) AS avg_improvement_surcharge,
    ROUND(MEDIAN(improvement_surcharge), 2) AS median_improvement_surcharge,

    ROUND(AVG(congestion_surcharge), 2) AS avg_congestion_surcharge,
    ROUND(MEDIAN(congestion_surcharge), 2) AS median_congestion_surcharge,

    ROUND(AVG(airport_fee), 2) AS avg_airport_fee,
    ROUND(MEDIAN(airport_fee), 2) AS median_airport_fee,

    ROUND(AVG(cbd_congestion_fee), 2) AS avg_cbd_fee,
    ROUND(MEDIAN(cbd_congestion_fee), 2) AS median_cbd_fee,

    ROUND(AVG(total_amount), 2) AS avg_total,
    ROUND(MEDIAN(total_amount), 2) AS median_total

FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet');


-- 6. Fare component distribution by rate code
SELECT
    RatecodeID,
    COUNT(*) AS trip_count,
    ROUND(AVG(fare_amount), 2) AS avg_fare,
    ROUND(AVG(extra), 2) AS avg_extra,
    ROUND(AVG(mta_tax), 2) AS avg_mta_tax,
    ROUND(AVG(tolls_amount), 2) AS avg_tolls,
    ROUND(AVG(improvement_surcharge), 2) AS avg_improvement_surcharge,
    ROUND(AVG(congestion_surcharge), 2) AS avg_congestion_surcharge,
    ROUND(AVG(airport_fee), 2) AS avg_airport_fee,
    ROUND(AVG(cbd_congestion_fee), 2) AS avg_cbd_fee,
    ROUND(AVG(total_amount), 2) AS avg_total
FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY RatecodeID
ORDER BY trip_count DESC;


-- 7. Reconstruct total amount from listed components
SELECT
    COUNT(*) AS trip_count,

    ROUND(AVG(total_amount), 2) AS avg_recorded_total,
    ROUND(AVG(
        fare_amount
        + extra
        + mta_tax
        + tip_amount
        + tolls_amount
        + improvement_surcharge
        + congestion_surcharge
        + airport_fee
        + cbd_congestion_fee
    ), 2) AS avg_reconstructed_total,

    ROUND(AVG(
        total_amount
        - (
            fare_amount
            + extra
            + mta_tax
            + tip_amount
            + tolls_amount
            + improvement_surcharge
            + congestion_surcharge
            + airport_fee
            + cbd_congestion_fee
        )
    ), 4) AS avg_difference,

    COUNT(*) FILTER (
        WHERE ABS(
            total_amount
            - (
                fare_amount
                + extra
                + mta_tax
                + tip_amount
                + tolls_amount
                + improvement_surcharge
                + congestion_surcharge
                + airport_fee
                + cbd_congestion_fee
            )
        ) > 0.01
    ) AS records_with_difference

FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet');


-- 8. Reconciliation differences by rate code
SELECT
    RatecodeID,
    COUNT(*) AS trip_count,

    ROUND(AVG(
        total_amount
        - (
            fare_amount
            + extra
            + mta_tax
            + tip_amount
            + tolls_amount
            + improvement_surcharge
            + congestion_surcharge
            + airport_fee
            + cbd_congestion_fee
        )
    ), 4) AS avg_difference,

    COUNT(*) FILTER (
        WHERE ABS(
            total_amount
            - (
                fare_amount
                + extra
                + mta_tax
                + tip_amount
                + tolls_amount
                + improvement_surcharge
                + congestion_surcharge
                + airport_fee
                + cbd_congestion_fee
            )
        ) > 0.01
    ) AS records_with_difference

FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY RatecodeID
ORDER BY trip_count DESC;


-- 9. Congestion Relief Zone fee before and after January 5, 2025
SELECT
    CASE
        WHEN tpep_pickup_datetime < TIMESTAMP '2025-01-05 00:00:00'
            THEN 'Before Jan 5'
        ELSE 'Jan 5 onward'
    END AS period,

    COUNT(*) AS trip_count,

    COUNT(*) FILTER (
        WHERE cbd_congestion_fee > 0
    ) AS trips_with_cbd_fee,

    ROUND(AVG(cbd_congestion_fee), 2) AS avg_cbd_fee,
    ROUND(AVG(total_amount), 2) AS avg_total

FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY period
ORDER BY period;


-- 10. Congestion Relief Zone fee by pickup location
SELECT
    PULocationID,
    COUNT(*) AS trip_count,

    COUNT(*) FILTER (
        WHERE cbd_congestion_fee > 0
    ) AS trips_with_cbd_fee,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE cbd_congestion_fee > 0
        ) / COUNT(*),
        2
    ) AS cbd_fee_percentage,

    ROUND(AVG(cbd_congestion_fee), 2) AS avg_cbd_fee,
    ROUND(AVG(total_amount), 2) AS avg_total

FROM read_parquet('data/processed/yellow_tripdata_2025-01_cleaned.parquet')
GROUP BY PULocationID
HAVING COUNT(*) >= 100
ORDER BY cbd_fee_percentage DESC;
