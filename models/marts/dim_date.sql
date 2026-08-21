-- models/marts/dim_date.sql
{% set start_date = '2023-01-01' %}
{% set end_date   = '2025-12-31' %}
with spine as (
    {{ dbt_utils.date_spine(
        datepart  = "day",
        start_date = "cast('" ~ start_date ~ "' as date)",
        end_date   = "cast('" ~ end_date   ~ "' as date)"
    ) }}
)
select
    cast(to_char(date_day, 'YYYYMMDD') as int) as date_sk,   -- integer PK: e.g. 20240315
    date_day                                   as date,
    year(date_day)                             as year,
    quarter(date_day)                          as quarter,
    month(date_day)                            as month,
    monthname(date_day)                        as month_name,
    dayofweek(date_day)                        as day_of_week,
    dayname(date_day)                          as day_name,
    case when dayofweek(date_day) in (0, 6) then true else false end as is_weekend
from spine