# Data Lab

A repository for exploring the world of data, from databases and data processing to analytics, data mining, and machine learning.

The goal is to understand how data is stored, managed, processed, analyzed, and used to solve real-world problems.

This repository covers different areas of the data domain, including DBMS, data engineering, data analytics, data science, data warehousing, Big Data, and machine learning. The focus is on learning the concepts, applying them through hands-on analysis, and understanding how these areas connect.

## Areas of Exploration

| Area | Focus |
|---|---|
| Database Management Systems | Database design, relational models, SQL, transactions, indexing, and query optimization |
| Data Engineering | Data ingestion, cleaning, transformation, ETL/ELT, and pipeline development |
| Data Warehousing & Data Mining | OLTP, OLAP, dimensional modeling, data warehousing, and mining techniques |
| Big Data | Distributed processing, scalable systems, Hadoop, and Spark |
| Data Analytics | Exploratory data analysis, statistics, visualization, and extracting insights |
| Data Science & Machine Learning | Data preprocessing, feature engineering, statistical modeling, and predictive analysis |
| Data Systems | Storage formats, data architecture, processing engines, and how different systems work together |

These areas are closely connected, and the repository will expand as I explore more concepts and technologies.

## Current Learning Focus

### NYC Yellow Taxi Data Analysis

**Dataset:** NYC Yellow Taxi Trip Records, January 2025

**Source:** NYC Taxi and Limousine Commission

The current learning focus involves exploring a real-world dataset using SQL and DuckDB. It includes data profiling, data quality investigation, data cleaning, analytical queries, geographical enrichment, advanced SQL, and data engineering pipeline development.

## Analyses

### 01. Initial Data Profiling

- Dataset structure, schema, and record counts
- Missing-value analysis and passenger-count distribution
- Vendor-level missingness
- Initial exploration of trip distance and numerical variables

[Documentation](docs/01_initial_profiling.md) | [SQL](sql/01_initial_profiling.sql)

### 02. Trip Duration Analysis

- Deriving trip duration from pickup and drop-off timestamps
- Identifying invalid timestamp relationships
- Investigating negative-duration records
- Filtering invalid-duration records
- Creating and validating the duration-cleaned dataset

[Documentation](docs/02_trip_duration_analysis.md) | [SQL](sql/02_trip_duration_analysis.sql)

### 03. Hourly Taxi Demand

- Analyzing taxi demand by hour
- Identifying hourly demand patterns
- Visualizing temporal demand distribution

[Documentation](docs/03_hourly_taxi_demand.md) | [SQL](sql/03_hourly_taxi_demand.sql) | Visualization

### 04. Weekday vs Weekend Demand

- Comparing hourly demand between weekdays and weekends
- Investigating differences in temporal demand patterns
- Visualizing weekday and weekend demand

[Documentation](docs/04_weekday_weekend_hourly_demand.md) | [SQL](sql/04_weekday_weekend_hourly_demand.sql) | Visualization

### 05. Distance Anomaly Analysis

- Investigating passenger-count missingness and vendor-level differences
- Comparing trip distances for records with missing and nonmissing passenger counts
- Identifying extreme trip distances
- Examining distance and duration together
- Calculating implied average speeds to detect physically implausible measurements
- Establishing a distance-validity rule for analytical use

[Documentation](docs/05_distance_anomaly_analysis.md) | [SQL](sql/05_distance_anomaly_analysis.sql)

### 06. Financial Anomaly Analysis

- Identifying negative fare amounts and negative total amounts
- Investigating financial anomalies by vendor and payment type
- Examining the relationship between negative fares, trip distance, and duration
- Analyzing financial components and unusual transaction patterns
- Distinguishing statistical anomalies from business-rule violations
- Identifying suspicious records for further investigation without automatically deleting them

[Documentation](docs/06_financial_anomaly_analysis.md) | [SQL](sql/06_financial_anomaly_analysis.sql)

### 07. Fare and Tip Analysis

- Investigating relationships between fare amount, trip distance, and trip duration
- Examining fare distributions across different trip characteristics
- Analyzing recorded tips by payment type
- Investigating credit-card tip distributions
- Understanding limitations in recorded tip data, particularly cash tips

[Documentation](docs/07_fare_and_tip_analysis.md) | [SQL](sql/07_fare_and_tip_analysis.sql)

### 08. Pickup and Drop-off Location Analysis

- Analyzing pickup and drop-off demand by taxi zone
- Comparing pickup and drop-off activity
- Identifying frequently travelled origin-destination pairs
- Examining location-level demand by hour
- Comparing trip distance and duration across pickup locations

[Documentation](docs/08_pickup_dropoff_location_analysis.md) | [SQL](sql/08_pickup_dropoff_location_analysis.sql)

### 09. Rate Code and Fare Component Analysis

- Investigating trip distributions across rate codes
- Examining fare characteristics by rate category
- Analyzing individual fare components and surcharges
- Reconstructing candidate trip totals and comparing them with recorded totals
- Investigating congestion charges and their distribution across time and pickup locations

[Documentation](docs/09_rate_code_and_fare_component_analysis.md) | [SQL](sql/09_rate_code_and_fare_component_analysis.sql)

### 10. Time-Based Demand and Fare Analysis

- Analyzing demand by hour, weekday, and date
- Comparing weekday and weekend activity
- Investigating trip distance and duration across different hours
- Examining fare and recorded tip distributions over time
- Comparing weekday rush-hour activity with other periods

[Documentation](docs/10_time_based_demand_and_fare_analysis.md) | [SQL](sql/10_time_based_demand_and_fare_analysis.sql)

### 11. Data Quality and Cleaning Audit

- Auditing completeness and missing values
- Checking timestamp and duration validity
- Performing numerical domain checks
- Investigating extreme distance and speed records
- Validating derived duration values
- Examining fare component reconciliation
- Identifying candidate duplicate records
- Creating consolidated row-level data quality flags

[Documentation](docs/11_data_quality_and_cleaning_audit.md) | [SQL](sql/11_data_quality_and_cleaning_audit.sql)

### 12. Taxi Zone Enrichment and Borough-Level Analysis

- Working with the NYC TLC taxi zone lookup dataset
- Validating lookup keys and geographical mappings
- Enriching trip records with pickup and drop-off zone information
- Investigating unmatched location identifiers
- Analyzing pickup and drop-off demand by borough
- Identifying high-demand zones and borough-level origin-destination patterns
- Examining trip characteristics across geographical areas

[Documentation](docs/12_taxi_zone_enrichment_and_borough_analysis.md) | [SQL](sql/12_taxi_zone_enrichment_and_borough_analysis.sql)

### 13. Advanced Analytical SQL

- Organizing complex queries using Common Table Expressions
- Applying `ROW_NUMBER`, `RANK`, and `DENSE_RANK`
- Ranking pickup zones within boroughs
- Calculating running totals and cumulative demand
- Using `LAG` for consecutive-period comparisons
- Comparing individual zones against group-level averages
- Applying window functions for analytical comparisons and rankings

[Documentation](docs/13_advanced_analytical_sql.md) | [SQL](sql/13_advanced_analytical_sql.sql)

### 14. Repeatable Data Engineering Pipeline

- Building a Python and DuckDB-based data preparation pipeline
- Validating input files and required columns
- Generating duration-cleaned and geographically enriched datasets
- Automating Parquet transformations
- Validating output record counts and geographical coverage
- Handling existing output files during repeated execution
- Exploring repeatability and idempotency in local data pipelines

[Documentation](docs/14_repeatable_data_engineering_pipeline.md) | [Python](python/14_taxi_data_pipeline.py) | [SQL Validation](sql/14_pipeline_validation.sql)

### 15. Final Analytical Synthesis and Learning Review

- Consolidating findings across the analytical iterations
- Revisiting borough-level and zone-level demand
- Summarizing temporal demand patterns
- Examining origin-destination combinations
- Reviewing rate code and financial distributions
- Bringing data quality observations into the final analysis
- Validating relationships between raw, cleaned, and enriched datasets

[Documentation](docs/15_final_analytical_synthesis_and_learning_review.md) | [SQL](sql/15_final_analytical_synthesis.sql)

## Learning Reviews

Consolidated reviews are maintained separately from individual iteration documentation. Each review covers five iterations and records the concepts learned, analytical reasoning, important findings, corrected misunderstandings, and connections between the different exercises.

| Review | Coverage |
|---|---|
| [Learning Review 1](docs/reviews/iterations_01-05_review.md) | Iterations 1–5 |
| [Learning Review 2](docs/reviews/iterations_06-10_review.md) | Iterations 6–10 |
| [Learning Review 3](docs/reviews/iterations_11-15_review.md) | Iterations 11–15 |

## Data Processing

The original dataset is preserved separately from processed datasets.

| Processing Stage | Records |
|---|---:|
| Original dataset | 3,475,226 |
| January-filtered dataset | 3,475,204 |
| Duration-cleaned dataset | 3,475,080 |

The duration-cleaned dataset excludes 124 records with invalid trip durations.

The distance-anomaly investigation identified 899 additional records with calculated average speeds above 100 mph. These records were flagged for investigation and potential exclusion from distance-based analysis.

Distance-based exclusions are analysis-specific and do not overwrite the original dataset or duration-cleaned dataset.

The financial anomaly investigation identified 144,118 records with negative fare amounts and 63,037 records with negative total amounts. All negative-fare records belonged to Vendor 2, with substantial concentrations across specific payment types.

These financial records are flagged for investigation rather than automatically removed. The available data does not establish whether every negative value represents a refund, reversal, correction, dispute, or data-quality issue.

The processing workflow also includes a geographically enriched dataset created using the NYC TLC taxi zone lookup table. This adds zone and borough information to the cleaned trip records for geographical analysis.

## Technologies

Currently working with:

- Python
- SQL
- DuckDB
- Pandas
- PyArrow
- Matplotlib
- Parquet
- Git and GitHub

More technologies will be added as the learning progresses.

## Repository Structure

```text
data-lab/
├── data/
│   ├── raw/
│   └── processed/
├── sql/
├── python/
├── notebooks/
├── docs/
│   ├── reviews/
│   │   ├── iterations_01-05_review.md
│   │   ├── iterations_06-10_review.md
│   │   └── iterations_11-15_review.md
│   ├── 01_initial_profiling.md
│   ├── ...
│   └── 15_final_analytical_synthesis_and_learning_review.md
└── README.md
```

The data directory contains local datasets that are excluded from Git. SQL queries and Python scripts are maintained separately, while notebooks are used for exploration. The docs directory contains individual learning journals, consolidated reviews, visualizations, and technical notes.

## Workflow

The general approach for each learning iteration is to understand the dataset first, investigate its quality, process it when necessary, and then perform analysis.

Queries, scripts, and findings are documented so that the work can be reproduced and revisited later.

Raw datasets are kept out of Git. Their sources and download instructions are documented where relevant.

## Learning Philosophy

The aim is to understand concepts beyond just writing code or completing tutorials.

I want to understand how different data technologies work, why they are used, and how they fit together in real-world systems.

This repository will continue to grow as I explore databases, data pipelines, analytical systems, large-scale data processing, and machine learning through practical learning and hands-on analysis.

## Future Work

The learning journey will continue with more advanced data cleaning, transformation, exploratory analysis, data engineering pipelines, data warehousing, distributed processing, and eventually machine learning.

