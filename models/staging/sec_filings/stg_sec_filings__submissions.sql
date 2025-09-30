with 

source as (

    select * from {{ source('sec_filings', 'raw_submissions') }}

),

renamed as (

    select
    adsh as submission_id,
    cik as company_id,
    name as company_name,
    sic as industry_code,
    countryba as business_country,
    stprba as business_state,
    cityba as business_city,
    zipba as business_zip,
    bas1 as business_address_line_1,
    bas2 as business_address_line_2,
    baph as business_phone,
    countryma as mailing_country,
    stprma as mailing_state,
    cityma as mailing_city,
    zipma as mailing_zip,
    mas1 as mailing_address_line_1,
    mas2 as mailing_address_line_2,
    countryinc as incorporation_country,
    stprinc as incorporation_state,
    ein as tax_id,
    former as former_names,
    changed as name_change_date,
    afs as accelerated_filer_status,
    wksi as well_known_issuer_flag,
    fye as fiscal_year_end,
    form as form_type,
    period as reporting_period_end,
    fy as fiscal_year,
    fp as fiscal_period,
    filed as filed_date,
    accepted as accepted_date,
    prevrpt as previous_report_flag,
    detail as detail_flag,
    instance as instance_document,
    nciks as related_company_count,
    aciks as related_company_ids,
    pubfloatusd as public_float_usd,
    floatdate as float_date,
    floataxis as float_axis,
    floatmems as float_members

    from source

)

select * from renamed
