with

numbers as (

    select
        submission_id,
        concept_name,
        taxonomy_version,
        reporting_date,
        fiscal_quarters_covered,
        unit_of_measure,
        dimension_header,
        is_primary_axis,
        reported_value,
        footnote_text,
        footnote_length,
        dimension_name,
        co_reporting_entity,
        duration_period,
        date_point,
        decimal_precision
    from {{ ref('stg_sec_filings__numbers') }}

),

filings as (

    select
        submission_id,
        company_id,
        form_type,
        fiscal_year,
        fiscal_period,
        reporting_period_end,
        filed_date
    from {{ ref('dim_filing') }}

),

concepts as (

    select
        concept_key,
        concept_name,
        taxonomy_version
    from {{ ref('dim_concept') }}

),

joined as (

    select
        n.submission_id,
        f.company_id,
        c.concept_key,
        n.reporting_date,
        n.fiscal_quarters_covered,
        n.unit_of_measure,
        n.dimension_header,
        n.is_primary_axis,
        n.reported_value,
        n.footnote_text,
        n.footnote_length,
        n.dimension_name,
        n.co_reporting_entity,
        n.duration_period,
        n.date_point,
        n.decimal_precision,
        f.form_type,
        f.fiscal_year,
        f.fiscal_period,
        f.reporting_period_end,
        f.filed_date
    from numbers n
    left join filings f
        on n.submission_id = f.submission_id
    left join concepts c
        on n.concept_name = c.concept_name
        and n.taxonomy_version = c.taxonomy_version

),

final as (

    select
        md5(
            submission_id || '|' || 
            coalesce(concept_key, '') || '|' || 
            coalesce(cast(reporting_date as varchar), '') || '|' || 
            coalesce(dimension_header, '') || '|' || 
            coalesce(dimension_name, '')
        ) as financial_metric_key,
        submission_id,
        company_id,
        concept_key,
        reporting_date,
        fiscal_quarters_covered,
        unit_of_measure,
        dimension_header,
        is_primary_axis,
        reported_value,
        footnote_text,
        footnote_length,
        dimension_name,
        co_reporting_entity,
        duration_period,
        date_point,
        decimal_precision,
        form_type,
        fiscal_year,
        fiscal_period,
        reporting_period_end,
        filed_date
    from joined

)

select * from final
