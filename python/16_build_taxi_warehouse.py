from pathlib import Path
import duckdb


ROOT = Path(__file__).resolve().parents[1]

SOURCE = (
    ROOT
    / "data/processed/yellow_tripdata_2025-01_enriched.parquet"
)

SQL_FILE = ROOT / "sql/16_build_taxi_warehouse.sql"

DATABASE = ROOT / "data/processed/taxi_warehouse.duckdb"


def scalar(con, query):
    return con.execute(query).fetchone()[0]


def main():

    if not SOURCE.exists():
        raise FileNotFoundError(
            f"Source dataset not found: {SOURCE}"
        )

    if not SQL_FILE.exists():
        raise FileNotFoundError(
            f"SQL file not found: {SQL_FILE}"
        )

    DATABASE.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    con = duckdb.connect(str(DATABASE))

    try:

        print("Building Iteration 16 warehouse...")

        sql_text = SQL_FILE.read_text(
            encoding="utf-8"
        )

        con.execute(sql_text)

        source_path = (
            SOURCE.as_posix().replace("'", "''")
        )

        source_count = scalar(
            con,
            f"""
            SELECT COUNT(*)
            FROM read_parquet('{source_path}')
            """
        )

        fact_count = scalar(
            con,
            "SELECT COUNT(*) FROM fact_trips"
        )

        print("\nTable row counts")

        tables = [
            "dim_date",
            "dim_location",
            "dim_payment",
            "dim_vendor",
            "fact_trips"
        ]

        for table in tables:

            count = scalar(
                con,
                f"SELECT COUNT(*) FROM {table}"
            )

            print(
                f"{table:18} {count:>12,}"
            )

        # Compare source and fact-table measures.

        source_fare, source_total = con.execute(
            f"""
            SELECT
                SUM(fare_amount),
                SUM(total_amount)
            FROM read_parquet('{source_path}')
            """
        ).fetchone()

        fact_fare, fact_total = con.execute(
            """
            SELECT
                SUM(fare_amount),
                SUM(total_amount)
            FROM fact_trips
            """
        ).fetchone()

        # Referential-integrity checks.

        reference_checks = {

            "pickup_date": """
                SELECT COUNT(*)
                FROM fact_trips f
                LEFT JOIN dim_date d
                    ON f.pickup_date_key = d.date_key
                WHERE d.date_key IS NULL
            """,

            "dropoff_date": """
                SELECT COUNT(*)
                FROM fact_trips f
                LEFT JOIN dim_date d
                    ON f.dropoff_date_key = d.date_key
                WHERE d.date_key IS NULL
            """,

            "pickup_location": """
                SELECT COUNT(*)
                FROM fact_trips f
                LEFT JOIN dim_location d
                    ON f.pickup_location_key = d.location_key
                WHERE d.location_key IS NULL
            """,

            "dropoff_location": """
                SELECT COUNT(*)
                FROM fact_trips f
                LEFT JOIN dim_location d
                    ON f.dropoff_location_key = d.location_key
                WHERE d.location_key IS NULL
            """,

            "payment": """
                SELECT COUNT(*)
                FROM fact_trips f
                LEFT JOIN dim_payment d
                    ON f.payment_key = d.payment_key
                WHERE d.payment_key IS NULL
            """,

            "vendor": """
                SELECT COUNT(*)
                FROM fact_trips f
                LEFT JOIN dim_vendor d
                    ON f.vendor_key = d.vendor_key
                WHERE d.vendor_key IS NULL
            """
        }

        unresolved = {
            name: scalar(con, query)
            for name, query in reference_checks.items()
        }

        # Check duplicate fact keys.

        duplicate_trip_keys = scalar(
            con,
            """
            SELECT COUNT(*)
            FROM (
                SELECT trip_key
                FROM fact_trips
                GROUP BY trip_key
                HAVING COUNT(*) > 1
            )
            """
        )

        # Final validation conditions.

        checks = {

            "Fact count equals source count":
                fact_count == source_count,

            "Fare sum preserved":
                abs(
                    (fact_fare or 0)
                    - (source_fare or 0)
                ) < 1e-4,

            "Total amount sum preserved":
                abs(
                    (fact_total or 0)
                    - (source_total or 0)
                ) < 1e-4,

            "Trip keys unique in this build":
                duplicate_trip_keys == 0,

            "All fact references resolve":
                all(
                    value == 0
                    for value in unresolved.values()
                )
        }

        print("\nValidation")

        print(f"Source rows: {source_count:,}")
        print(f"Fact rows:   {fact_count:,}")

        print(
            f"Source/fact fare sums: "
            f"{source_fare} / {fact_fare}"
        )

        print(
            f"Source/fact total sums: "
            f"{source_total} / {fact_total}"
        )

        print(
            f"Duplicate trip-key groups: "
            f"{duplicate_trip_keys:,}"
        )

        print("\nUnresolved references")

        for name, count in unresolved.items():

            print(
                f"{name:18} {count:>12,}"
            )

        print("\nChecks")

        for name, passed in checks.items():

            status = "PASS" if passed else "FAIL"

            print(f"{status}  {name}")

        if not all(checks.values()):

            raise RuntimeError(
                "Warehouse validation failed."
            )

        print(
            f"\nWarehouse created: {DATABASE}"
        )

    finally:

        con.close()


if __name__ == "__main__":
    main()
