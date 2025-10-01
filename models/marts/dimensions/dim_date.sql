with

date_spine as (

    select distinct
        TO_DATE(reporting_date::string, 'YYYYMMDD') as date_day
    from {{ ref('stg_sec_filings__numbers') }}
    where reporting_date is not null

),

final as (

    select
        date_day,
        extract(year from date_day) as year,
        extract(quarter from date_day) as quarter,
        extract(month from date_day) as month,
        extract(day from date_day) as day,
        extract(dayofweek from date_day) as day_of_week,
        extract(dayofyear from date_day) as day_of_year,
        extract(week from date_day) as week_of_year,
        case
            when extract(quarter from date_day) = 1 then 'Q1'
            when extract(quarter from date_day) = 2 then 'Q2'
            when extract(quarter from date_day) = 3 then 'Q3'
            when extract(quarter from date_day) = 4 then 'Q4'
        end as quarter_name,
        case
            when extract(month from date_day) = 1 then 'January'
            when extract(month from date_day) = 2 then 'February'
            when extract(month from date_day) = 3 then 'March'
            when extract(month from date_day) = 4 then 'April'
            when extract(month from date_day) = 5 then 'May'
            when extract(month from date_day) = 6 then 'June'
            when extract(month from date_day) = 7 then 'July'
            when extract(month from date_day) = 8 then 'August'
            when extract(month from date_day) = 9 then 'September'
            when extract(month from date_day) = 10 then 'October'
            when extract(month from date_day) = 11 then 'November'
            when extract(month from date_day) = 12 then 'December'
        end as month_name
    from date_spine

)

select * from final
