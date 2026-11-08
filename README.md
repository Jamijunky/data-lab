# Data Lab

A repository for exploring the world of data, from databases and data processing to analytics, data mining, and machine learning.

The goal is to understand how data is stored, managed, processed, analyzed, and used to solve real-world problems.

This repository covers different areas of the data domain, including DBMS, data engineering, data analytics, data science, data warehousing, Big Data, and machine learning. The focus is on learning the concepts, applying them through practical projects, and understanding how these areas connect.

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

## Current Project

### NYC Yellow Taxi Data Analysis

**Dataset:** NYC Yellow Taxi Trip Records, January 2025

**Source:** NYC Taxi and Limousine Commission

The current project focuses on exploring a real-world dataset using SQL and DuckDB. It includes data profiling, data quality investigation, data cleaning, analytical queries, and exploratory data analysis.

### Analyses

#### 01. Initial Data Profiling

- Dataset structure, schema, and record counts
- Missing-value analysis and passenger-count distribution
- Vendor-level missingness
- Initial exploration of trip distance and numerical variables

[Documentation](docs/01_initial_profiling.md) | [SQL](sql/01_data_profiling.sql)

#### 02. Trip Duration Analysis

- Deriving trip duration from pickup and dropoff timestamps
- Identifying invalid timestamp relationships
- Investigating negative-duration records
- Filtering invalid-duration records
- Creating and validating the duration-cleaned dataset

[Documentation](docs/02_trip_duration_analysis.md) | [SQL](sql/02_trip_duration_analysis.sql)

#### 03. Hourly Taxi Demand

- Analyzing taxi demand by hour
- Identifying hourly demand patterns
- Visualizing temporal demand distribution

[Documentation](docs/03_hourly_taxi_demand.md) | [SQL](sql/03_hourly_taxi_demand.sql) | [Visualization](docs/hourly_taxi_demand.png)

#### 04. Weekday vs Weekend Demand

- Comparing hourly demand between weekdays and weekends
- Investigating differences in temporal demand patterns
- Visualizing weekday and weekend demand

[Documentation](docs/04_weekday_weekend_hourly_demand.md) | [SQL](sql/04_weekday_weekend_hourly_demand.sql) | [Visualization](docs/weekday_weekend_hourly_demand.png)

#### 05. Distance Anomaly Analysis

- Investigating passenger-count missingness and vendor-level differences
- Comparing trip distances for records with missing and nonmissing passenger counts
- Identifying extreme trip distances
- Examining distance and duration together
- Calculating implied average speeds to detect physically implausible measurements
- Establishing a distance-validity rule for analytical use

[Documentation](docs/05_distance_anomaly_analysis.md) | [SQL](sql/05_distance_anomaly_analysis.sql)

## Data Processing

The project preserves the original dataset separately from processed datasets.

| Processing Stage | Records |
|---|---:|
| Original dataset | 3,475,226 |
| January-filtered dataset | 3,475,204 |
| Duration-cleaned dataset | 3,475,080 |

The duration-cleaned dataset excludes 124 records with invalid trip durations.

The distance-anomaly investigation identified 899 additional records with calculated average speeds above 100 mph. These records were identified for exclusion from distance-based analysis.

Distance-based exclusions are analysis-specific and do not overwrite the original dataset or duration-cleaned dataset.

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

More technologies will be added as the projects and learning progress.

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
└── README.md
```

The data directory contains local datasets that are excluded from Git. SQL queries and Python scripts are maintained separately, while notebooks are used for exploration and the docs directory contains analysis reports, visualizations, and technical notes.

## Workflow

The general approach for each project is to understand the dataset first, investigate its quality, process it when necessary, and then perform analysis.

Queries, scripts, and findings are documented so that the work can be reproduced and revisited later.

Raw datasets are kept out of Git. Their sources and download instructions are documented where relevant.

## Learning Philosophy

The aim is to understand concepts beyond just writing code or completing tutorials.

I want to understand how different data technologies work, why they are used, and how they fit together in real-world systems.

This repository will continue to grow as I explore databases, data pipelines, analytical systems, large-scale data processing, and machine learning through practical work.

## Future Work

The project will continue with more advanced data cleaning, transformation, exploratory analysis, data engineering pipelines, data warehousing, and eventually machine learning.

