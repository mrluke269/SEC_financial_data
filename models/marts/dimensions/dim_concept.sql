with

concepts as (

    select
        concept_name,
        taxonomy_version,
        is_custom_tag,
        is_abstract_tag,
        data_type,
        item_order,
        debit_credit_indicator,
        display_label,
        documentation
    from {{ ref('stg_sec_filings__tag') }}

),

final as (

    select
        md5(concept_name || '|' || taxonomy_version) as concept_key,
        concept_name,
        taxonomy_version,
        is_custom_tag,
        is_abstract_tag,
        data_type,
        item_order,
        debit_credit_indicator,
        display_label,
        documentation
    from concepts

)

select * from final
