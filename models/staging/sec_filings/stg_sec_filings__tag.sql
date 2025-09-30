with 

source as (

    select * from {{ source('sec_filings', 'raw_tag') }}

),

renamed as (

    select
    tag as concept_name,
    version as taxonomy_version,
    custom as is_custom_tag,
    abstract as is_abstract_tag,
    datatype as data_type,
    iord as item_order,
    crdr as debit_credit_indicator,
    tlabel as display_label,
    doc as documentation

    from source

)

select * from renamed
