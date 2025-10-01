with

companies as (

    select
        company_id,
        company_name,
        industry_code,
        business_country,
        business_state,
        business_city,
        business_zip,
        business_address_line_1,
        business_address_line_2,
        business_phone,
        mailing_country,
        mailing_state,
        mailing_city,
        mailing_zip,
        mailing_address_line_1,
        mailing_address_line_2,
        incorporation_country,
        incorporation_state,
        tax_id,
        former_names,
        name_change_date,
        well_known_issuer_flag
    from {{ ref('stg_sec_filings__submissions') }}

),

deduplicated as (

    select
        company_id,
        company_name,
        industry_code,
        business_country,
        business_state,
        business_city,
        business_zip,
        business_address_line_1,
        business_address_line_2,
        business_phone,
        mailing_country,
        mailing_state,
        mailing_city,
        mailing_zip,
        mailing_address_line_1,
        mailing_address_line_2,
        incorporation_country,
        incorporation_state,
        tax_id,
        former_names,
        name_change_date,
        well_known_issuer_flag,
        row_number() over (partition by company_id order by name_change_date desc nulls last) as row_num
    from companies

),

final as (

    select
        company_id,
        company_name,
        industry_code,
        business_country,
        business_state,
        business_city,
        business_zip,
        business_address_line_1,
        business_address_line_2,
        business_phone,
        mailing_country,
        mailing_state,
        mailing_city,
        mailing_zip,
        mailing_address_line_1,
        mailing_address_line_2,
        incorporation_country,
        incorporation_state,
        tax_id,
        former_names,
        name_change_date,
        well_known_issuer_flag
    from deduplicated
    where row_num = 1

)

select * from final
