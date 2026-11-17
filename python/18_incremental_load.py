from pathlib import Path
import argparse
import math

import duckdb

ROOT = Path(__file__).resolve().parents[1]

SOURCE = ROOT / "data/processed/yellow_tripdata_2025-01_enriched.parquet"
SQL_FILE = ROOT / "sql/18_incremental_load.sql"
DATABASE = ROOT / "data/processed/taxi_incremental.duckdb"


def scalar(con, query, params=None):
    return con.execute(query, params or []).fetchone()[0]


def initialize_warehouse(con):
    con.execute("""
        CREATE TABLE IF NOT EXISTS load_batches (
            batch_id VARCHAR PRIMARY KEY,
            start_date DATE NOT NULL,
            end_date DATE NOT NULL,
            loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            rows_loaded BIGINT NOT NULL
        )
    """)

    con.execute("""
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
        )
    """)

    con.execute("""
        CREATE TABLE IF NOT EXISTS dim_location (
            location_key BIGINT PRIMARY KEY,
            location_id INTEGER UNIQUE,
            borough VARCHAR,
            zone VARCHAR,
            service_zone VARCHAR
        )
    """)

    con.execute("""
        CREATE TABLE IF NOT EXISTS dim_payment (
            payment_key BIGINT PRIMARY KEY,
            payment_type BIGINT UNIQUE,
            payment_description VARCHAR
        )
    """)

    con.execute("""
        CREATE TABLE IF NOT EXISTS dim_vendor (
            vendor_key BIGINT PRIMARY KEY,
            VendorID INTEGER UNIQUE,
            vendor_description VARCHAR
        )
    """)

    con.execute("""
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
            rate_code_id DOUBLE,
            store_and_fwd_flag VARCHAR,
            passenger_count DOUBLE,
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
        )
    """)

    con.execute("""
        INSERT INTO dim_date
        VALUES (
            0, NULL, NULL, NULL, NULL,
            'Unknown', NULL, NULL, 'Unknown', NULL
        )
        ON CONFLICT (date_key) DO NOTHING
    """)

    con.execute("""
        INSERT INTO dim_location
        VALUES (0, NULL, 'Unknown', 'Unknown', 'Unknown')
        ON CONFLICT (location_key) DO NOTHING
    """)

    con.execute("""
        INSERT INTO dim_payment
        VALUES (0, NULL, 'Missing payment type')
        ON CONFLICT (payment_key) DO NOTHING
    """)

    con.execute("""
        INSERT INTO dim_vendor
        VALUES (0, NULL, 'Missing vendor')
        ON CONFLICT (vendor_key) DO NOTHING
    """)


def validate_batch(con, old_max_trip_key, batch_rows):
    new_rows = scalar(
        con,
        "SELECT COUNT(*) FROM fact_trips WHERE trip_key > ?",
        [old_max_trip_key]
    )

    if new_rows != batch_rows:
        raise RuntimeError(
            f"Expected {batch_rows:,} new facts, found {new_rows:,}."
        )

    source_fare, source_total = con.execute("""
        SELECT SUM(fare_amount), SUM(total_amount)
        FROM stg_trip_batch
    """).fetchone()

    fact_fare, fact_total = con.execute("""
        SELECT SUM(fare_amount), SUM(total_amount)
        FROM fact_trips
        WHERE trip_key > ?
    """, [old_max_trip_key]).fetchone()

    if not math.isclose(
        source_fare or 0,
        fact_fare or 0,
        rel_tol=1e-10,
        abs_tol=1e-5
    ):
        raise RuntimeError("Fare sum does not match the staged batch.")

    if not math.isclose(
        source_total or 0,
        fact_total or 0,
        rel_tol=1e-10,
        abs_tol=1e-5
    ):
        raise RuntimeError("Total amount sum does not match the staged batch.")

    unresolved = scalar(con, """
        SELECT COUNT(*)
        FROM fact_trips f
        LEFT JOIN dim_date pd
            ON f.pickup_date_key = pd.date_key
        LEFT JOIN dim_date dd
            ON f.dropoff_date_key = dd.date_key
        LEFT JOIN dim_location pl
            ON f.pickup_location_key = pl.location_key
        LEFT JOIN dim_location dl
            ON f.dropoff_location_key = dl.location_key
        LEFT JOIN dim_payment p
            ON f.payment_key = p.payment_key
        LEFT JOIN dim_vendor v
            ON f.vendor_key = v.vendor_key
        WHERE pd.date_key IS NULL
           OR dd.date_key IS NULL
           OR pl.location_key IS NULL
           OR dl.location_key IS NULL
           OR p.payment_key IS NULL
           OR v.vendor_key IS NULL
    """)

    if unresolved != 0:
        raise RuntimeError(
            f"Found {unresolved:,} unresolved dimension references."
        )

    return new_rows, source_fare, source_total


def load_batch(con, batch_id, start_date, end_date):
    already_loaded = con.execute("""
        SELECT 1
        FROM load_batches
        WHERE batch_id = ?
    """, [batch_id]).fetchone()

    if already_loaded:
        print(f"Batch '{batch_id}' was already loaded. Skipping.")
        return

    overlap = con.execute("""
        SELECT batch_id, start_date, end_date
        FROM load_batches
        WHERE start_date <= CAST(? AS DATE)
          AND end_date >= CAST(? AS DATE)
    """, [end_date, start_date]).fetchall()

    if overlap:
        raise ValueError(
            f"Requested date range overlaps existing batches: {overlap}"
        )

    con.execute("BEGIN TRANSACTION")

    try:
        con.execute("""
            CREATE OR REPLACE TEMP TABLE stg_trip_batch AS
            SELECT *
            FROM read_parquet(?)
            WHERE CAST(tpep_pickup_datetime AS DATE)
                BETWEEN CAST(? AS DATE) AND CAST(? AS DATE)
        """, [str(SOURCE), start_date, end_date])

        batch_rows = scalar(con, "SELECT COUNT(*) FROM stg_trip_batch")

        if batch_rows == 0:
            raise ValueError("The selected date range contains no records.")

        old_max_trip_key = scalar(
            con,
            "SELECT COALESCE(MAX(trip_key), 0) FROM fact_trips"
        )

        con.execute(SQL_FILE.read_text(encoding="utf-8"))

        inserted, fare_sum, total_sum = validate_batch(
            con,
            old_max_trip_key,
            batch_rows
        )

        con.execute("""
            INSERT INTO load_batches (
                batch_id,
                start_date,
                end_date,
                rows_loaded
            )
            VALUES (?, CAST(? AS DATE), CAST(? AS DATE), ?)
        """, [batch_id, start_date, end_date, inserted])

        fact_count = scalar(con, "SELECT COUNT(*) FROM fact_trips")
        ledger_count = scalar(
            con,
            "SELECT COALESCE(SUM(rows_loaded), 0) FROM load_batches"
        )

        if fact_count != ledger_count:
            raise RuntimeError(
                f"Fact count {fact_count:,} does not match "
                f"ledger count {ledger_count:,}."
            )

        con.execute("COMMIT")

        print(f"\nBatch loaded successfully: {batch_id}")
        print(f"Rows in this batch: {inserted:,}")
        print(f"Warehouse fact rows: {fact_count:,}")
        print(f"Batch fare sum: {fare_sum}")
        print(f"Batch total sum: {total_sum}")
        print("Validation: PASS")

    except Exception:
        con.execute("ROLLBACK")
        raise


def main():
    parser = argparse.ArgumentParser(
        description="Incrementally load a date range into the taxi warehouse."
    )

    parser.add_argument("--batch-id", required=True)
    parser.add_argument("--start", required=True)
    parser.add_argument("--end", required=True)

    args = parser.parse_args()

    if args.start > args.end:
        raise ValueError("Start date cannot be after end date.")

    if not SOURCE.exists():
        raise FileNotFoundError(f"Source dataset not found: {SOURCE}")

    if not SQL_FILE.exists():
        raise FileNotFoundError(f"SQL file not found: {SQL_FILE}")

    DATABASE.parent.mkdir(parents=True, exist_ok=True)

    con = duckdb.connect(str(DATABASE))

    try:
        initialize_warehouse(con)

        load_batch(
            con,
            args.batch_id,
            args.start,
            args.end
        )
    finally:
        con.close()


if __name__ == "__main__":
    main()
