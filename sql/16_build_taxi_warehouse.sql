-- Iteration 16: DuckDB star-schema warehouse
-- Run from the data-lab repository root.
-- Grain: one fact_trips row per enriched source trip row.
-- No additional cleaning or aggregation is performed.

CREATE OR REPLACE TABLE dim_date AS
WITH bounds AS (
    SELECT
        MIN(CAST(tpep_pickup_datetime AS DATE)) AS min_date,
        MAX(CAST(tpep_dropoff_datetime AS DATE)) AS max_date
    FROM read_parquet(
        'data/processed/yellow_tripdata_2025-01_enriched.parquet'
    )
),
calendar AS (
    SELECT CAST(d AS DATE) AS date_value
    FROM bounds,
         generate_series(
             min_date,
             max_date,
             INTERVAL 1 DAY
         ) AS dates(d)
)
SELECT
    0 AS date_key,
    CAST(NULL AS DATE) AS date_value,
    NULL::INTEGER AS year_number,
    NULL::INTEGER AS month_number,
    NULL::INTEGER AS day_of_month,
    'Unknown' AS weekday_name,
    NULL::INTEGER AS weekday_number,
    NULL::INTEGER AS quarter_number,
    'Unknown' AS month_name,
    NULL::BOOLEAN AS is_weekend

UNION ALL

SELECT
    CAST(strftime(date_value, '%Y%m%d') AS INTEGER),
    date_value,
    year(date_value),
    month(date_value),
    day(date_value),
    dayname(date_value),
    isodow(date_value),
    quarter(date_value),
    monthname(date_value),
    isodow(date_value) IN (6, 7)
FROM calendar;


CREATE OR REPLACE TABLE dim_location AS
WITH all_locations AS (
    SELECT
        PULocationID AS location_id,
        pickup_borough AS borough,
        pickup_zone AS zone,
        pickup_service_zone AS service_zone
    FROM read_parquet(
        'data/processed/yellow_tripdata_2025-01_enriched.parquet'
    )

    UNION ALL

    SELECT
        DOLocationID,
        dropoff_borough,
        dropoff_zone,
        dropoff_service_zone
    FROM read_parquet(
        'data/processed/yellow_tripdata_2025-01_enriched.parquet'
    )
),
attributes AS (
    SELECT
        location_id,
        MAX(borough) AS borough,
        MAX(zone) AS zone,
        MAX(service_zone) AS service_zone
    FROM all_locations
    WHERE location_id IS NOT NULL
    GROUP BY location_id
),
numbered AS (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY location_id
        ) AS location_key,
        location_id,
        borough,
        zone,
        service_zone
    FROM attributes
)
SELECT
    0 AS location_key,
    CAST(NULL AS INTEGER) AS location_id,
    'Unknown' AS borough,
    'Unknown' AS zone,
    'Unknown' AS service_zone

UNION ALL

SELECT
    location_key,
    location_id,
    COALESCE(borough, 'Unknown'),
    COALESCE(zone, 'Unknown'),
    COALESCE(service_zone, 'Unknown')
FROM numbered;


CREATE OR REPLACE TABLE dim_payment AS
WITH codes AS (
    SELECT DISTINCT
        payment_type
    FROM read_parquet(
        'data/processed/yellow_tripdata_2025-01_enriched.parquet'
    )
    WHERE payment_type IS NOT NULL
),
numbered AS (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY payment_type
        ) AS payment_key,
        payment_type,
        CASE payment_type
            WHEN 0 THEN 'Unknown / unspecified'
            WHEN 1 THEN 'Credit card'
            WHEN 2 THEN 'Cash'
            WHEN 3 THEN 'No charge'
            WHEN 4 THEN 'Dispute'
            WHEN 5 THEN 'Unknown / other code'
            WHEN 6 THEN 'Voided trip'
            ELSE 'Other / unrecognized code'
        END AS payment_description
    FROM codes
)
SELECT
    0 AS payment_key,
    CAST(NULL AS BIGINT) AS payment_type,
    'Missing payment type' AS payment_description

UNION ALL

SELECT
    payment_key,
    payment_type,
    payment_description
FROM numbered;


CREATE OR REPLACE TABLE dim_vendor AS
WITH codes AS (
    SELECT DISTINCT
        VendorID
    FROM read_parquet(
        'data/processed/yellow_tripdata_2025-01_enriched.parquet'
    )
    WHERE VendorID IS NOT NULL
),
numbered AS (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY VendorID
        ) AS vendor_key,
        VendorID,
        'Vendor ' || CAST(VendorID AS VARCHAR)
            AS vendor_description
    FROM codes
)
SELECT
    0 AS vendor_key,
    CAST(NULL AS INTEGER) AS VendorID,
    'Missing vendor' AS vendor_description

UNION ALL

SELECT
    vendor_key,
    VendorID,
    vendor_description
FROM numbered;


CREATE OR REPLACE TABLE fact_trips AS
WITH source_trips AS (
    SELECT *
    FROM read_parquet(
        'data/processed/yellow_tripdata_2025-01_enriched.parquet'
    )
),
numbered_trips AS (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY
                tpep_pickup_datetime,
                tpep_dropoff_datetime,
                VendorID,
                PULocationID,
                DOLocationID,
                payment_type,
                passenger_count,
                trip_distance,
                RatecodeID,
                store_and_fwd_flag,
                fare_amount,
                extra,
                mta_tax,
                tip_amount,
                tolls_amount,
                improvement_surcharge,
                total_amount,
                congestion_surcharge,
                Airport_fee,
                cbd_congestion_fee,
                trip_duration_minutes,
                pickup_borough,
                pickup_zone,
                pickup_service_zone,
                dropoff_borough,
                dropoff_zone,
                dropoff_service_zone
        ) AS trip_key,
        *
    FROM source_trips
)
SELECT
    t.trip_key,

    COALESCE(pd.date_key, 0)
        AS pickup_date_key,

    COALESCE(dd.date_key, 0)
        AS dropoff_date_key,

    COALESCE(pl.location_key, 0)
        AS pickup_location_key,

    COALESCE(dl.location_key, 0)
        AS dropoff_location_key,

    COALESCE(pm.payment_key, 0)
        AS payment_key,

    COALESCE(v.vendor_key, 0)
        AS vendor_key,

    -- Original source attributes
    t.tpep_pickup_datetime AS pickup_timestamp,
    t.tpep_dropoff_datetime AS dropoff_timestamp,
    t.RatecodeID AS rate_code_id,
    t.store_and_fwd_flag,

    -- Measures
    t.passenger_count,
    t.trip_distance,
    t.trip_duration_minutes,
    t.fare_amount,
    t.extra AS extra_amount,
    t.mta_tax,
    t.tip_amount,
    t.tolls_amount,
    t.improvement_surcharge,
    t.total_amount,
    t.congestion_surcharge,
    t.Airport_fee AS airport_fee,
    t.cbd_congestion_fee

FROM numbered_trips t

LEFT JOIN dim_date pd
    ON pd.date_value =
       CAST(t.tpep_pickup_datetime AS DATE)

LEFT JOIN dim_date dd
    ON dd.date_value =
       CAST(t.tpep_dropoff_datetime AS DATE)

LEFT JOIN dim_location pl
    ON pl.location_id IS NOT DISTINCT FROM t.PULocationID

LEFT JOIN dim_location dl
    ON dl.location_id IS NOT DISTINCT FROM t.DOLocationID

LEFT JOIN dim_payment pm
    ON pm.payment_type IS NOT DISTINCT FROM t.payment_type

LEFT JOIN dim_vendor v
    ON v.VendorID IS NOT DISTINCT FROM t.VendorID;
