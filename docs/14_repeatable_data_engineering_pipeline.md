# Iteration 14: Repeatable Data Engineering Pipeline

## Objective

The objective of this iteration is to connect the data preparation and enrichment operations into a repeatable data processing pipeline.

Previous iterations used individual SQL files to investigate, transform, and analyze the NYC Yellow Taxi dataset. These operations were useful for learning, but executing them independently is not an ideal long-term workflow.

A data pipeline organizes these operations into a defined sequence so that the same process can be executed again when new data becomes available.

## Understanding a Data Pipeline

A data pipeline is a sequence of operations through which data moves from a source to a destination.

In this analysis, the source is the raw January 2025 Yellow Taxi Parquet dataset. The pipeline validates the input, applies documented cleaning rules, enriches the records with geographical reference data, and writes analytical datasets.

The pipeline separates the stages so that each transformation has a clear responsibility.

## ETL and ELT

ETL stands for Extract, Transform, Load.

Data is extracted from a source, transformed into the required structure, and loaded into its destination.

ELT stands for Extract, Load, Transform.

Data is first loaded into a storage or processing environment and transformed afterward.

The distinction concerns when transformation happens relative to loading. Modern analytical systems often use a combination of these approaches.

This iteration follows a practical local workflow: DuckDB reads the source Parquet and CSV files, performs transformations, and writes processed Parquet outputs.

## Pipeline Stages

### 1. Extraction

The pipeline reads the raw Yellow Taxi Parquet dataset and the Taxi Zone Lookup CSV.

The raw trip dataset contains the original transaction records. The lookup CSV provides geographical descriptions for location identifiers.

The source files are preserved and are not modified by the pipeline.

### 2. Validation

Before processing, the pipeline checks whether the required source files exist and whether the expected columns are available.

It also checks the lookup table for duplicate location identifiers.

These checks prevent the pipeline from silently processing incomplete or structurally incompatible inputs.

### 3. Transformation

The first transformation filters pickup timestamps to January 2025 and retains records where the drop-off timestamp is not earlier than the pickup timestamp.

Trip duration is calculated from the pickup and drop-off timestamps.

The previously established processing results provide reference points:

- Raw records: 3,475,226.
- January pickup records: 3,475,204.
- Duration-cleaned records: 3,475,080.

These counts are useful validation checkpoints for reproducing the original processing.

Extreme distances, negative fares, and other suspicious financial or trip characteristics are not automatically deleted. They require separate analytical decisions.

### 4. Enrichment

The cleaned trip dataset is joined with the Taxi Zone Lookup table.

Pickup and drop-off location identifiers are enriched separately using LEFT JOIN operations.

The pipeline preserves trip records without matching lookup entries so that missing geographical information remains visible.

### 5. Loading

The pipeline writes two separate outputs:

- A duration-cleaned Parquet dataset.
- A geographically enriched Parquet dataset.

Parquet is useful for analytical workloads because it is columnar and supports efficient column-based reading.

The original raw files remain unchanged.

## Idempotency

A pipeline is idempotent when executing it repeatedly with the same inputs produces the same logical output without accumulating unintended changes.

For this local workflow, the output datasets are regenerated from the source files instead of appending another copy of the same records on every execution.

This avoids duplicate accumulation across repeated runs.

Idempotency does not guarantee identical results if the source files, transformation rules, or reference data change.

## Data Validation and Pipeline Reliability

A successful script execution is not sufficient proof that a pipeline produced correct data.

The pipeline should validate important properties after transformation.

For example, the enriched dataset should contain the same number of records as the cleaned dataset, assuming the lookup keys are unique.

The output should also contain the expected geographical columns.

Validation should detect structural or record-count problems before the pipeline reports success.

## Separation of Responsibilities

Python is used to orchestrate the workflow: checking inputs, managing paths, executing transformations, and validating outputs.

DuckDB performs the analytical data operations through SQL.

This separation makes the pipeline easier to maintain. Python controls the execution process, while SQL expresses the data transformations.

## Analytical Conclusions

This iteration moves the learning workflow from manually executing separate transformations toward a reproducible data pipeline.

It demonstrates how raw data, validation, cleaning, reference-data enrichment, and output generation can be organized into a single process.

The pipeline also makes cleaning decisions explicit and preserves suspicious observations rather than deleting them without justification.

## Limitations

This is a local batch-processing pipeline for one monthly dataset.

It does not yet support incremental ingestion, automated scheduling, cloud storage, distributed processing, or production monitoring.

The pipeline also relies on the supplied source files and documented transformation rules. It cannot independently verify the real-world accuracy of taxi trip records.

## Learning Reflection

The most important concept in this iteration is that data engineering involves more than writing queries.

A reliable workflow must manage inputs, validate assumptions, execute transformations in a controlled sequence, preserve source data, and verify outputs.

The pipeline provides a foundation for later work involving incremental processing, orchestration, partitioning, and larger-scale data systems.
