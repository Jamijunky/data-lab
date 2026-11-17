-- Iteration 18: Incremental loading
-- Input: temporary table stg_trip_batch
-- The Python runner creates the staging table for each date range.

CREATE TABLE IF NOT EXISTS load_batches (
    batch_id VARCHAR PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    rows_loaded BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_key INTEGER PRIMARY KEY,
    date_value DATE UNIQUE,
    year_number INTEGER,
    month_number INTEGER,
    day_of_month INTEGER,
    weekday_name VARCHAR,
    weekday_number INTEGER,
    quarter_number INTEGER,
    month_name VARCHAR,
    is_weekend BOOLEAN
);

CREATE TABLE IF NOT EXISTS dim_location (
    location_key BIGINT PRIMARY KEY,
    location_id INTEGER UNIQUE,
    borough VARCHAR,
    zone VARCHAR,
    service_zone VARCHAR
);

CREATE TABLE IF NOT EXISTS dim_payment (
    payment_key BIGINT PRIMARY KEY,
    payment_type BIGINT UNIQUE,
    payment_description VARCHAR
);

CREATE TABLE IF NOT EXISTS dim_vendor (
    vendor_key BIGINT PRIMARY KEY,
    VendorID INTEGER UNIQUE,
    vendor_description VARCHAR
);

CREATE TABLE IF NOT EXISTS fact_trips (
    trip_key BIGINT PRIMARY KEY,
    pickup_date_key INTEGER,
    dropoff_date_key INTEGER,
    pickup_location_key BIGINT,
    dropoff_location_key BIGINT,
    payment_key BIGINT,
    vendor_key BIGINT,
    pickup_timestamp TIMESTAMP,
    dropoff_timestamp TIMESTAMP,
    rate_code_id BIGINT,
    store_and_fwd_flag VARCHAR,
    passenger_count BIGINT,
    trip_distance DOUBLE,
    trip_duration_minutes DOUBLE,
    fare_amount DOUBLE,
    extra_amount DOUBLE,
    mta_tax DOUBLE,
    tip_amount DOUBLE,
    tolls_amount DOUBLE,
    improvement_surcharge DOUBLE,
    total_amount DOUBLE,
    congestion_surcharge DOUBLE,
    airport_fee DOUBLE,
    cbd_congestion_fee DOUBLE
);

-- Seed unknown members once.
INSERT INTO dim_date
SELECT 0, NULL, NULL, NULL, NULL, 'Unknown',
       NULL, NULL, 'Unknown', NULL
WHERE NOT EXISTS (SELECT 1 FROM dim_date WHERE date_key = 0);

INSERT INTO dim_location
SELECT 0, NULL, 'Unknown', 'Unknown', 'Unknown'
WHERE NOT EXISTS (SELECT 1 FROM dim_location WHERE location_key = 0);

INSERT INTO dim_payment
SELECT 0, NULL, 'Missing payment type'
WHERE NOT EXISTS (SELECT 1 FROM dim_payment WHERE payment_key = 0);

INSERT INTO dim_vendor
SELECT 0, NULL, 'Missing vendor'
WHERE NOT EXISTS (SELECT 1 FROM dim_vendor WHERE vendor_key = 0);

-- Add date members from this batch.
INSERT INTO dim_date
WITH batch_dates AS (
    SELECT CAST(tpep_pickup_datetime AS DATE) AS date_value
    FROM stg_trip_batch
    UNION
    SELECT CAST(tpep_dropoff_datetime AS DATE)
    FROM stg_trip_batch
),
new_dates AS (
    SELECT d.*
    FROM batch_dates d
    WHERE d.date_value IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM dim_date existing
          WHERE existing.date_value = d.date_value
      )
)
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
FROM new_dates;

-- Add new location members.
INSERT INTO dim_location
WITH all_locations AS (
    SELECT
        PULocationID AS location_id,
        pickup_borough AS borough,
        pickup_zone AS zone,
        pickup_service_zone AS service_zone
    FROM stg_trip_batch

    UNION ALL

    SELECT
        DOLocationID,
        dropoff_borough,
        dropoff_zone,
        dropoff_service_zone
    FROM stg_trip_batch
),
location_attributes AS (
    SELECT
        location_id,
        MAX(borough) AS borough,
        MAX(zone) AS zone,
        MAX(service_zone) AS service_zone
    FROM all_locations
    WHERE location_id IS NOT NULL
    GROUP BY location_id
),
new_locations AS (
    SELECT a.*
    FROM location_attributes a
    WHERE NOT EXISTS (
        SELECT 1
        FROM dim_location d
        WHERE d.location_id = a.location_id
    )
),
numbered AS (
    SELECT
        COALESCE((SELECT MAX(location_key) FROM dim_location), 0)
        + ROW_NUMBER() OVER (ORDER BY location_id) AS location_key,
        *
    FROM new_locations
)
SELECT
    location_key,
    location_id,
    COALESCE(borough, 'Unknown'),
    COALESCE(zone, 'Unknown'),
    COALESCE(service_zone, 'Unknown')
FROM numbered;

-- Add new payment members.
INSERT INTO dim_payment
WITH codes AS (
    SELECT DISTINCT payment_type
    FROM stg_trip_batch
    WHERE payment_type IS NOT NULL
),
new_codes AS (
    SELECT c.payment_type
    FROM codes c
    WHERE NOT EXISTS (
        SELECT 1
        FROM dim_payment d
        WHERE d.payment_type = c.payment_type
    )
),
numbered AS (
    SELECT
        COALESCE((SELECT MAX(payment_key) FROM dim_payment), 0)
        + ROW_NUMBER() OVER (ORDER BY payment_type) AS payment_key,
        payment_type
    FROM new_codes
)
SELECT
    payment_key,
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
    END
FROM numbered;

-- Add new vendor members.
INSERT INTO dim_vendor
WITH codes AS (
    SELECT DISTINCT VendorID
    FROM stg_trip_batch
    WHERE VendorID IS NOT NULL
),
new_codes AS (
    SELECT c.VendorID
    FROM codes c
    WHERE NOT EXISTS (
        SELECT 1
        FROM dim_vendor d
        WHERE d.VendorID = c.VendorID
    )
),
numbered AS (
    SELECT
        COALESCE((SELECT MAX(vendor_key) FROM dim_vendor), 0)
        + ROW_NUMBER() OVER (ORDER BY VendorID) AS vendor_key,
        VendorID
    FROM new_codes
)
SELECT
    vendor_key,
    VendorID,
    'Vendor ' || CAST(VendorID AS VARCHAR)
FROM numbered;

-- Insert this batch's fact rows.
INSERT INTO fact_trips
WITH numbered_trips AS (
    SELECT
        COALESCE((SELECT MAX(trip_key) FROM fact_trips), 0)
        + ROW_NUMBER() OVER (
            ORDER BY
                tpep_pickup_datetime,
                tpep_dropoff_datetime,
                VendorID,
                PULocationID,
                DOLocationID,
                payment_type,
                fare_amount,
                total_amount
        ) AS trip_key,
        *
    FROM stg_trip_batch
)
SELECT
    t.trip_key,
    COALESCE(pd.date_key, 0),
    COALESCE(dd.date_key, 0),
    COALESCE(pl.location_key, 0),
    COALESCE(dl.location_key, 0),
    COALESCE(pm.payment_key, 0),
    COALESCE(v.vendor_key, 0),
    t.tpep_pickup_datetime,
    t.tpep_dropoff_datetime,
    t.RatecodeID,
    t.store_and_fwd_flag,
    t.passenger_count,
    t.trip_distance,
    t.trip_duration_minutes,
    t.fare_amount,
    t.extra,
    t.mta_tax,
    t.tip_amount,
    t.tolls_amount,
    t.improvement_surcharge,
    t.total_amount,
    t.congestion_surcharge,
    t.Airport_fee,
    t.cbd_congestion_fee
FROM numbered_trips t
LEFT JOIN dim_date pd
    ON pd.date_value = CAST(t.tpep_pickup_datetime AS DATE)
LEFT JOIN dim_date dd
    ON dd.date_value = CAST(t.tpep_dropoff_datetime AS DATE)
LEFT JOIN dim_location pl
    ON pl.location_id IS NOT DISTINCT FROM t.PULocationID
LEFT JOIN dim_location dl
    ON dl.location_id IS NOT DISTINCT FROM t.DOLocationID
LEFT JOIN dim_payment pm
    ON pm.payment_type IS NOT DISTINCT FROM t.payment_type
LEFT JOIN dim_vendor v
    ON v.VendorID IS NOT DISTINCT FROM t.VendorID;
