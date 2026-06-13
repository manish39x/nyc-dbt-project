# NYC Taxi Data Pipeline

End-to-end ELT pipeline processing NYC TLC yellow and green taxi trip records
using Airflow, AWS S3, Snowflake, and dbt.

## Architecture

will do it ltr🫤

## Stack

| Layer | Tool |
|---|---|
| Orchestration | Apache Airflow |
| Storage | AWS S3 (Parquet) |
| Ingestion | Snowflake Snowpipe (auto-ingest via SQS) |
| Warehouse | Snowflake |
| Transformation | dbt Cloud |
| Seed data | NYC TLC Taxi Zone Lookup |

## Pipeline Overview

**Ingestion** — Airflow DAG downloads monthly Parquet files from the NYC TLC
CloudFront source and uploads them to partitioned S3 paths. Snowpipe listens
via SQS event notifications and auto-ingests new files into raw VARIANT tables.

**Staging** — dbt parses VARIANT columns into typed fields, renames columns to
a consistent schema, and filters invalid rows (zero-distance trips, corrupt
fares, out-of-range timestamps).

**Intermediate** — Yellow and green trips are unioned into a single
`int_all_trips` model. Zone IDs are enriched via a join to the TLC taxi zone
seed. Coded fields (payment type, rate code, vendor) are decoded to
human-readable descriptions. Time dimensions are derived from pickup timestamp.

**Marts** — Aggregated analytical tables ready for BI consumption.

## Models

models/
├── staging/
│   ├── stg_taxi_trips__yellow.sql
│   ├── stg_taxi_trips__green.sql
│   ├── _src_taxi_.yml
│   └── _stg_taxi.yml
├── intermediate/
│   └── int_all_trips.sql
└── marts/
    └──  fct_daily_summary.sql
    └──  fct_zone_revenue.sql
    └──  fct_hourly_patterns.sql


## Data Quality

dbt tests cover:
- `not_null` on all key columns (pickup_datetime, total_amount, vendor_id)
- `accepted_values` on coded fields (payment_type, rate_code_id, taxi_type)
- Custom test: no negative fare amounts across yellow and green
- Custom test: dropoff always after pickup

## Dataset

NYC TLC Trip Record Data — Yellow and Green taxi trips 2014–2026.
Source: https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

## dbt Lineage
<img width="1212" height="469" alt="Screenshot from 2026-06-13 12-08-17" src="https://github.com/user-attachments/assets/fc6602a3-589b-4565-b95f-f06f3239a0e7" />

## Dashboard
<img width="1241" height="816" alt="image" src="https://github.com/user-attachments/assets/ebe491d4-96ba-4d85-b265-653d44af1ba2" />




