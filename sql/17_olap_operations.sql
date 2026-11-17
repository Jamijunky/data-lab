-- Iteration 17: OLAP operations on the DuckDB taxi warehouse
-- Run each query independently against data/processed/taxi_warehouse.duckdb.
-- These queries read from the warehouse; they do not create or modify tables.

-- 17.1 ROLL-UP
-- Aggregate trip-level facts to the pickup-borough level.

SELECT
    l.borough,
    COUNT(*) AS total_trips,
    ROUND(SUM(f.total_amount), 2) AS total_revenue
FROM fact_trips f
JOIN dim_location l
    ON f.pickup_location_key = l.location_key
GROUP BY l.borough
ORDER BY total_trips DESC;


-- 17.2 DRILL-DOWN
-- Restrict the borough-level view to Manhattan and show its pickup zones.

SELECT
    l.borough,
    l.zone,
    COUNT(*) AS total_trips,
    ROUND(SUM(f.total_amount), 2) AS total_revenue
FROM fact_trips f
JOIN dim_location l
    ON f.pickup_location_key = l.location_key
WHERE l.borough = 'Manhattan'
GROUP BY l.borough, l.zone
ORDER BY total_trips DESC;


-- 17.3 SLICE
-- Keep only credit-card trips (source payment_type = 1).

SELECT
    p.payment_description,
    COUNT(*) AS total_trips,
    ROUND(AVG(f.fare_amount), 2) AS avg_fare,
    ROUND(AVG(f.total_amount), 2) AS avg_total
FROM fact_trips f
JOIN dim_payment p
    ON f.payment_key = p.payment_key
WHERE p.payment_type = 1
GROUP BY p.payment_description;


-- 17.4 DICE
-- Manhattan pickup trips, weekdays, and credit-card payments.

SELECT
    l.borough,
    d.weekday_name,
    COUNT(*) AS total_trips,
    ROUND(SUM(f.total_amount), 2) AS total_revenue
FROM fact_trips f
JOIN dim_location l
    ON f.pickup_location_key = l.location_key
JOIN dim_date d
    ON f.pickup_date_key = d.date_key
JOIN dim_payment p
    ON f.payment_key = p.payment_key
WHERE l.borough = 'Manhattan'
  AND d.is_weekend = FALSE
  AND p.payment_type = 1
GROUP BY l.borough, d.weekday_number, d.weekday_name
ORDER BY d.weekday_number;


-- 17.5 PIVOT-LIKE CONDITIONAL AGGREGATION
-- Compare payment-code trip counts across weekdays.

SELECT
    d.weekday_name,
    SUM(CASE WHEN p.payment_type = 0 THEN 1 ELSE 0 END) AS payment_code_0,
    SUM(CASE WHEN p.payment_type = 1 THEN 1 ELSE 0 END) AS credit_card,
    SUM(CASE WHEN p.payment_type = 2 THEN 1 ELSE 0 END) AS cash,
    SUM(CASE WHEN p.payment_type = 3 THEN 1 ELSE 0 END) AS no_charge,
    SUM(CASE WHEN p.payment_type = 4 THEN 1 ELSE 0 END) AS dispute,
    SUM(CASE WHEN p.payment_type = 5 THEN 1 ELSE 0 END) AS payment_code_5,
    SUM(CASE WHEN p.payment_type IS NULL THEN 1 ELSE 0 END) AS missing_payment_type,
    COUNT(*) AS total_trips
FROM fact_trips f
JOIN dim_date d
    ON f.pickup_date_key = d.date_key
JOIN dim_payment p
    ON f.payment_key = p.payment_key
GROUP BY d.weekday_number, d.weekday_name
ORDER BY d.weekday_number;


-- Supporting lookup: inspect the source-code-to-description mapping.

SELECT
    payment_key,
    payment_type,
    payment_description
FROM dim_payment
ORDER BY payment_key;
