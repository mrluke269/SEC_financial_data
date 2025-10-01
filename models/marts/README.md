# Marts Layer

The marts layer contains business-ready dimensional models for analysis and reporting.

## Model Lineage

```
Staging Models → Dimension Models → Fact Models

stg_sec_filings__submissions → dim_company
                             → dim_filing → fct_financial_metrics
                             
stg_sec_filings__tag → dim_concept → fct_financial_metrics

stg_sec_filings__numbers → dim_date → fct_financial_metrics
                        → fct_financial_metrics
```

## Dimensions

### dim_company
- **Purpose**: Master table of companies that file with the SEC
- **Grain**: One row per company (CIK)
- **Key**: company_id
- **Source**: stg_sec_filings__submissions (deduplicated)
- **Update Strategy**: SCD Type 1 (overwrites with most recent data)

### dim_filing
- **Purpose**: Details about each SEC filing submission
- **Grain**: One row per filing submission
- **Key**: submission_id
- **Source**: stg_sec_filings__submissions
- **Update Strategy**: Append-only (new filings are added)

### dim_concept
- **Purpose**: Financial reporting concepts and tags from SEC taxonomy
- **Grain**: One row per concept + taxonomy version combination
- **Key**: concept_key (surrogate key from concept_name + taxonomy_version)
- **Source**: stg_sec_filings__tag
- **Update Strategy**: Append-only (new concepts/versions are added)

### dim_date
- **Purpose**: Calendar date dimension for time-based analysis
- **Grain**: One row per calendar date
- **Key**: date_day
- **Source**: stg_sec_filings__numbers (distinct reporting dates)
- **Update Strategy**: Append-only (new dates are added as they appear)

## Facts

### fct_financial_metrics
- **Purpose**: All reported financial metric values from SEC filings
- **Grain**: One row per unique combination of submission, concept, reporting date, and dimensions
- **Key**: financial_metric_key (surrogate key)
- **Foreign Keys**:
  - submission_id → dim_filing
  - company_id → dim_company
  - concept_key → dim_concept
  - reporting_date → dim_date
- **Measures**:
  - reported_value: The primary financial measure
  - fiscal_quarters_covered: Context for the measurement period
  - decimal_precision: Precision of the reported value
- **Source**: stg_sec_filings__numbers + dimension tables
- **Update Strategy**: Append-only (historical records are preserved)

## Materialization Strategy

- **Dimensions**: Materialized as **tables** for fast query performance
- **Facts**: Materialized as **tables** for optimal analytical query performance

Both dimension and fact tables are rebuilt on each dbt run. Consider implementing incremental models for very large datasets.

## Data Quality

All models include:
- Primary key uniqueness tests
- Not null tests on critical fields
- Referential integrity tests (foreign key relationships)

Run `dbt test` to validate data quality across all models.
