# Iteration 18: Incremental Data Loading

## Objective

In Iteration 16, I built the taxi warehouse by reading the complete enriched Parquet dataset and recreating the dimension and fact tables.

That approach is suitable for a full refresh. However, when new data arrives, rebuilding the entire warehouse just to add those records is unnecessary.

In this iteration, I implemented a batch-based incremental loading workflow in DuckDB.

The implementation uses the same enriched taxi dataset, but loads it in separate, non-overlapping pickup-date ranges.

## Loading strategy

I divided the January 2025 source dataset into two batches:

| Batch | Pickup date range |
|---|---|
| Batch 1 | January 1–15, 2025 |
| Batch 2 | January 16–31, 2025 |

The first batch initializes the warehouse. The second batch adds records while retaining the first batch.

The incremental warehouse is stored separately:

`data/processed/taxi_incremental.duckdb`

The Iteration 16 warehouse remains unchanged.

## Why I used batch boundaries

The source dataset does not provide a durable unique trip identifier.

In Iteration 16, I generated `trip_key` using `ROW_NUMBER()`. That key identifies a row in the generated warehouse snapshot. It is not a stable identifier that can reliably identify the same source trip across independent loads.

I therefore used controlled, non-overlapping pickup-date ranges as the loading boundary.

The implementation maintains a `load_batches` table containing:

- Batch ID
- Start date
- End date
- Load timestamp
- Number of rows loaded

The loader skips a batch ID that has already been processed. It also rejects a different batch whose date range overlaps an existing batch.

This prevents accidental reprocessing of a registered batch or overlapping date range. It does not guarantee arbitrary row-level deduplication across unrelated source files.

## Loading sequence

For each batch, the Python runner:

1. Checks whether the batch ID already exists.
2. Checks whether the requested date range overlaps an existing batch.
3. Opens a transaction.
4. Reads the selected pickup-date range into a temporary staging table.
5. Inserts previously unseen date members.
6. Inserts previously unseen location members.
7. Inserts previously unseen payment members.
8. Inserts previously unseen vendor members.
9. Inserts the batch's fact records.
10. Validates inserted row counts, fare totals, total amounts, and dimension references.
11. Records the batch in the ledger.
12. Commits the transaction.

If an operation or validation fails, the transaction is rolled back.

## Dimension handling

The dimension tables are retained between batch loads.

Before inserting fact rows, the loader checks which dimension members are missing and inserts only those members.

Location, payment, and vendor dimensions use warehouse-generated keys. New keys are assigned after the current maximum key.

The date dimension uses a YYYYMMDD date key.

Unknown members use key zero, preserving the distinction between a missing source value and an actual source code such as payment type zero.

## Files

- `sql/18_incremental_load.sql`
- `python/18_incremental_load.py`

The SQL file contains the dimension and fact insertion logic. Python coordinates staging, transaction management, batch tracking, and validation.

## Running the implementation

From the repository root:

```bash
cd ~/data-lab
source .venv/bin/activate
