# SEC_financial_data
dbt-powered transformations of raw government financial disclosures into dimensional models.

## Overview
This project transforms raw SEC financial filing data into a dimensional model optimized for analysis and reporting. The data pipeline follows the medallion architecture pattern with staging and marts layers.

## Data Model

### Staging Layer
The staging layer provides cleaned and renamed views of the raw SEC data:

- **stg_sec_filings__submissions**: Cleaned submission-level data for all SEC filings
- **stg_sec_filings__numbers**: Cleaned numeric data from financial statements
- **stg_sec_filings__tag**: Cleaned financial reporting tag definitions

### Marts Layer

#### Dimension Tables
The marts layer includes four dimension tables:

1. **dim_company**: Company master data
   - Contains unique company information including business addresses, incorporation details, and industry classification
   - Deduplicated by company_id (CIK)
   - Primary key: `company_id`

2. **dim_filing**: SEC filing details
   - Contains metadata about each SEC filing submission
   - Includes form type, filing dates, fiscal periods, and public float information
   - Primary key: `submission_id`

3. **dim_concept**: Financial reporting concepts
   - Contains definitions for financial reporting tags from the SEC taxonomy
   - Includes concept names, data types, and display labels
   - Primary key: `concept_key` (surrogate key from concept_name + taxonomy_version)

4. **dim_date**: Calendar date dimension
   - Contains calendar attributes for all reporting dates
   - Includes year, quarter, month, day, and week information
   - Primary key: `date_day`

#### Fact Table
1. **fct_financial_metrics**: Financial metrics fact table
   - Contains all reported financial metric values from SEC filings
   - Links to all dimension tables
   - Primary key: `financial_metric_key` (surrogate key)
   - Foreign keys: `submission_id`, `company_id`, `concept_key`, `reporting_date`
   - Measures: `reported_value`, `fiscal_quarters_covered`, `decimal_precision`

## Data Architecture

```
┌─────────────────┐
│  Raw SEC Data   │
│   (Sources)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Staging Layer  │
│    (Views)      │
├─────────────────┤
│ • submissions   │
│ • numbers       │
│ • tag           │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Marts Layer    │
│   (Tables)      │
├─────────────────┤
│ Dimensions:     │
│ • dim_company   │
│ • dim_filing    │
│ • dim_concept   │
│ • dim_date      │
│                 │
│ Facts:          │
│ • fct_financial │
│   _metrics      │
└─────────────────┘
```

## Usage

### Building the Models
To build all models:
```bash
dbt build
```

To build only dimension tables:
```bash
dbt build --select marts.dimensions.*
```

To build only fact tables:
```bash
dbt build --select marts.facts.*
```

### Example Queries

#### Get total revenue by company and year:
```sql
SELECT 
    c.company_name,
    d.year,
    SUM(f.reported_value) as total_revenue
FROM fct_financial_metrics f
JOIN dim_company c ON f.company_id = c.company_id
JOIN dim_concept co ON f.concept_key = co.concept_key
JOIN dim_date d ON f.reporting_date = d.date_day
WHERE co.concept_name = 'Revenues'
  AND f.unit_of_measure = 'USD'
GROUP BY c.company_name, d.year
ORDER BY d.year DESC, total_revenue DESC;
```

#### Compare quarterly metrics for a specific company:
```sql
SELECT 
    fi.fiscal_year,
    fi.fiscal_period,
    co.display_label,
    f.reported_value,
    f.unit_of_measure
FROM fct_financial_metrics f
JOIN dim_company c ON f.company_id = c.company_id
JOIN dim_filing fi ON f.submission_id = fi.submission_id
JOIN dim_concept co ON f.concept_key = co.concept_key
WHERE c.company_name = 'Apple Inc.'
  AND fi.form_type = '10-Q'
  AND co.concept_name IN ('Assets', 'Liabilities', 'StockholdersEquity')
ORDER BY fi.fiscal_year DESC, fi.fiscal_period;
```

## Project Structure
```
.
├── models/
│   ├── staging/          # Staging layer (views)
│   │   └── sec_filings/
│   ├── marts/            # Marts layer (tables)
│   │   ├── dimensions/   # Dimension tables
│   │   └── facts/        # Fact tables
│   └── sec_filings/      # Source definitions
├── tests/                # Custom data tests
├── macros/               # Custom macros
├── seeds/                # Seed data files
└── dbt_project.yml       # Project configuration
```

## Testing
All models include schema tests for data quality:
- Uniqueness tests on primary keys
- Not null tests on required fields
- Relationships tests for foreign keys

Run tests with:
```bash
dbt test
```
