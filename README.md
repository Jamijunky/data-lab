# Data Lab

A practical, evolving repository for exploring the **data domain end-to-end** - from databases and data acquisition to processing, analytics, data mining, and machine learning.

The objective is to develop a deep understanding of how data is created, stored, organized, processed, analyzed, and used to derive insights and support decisions.

This is not a repository focused on preparing for a single job role. It brings together concepts and practical work across **DBMS, data engineering, data analytics, data science, data warehousing, Big Data, and machine learning**.

The emphasis is on understanding the underlying concepts, working with real-world datasets, building reproducible workflows, and connecting theory with practical implementation.

## Areas of Exploration

| Area | Focus |
|---|---|
| Database Management Systems | Database design, relational models, SQL, transactions, indexing, and query optimization |
| Data Engineering | Data acquisition, ingestion, cleaning, transformation, ETL/ELT, and pipeline development |
| Data Warehousing & Data Mining | OLTP, OLAP, dimensional modeling, warehousing, aggregation, and mining techniques |
| Big Data | Distributed data processing, scalable systems, and technologies such as Hadoop and Spark |
| Data Analytics | Exploratory data analysis, statistics, visualization, and extracting insights |
| Data Science & Machine Learning | Data preprocessing, feature engineering, statistical modeling, and predictive analysis |
| Data Systems | Storage formats, data architecture, processing engines, and the systems connecting these areas |

These areas overlap and complement each other. The repository will evolve as new concepts and practical projects are explored.

## Current Project

### NYC Yellow Taxi Data Analysis

**Dataset:** NYC Yellow Taxi Trip Records — January 2025

**Source:** [NYC Taxi and Limousine Commission](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)

The initial project focuses on understanding a real-world dataset through SQL-based analysis, data quality investigation, and exploratory data analysis using DuckDB.

### Analyses

- [Initial Data Profiling](docs/01_initial_profiling.md)
- [Trip Duration Analysis](docs/02_trip_duration_analysis.md)
- [Hourly Taxi Demand Analysis](docs/03_hourly_taxi_demand.md)

### SQL Queries

- [Initial Data Profiling](sql/01_data_profiling.sql)
- [Trip Duration Analysis](sql/02_trip_duration_analysis.sql)
- [Hourly Taxi Demand Analysis](sql/03_hourly_taxi_demand.sql)

## Technologies

Currently used:

- Python
- SQL
- DuckDB
- Pandas
- PyArrow
- Matplotlib
- Parquet

Additional technologies will be introduced as the projects and learning objectives expand.

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

- `data/` — Local datasets, excluded from Git
- `sql/` — Reproducible SQL queries and analyses
- `python/` — Python scripts and data-processing utilities
- `notebooks/` — Exploratory analysis and experiments
- `docs/` — Methodology, findings, visualizations, and technical notes

## Workflow & Reproducibility

The repository follows a practical workflow:

1. Acquire and inspect real-world data.
2. Understand its structure, schema, and limitations.
3. Investigate missing values and data quality issues.
4. Process and transform data where necessary.
5. Perform analytical queries and exploratory analysis.
6. Visualize and interpret results.
7. Document findings, assumptions, and limitations.
8. Keep the analysis reproducible through code and version control.

Raw datasets are intentionally excluded from Git. Dataset sources and instructions for obtaining the data are documented where relevant.

## Learning Philosophy

The focus is not simply on completing tutorials or collecting technologies.

The goal is to understand **why systems work the way they do**, how different data technologies fit together, and how theoretical concepts translate into practical workflows.

This repository will grow alongside that understanding — from foundational database concepts to large-scale data systems, analytics, and machine learning.

