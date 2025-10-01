with

filings as (

    select
        submission_id,
        company_id,
        accelerated_filer_status,
        fiscal_year_end,
        form_type,
        reporting_period_end,
        fiscal_year,
        fiscal_period,
        filed_date,
        accepted_date,
        previous_report_flag,
        detail_flag,
        instance_document,
        related_company_count,
        related_company_ids,
        public_float_usd,
        float_date,
        float_axis,
        float_members
    from {{ ref('stg_sec_filings__submissions') }}

),

final as (

    select
        submission_id,
        company_id,
        accelerated_filer_status,
        fiscal_year_end,
        form_type,
        reporting_period_end,
        fiscal_year,
        fiscal_period,
        filed_date,
        accepted_date,
        previous_report_flag,
        detail_flag,
        instance_document,
        related_company_count,
        related_company_ids,
        public_float_usd,
        float_date,
        float_axis,
        float_members
    from filings

)

select * from final
