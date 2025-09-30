with 

source as (

    select * from {{ source('sec_filings', 'raw_numbers') }}

),

renamed as (

    select
    adsh as submission_id,
    tag as concept_name,
    version as taxonomy_version,
    ddate as reporting_date,
    qtrs as fiscal_quarters_covered,
    uom as unit_of_measure,
    dimh as dimension_header,
    iprx as is_primary_axis,
    value as reported_value,
    footnote as footnote_text,
    footlen as footnote_length,
    dimn as dimension_name,
    coreg as co_reporting_entity,
    durp as duration_period,
    datp as date_point,
    dcml as decimal_precision

    from source

)

select * from renamed
