from pathlib import Path
import duckdb


ROOT = Path(__file__).resolve().parent.parent

RAW_FILE = ROOT / "data/raw/yellow_tripdata_2025-01.parquet"
LOOKUP_FILE = ROOT / "data/raw/taxi_zone_lookup.csv"

CLEANED_FILE = ROOT / "data/processed/yellow_tripdata_2025-01_cleaned.parquet"
ENRICHED_FILE = ROOT / "data/processed/yellow_tripdata_2025-01_enriched.parquet"

START_DATE = "2025-01-01 00:00:00"
END_DATE = "2025-02-01 00:00:00"

REQUIRED_TRIP_COLUMNS = {
    "VendorID",
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime",
    "passenger_count",
    "trip_distance",
    "RatecodeID",
    "PULocationID",
    "DOLocationID",
    "fare_amount",
    "total_amount",
}

REQUIRED_LOOKUP_COLUMNS = {
    "LocationID",
    "Borough",
    "Zone",
    "service_zone",
}


def validate_inputs(con):
    if not RAW_FILE.exists():
        raise FileNotFoundError(f"Missing raw dataset: {RAW_FILE}")

    if not LOOKUP_FILE.exists():
        raise FileNotFoundError(f"Missing lookup dataset: {LOOKUP_FILE}")

    trip_columns = {
        row[0]
        for row in con.execute(
            f"DESCRIBE SELECT * FROM read_parquet('{RAW_FILE}')"
        ).fetchall()
    }

    lookup_columns = {
        row[0]
        for row in con.execute(
            f"DESCRIBE SELECT * FROM read_csv_auto('{LOOKUP_FILE}')"
        ).fetchall()
    }

    missing_trip_columns = REQUIRED_TRIP_COLUMNS - trip_columns
    missing_lookup_columns = REQUIRED_LOOKUP_COLUMNS - lookup_columns

    if missing_trip_columns:
        raise ValueError(
            f"Missing trip columns: {sorted(missing_trip_columns)}"
        )

    if missing_lookup_columns:
        raise ValueError(
            f"Missing lookup columns: {sorted(missing_lookup_columns)}"
        )

    duplicate_lookup_ids = con.execute(
        f"""
        SELECT COUNT(*)
        FROM (
            SELECT LocationID
            FROM read_csv_auto('{LOOKUP_FILE}')
            GROUP BY LocationID
            HAVING COUNT(*) > 1
        )
        """
    ).fetchone()[0]

    if duplicate_lookup_ids:
        raise ValueError(
            f"Lookup table contains {duplicate_lookup_ids} duplicate keys"
        )

    print("Input validation passed.")


def create_cleaned_dataset(con):
    con.execute(
        f"""
        COPY (
            SELECT
                *,
                DATE_DIFF(
                    'second',
                    tpep_pickup_datetime,
                    tpep_dropoff_datetime
                ) / 60.0 AS trip_duration_minutes
            FROM read_parquet('{RAW_FILE}')
            WHERE tpep_pickup_datetime >= TIMESTAMP '{START_DATE}'
              AND tpep_pickup_datetime < TIMESTAMP '{END_DATE}'
              AND tpep_dropoff_datetime >= tpep_pickup_datetime
        )
        TO '{CLEANED_FILE}'
        (FORMAT PARQUET)
        """
    )

    print("Cleaned dataset created.")


def create_enriched_dataset(con):
    con.execute(
        f"""
        COPY (
            SELECT
                t.*,

                pu.Borough AS pickup_borough,
                pu.Zone AS pickup_zone,
                pu.service_zone AS pickup_service_zone,

                dst.Borough AS dropoff_borough,
                dst.Zone AS dropoff_zone,
                dst.service_zone AS dropoff_service_zone

            FROM read_parquet('{CLEANED_FILE}') t

            LEFT JOIN read_csv_auto('{LOOKUP_FILE}') pu
                ON t.PULocationID = pu.LocationID

            LEFT JOIN read_csv_auto('{LOOKUP_FILE}') dst
                ON t.DOLocationID = dst.LocationID

        )
        TO '{ENRICHED_FILE}'
        (FORMAT PARQUET)
        """
    )

    print("Enriched dataset created.")


def validate_outputs(con):
    raw_count = con.execute(
        f"SELECT COUNT(*) FROM read_parquet('{RAW_FILE}')"
    ).fetchone()[0]

    january_count = con.execute(
        f"""
        SELECT COUNT(*)
        FROM read_parquet('{RAW_FILE}')
        WHERE tpep_pickup_datetime >= TIMESTAMP '{START_DATE}'
          AND tpep_pickup_datetime < TIMESTAMP '{END_DATE}'
        """
    ).fetchone()[0]

    cleaned_count = con.execute(
        f"SELECT COUNT(*) FROM read_parquet('{CLEANED_FILE}')"
    ).fetchone()[0]

    enriched_count = con.execute(
        f"SELECT COUNT(*) FROM read_parquet('{ENRICHED_FILE}')"
    ).fetchone()[0]

    unmatched_pickups, unmatched_dropoffs = con.execute(
        f"""
        SELECT
            COUNT(*) FILTER (WHERE pickup_borough IS NULL),
            COUNT(*) FILTER (WHERE dropoff_borough IS NULL)
        FROM read_parquet('{ENRICHED_FILE}')
        """
    ).fetchone()

    if cleaned_count > january_count:
        raise ValueError("Cleaned count exceeds January-filtered count.")

    if enriched_count != cleaned_count:
        raise ValueError(
            "Enrichment changed the record count. Check lookup keys."
        )

    print("\nPipeline validation summary")
    print("---------------------------")
    print(f"Raw records:              {raw_count:,}")
    print(f"January pickup records:   {january_count:,}")
    print(f"Duration-cleaned records: {cleaned_count:,}")
    print(f"Enriched records:         {enriched_count:,}")
    print(f"Unmatched pickups:        {unmatched_pickups:,}")
    print(f"Unmatched drop-offs:      {unmatched_dropoffs:,}")

    print("\nOutput files")
    print("------------")
    print(CLEANED_FILE)
    print(ENRICHED_FILE)


def main():
    (ROOT / "data/processed").mkdir(parents=True, exist_ok=True)

    con = duckdb.connect()

    try:
        print("Starting taxi data pipeline...\n")

        validate_inputs(con)

        if CLEANED_FILE.exists():
            CLEANED_FILE.unlink()

        if ENRICHED_FILE.exists():
            ENRICHED_FILE.unlink()

        create_cleaned_dataset(con)
        create_enriched_dataset(con)
        validate_outputs(con)

        print("\nPipeline completed successfully.")

    finally:
        con.close()


if __name__ == "__main__":
    main()
