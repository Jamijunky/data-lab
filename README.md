# Data Lab

A repository for exploring the world of data, from databases and data processing to analytics, data mining, and machine learning.

The goal is to understand how data is stored, managed, processed, analyzed, and used to solve real-world problems.

This repository covers different areas of the data domain, including **DBMS, data engineering, data analytics, data science, data warehousing, Big Data, and machine learning**. The focus is on learning the concepts, applying them through practical projects, and understanding how these areas connect.

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

**Source:** [NYC Taxi and Limousine Commission](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)

The current project focuses on exploring a real-world dataset using SQL and DuckDB. It includes data profiling, data quality investigation, analytical queries, and exploratory data analysis.

### Analyses

- [Initial Data Profiling](docs/01_initial_profiling.md)
- [Trip Duration Analysis](docs/02_trip_duration_analysis.md)
- [Hourly Taxi Demand Analysis](docs/03_hourly_taxi_demand.md)

### SQL Queries

- [Initial Data Profiling](sql/01_data_profiling.sql)
- [Trip Duration Analysis](sql/02_trip_duration_analysis.sql)
- [Hourly Taxi Demand Analysis](sql/03_hourly_taxi_demand.sql)

## Technologies

Currently working with:

- Python
- SQL
- DuckDB
- Pandas
- PyArrow
- Matplotlib
- Parquet

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

The `data` directory contains local datasets that are excluded from Git. SQL queries and Python scripts are maintained separately, while notebooks are used for exploration and the `docs` directory contains analysis reports, visualizations, and technical notes.

## Workflow

The general approach for each project is to understand the dataset first, investigate its quality, process it when necessary, and then perform analysis.

Queries, scripts, and findings are documented so that the work can be reproduced and revisited later.

Raw datasets are kept out of Git. Their sources and download instructions are documented where relevant.

## Learning Philosophy

The aim is to understand concepts beyond just writing code or completing tutorials.

I want to understand how different data technologies work, why they are used, and how they fit together in real-world systems.

This repository will continue to grow as I explore databases, data pipelines, analytical systems, large-scale data processing, and machine learning through practical work.
