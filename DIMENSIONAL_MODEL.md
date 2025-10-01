# Dimensional Model Summary

## Overview
This document provides a quick reference for the dimensional model created for SEC financial data.

## Model Architecture

### Data Flow
```
Raw Sources (SEC_FINANCIALS schema)
    ├── raw_submissions
    ├── raw_numbers
    └── raw_tag
           ↓
Staging Layer (Views)
    ├── stg_sec_filings__submissions
    ├── stg_sec_filings__numbers
    └── stg_sec_filings__tag
           ↓
Marts Layer (Tables)
    ├── Dimensions
    │   ├── dim_company (from submissions)
    │   ├── dim_filing (from submissions)
    │   ├── dim_concept (from tag)
    │   └── dim_date (from numbers)
    └── Facts
        └── fct_financial_metrics (from numbers + all dimensions)
```

## Star Schema Design

```
                    dim_date
                        |
                   date_day (PK)
                        |
                        |
    dim_company --------+-------- dim_filing
         |              |              |
    company_id (PK)     |      submission_id (PK)
         |              |              |
         +------+-------+-------+------+
                |               |
                |               |
         fct_financial_metrics  |
                |               |
      financial_metric_key (PK) |
      submission_id (FK) --------+
      company_id (FK) -----------+
      concept_key (FK) -----------+
      reporting_date (FK) --------+
      reported_value (MEASURE)
                |
                |
         dim_concept
                |
         concept_key (PK)
```

## Table Specifications

| Table | Type | Rows (approx) | Materialization | Key |
|-------|------|---------------|-----------------|-----|
| dim_company | Dimension | ~10,000 | Table | company_id |
| dim_filing | Dimension | ~1M | Table | submission_id |
| dim_concept | Dimension | ~10,000 | Table | concept_key |
| dim_date | Dimension | ~5,000 | Table | date_day |
| fct_financial_metrics | Fact | ~100M+ | Table | financial_metric_key |

## Key Relationships

### Foreign Key Relationships in fct_financial_metrics:
- `company_id` → `dim_company.company_id`
- `submission_id` → `dim_filing.submission_id`
- `concept_key` → `dim_concept.concept_key`
- `reporting_date` → `dim_date.date_day`

## Common Analytical Queries

### 1. Revenue Trends by Company
```sql
SELECT 
    c.company_name,
    d.year,
    d.quarter_name,
    SUM(f.reported_value) as total_revenue
FROM fct_financial_metrics f
JOIN dim_company c ON f.company_id = c.company_id
JOIN dim_concept co ON f.concept_key = co.concept_key
JOIN dim_date d ON f.reporting_date = d.date_day
WHERE co.concept_name LIKE '%Revenue%'
  AND f.unit_of_measure = 'USD'
GROUP BY 1, 2, 3
ORDER BY 2 DESC, 3, 4 DESC;
```

### 2. Balance Sheet Analysis
```sql
SELECT 
    c.company_name,
    co.display_label,
    f.reported_value,
    f.reporting_date
FROM fct_financial_metrics f
JOIN dim_company c ON f.company_id = c.company_id
JOIN dim_concept co ON f.concept_key = co.concept_key
JOIN dim_filing fi ON f.submission_id = fi.submission_id
WHERE fi.form_type = '10-K'
  AND co.concept_name IN ('Assets', 'Liabilities', 'StockholdersEquity')
  AND f.fiscal_quarters_covered = 4
ORDER BY c.company_name, f.reporting_date DESC;
```

### 3. Industry Comparison
```sql
SELECT 
    c.industry_code,
    COUNT(DISTINCT c.company_id) as company_count,
    AVG(f.reported_value) as avg_metric_value
FROM fct_financial_metrics f
JOIN dim_company c ON f.company_id = c.company_id
JOIN dim_concept co ON f.concept_key = co.concept_key
WHERE co.concept_name = 'Revenue'
  AND f.fiscal_year = 2023
GROUP BY c.industry_code
ORDER BY avg_metric_value DESC;
```

### 4. Time Series Analysis
```sql
SELECT 
    d.year,
    d.month,
    COUNT(DISTINCT f.submission_id) as filing_count,
    COUNT(DISTINCT f.company_id) as company_count
FROM fct_financial_metrics f
JOIN dim_date d ON f.reporting_date = d.date_day
GROUP BY d.year, d.month
ORDER BY d.year DESC, d.month DESC;
```

## Data Quality Tests

### Dimension Tests
- ✅ Primary key uniqueness
- ✅ Primary key not null
- ✅ Business key uniqueness (where applicable)

### Fact Tests
- ✅ Primary key uniqueness
- ✅ Foreign key relationships
- ✅ Required fields not null
- ✅ Measure value ranges (can be added)

## Build Commands

```bash
# Build entire project
dbt build

# Build only staging
dbt build --select staging.*

# Build only dimensions
dbt build --select marts.dimensions.*

# Build only facts
dbt build --select marts.facts.*

# Build specific model and downstream
dbt build --select dim_company+

# Run tests only
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

## Notes

- **Grain**: The fact table grain is one row per unique combination of submission, concept, reporting date, and dimensions
- **Measures**: Primary measure is `reported_value`; context measures include `fiscal_quarters_covered` and `decimal_precision`
- **Degenerate Dimensions**: Some filing attributes are denormalized into the fact table for query convenience
- **SCD Type**: Dimensions use Type 1 (overwrite) except dim_filing which is append-only
- **Optimization**: Consider partitioning fact table by reporting_date and clustering by company_id for large datasets
