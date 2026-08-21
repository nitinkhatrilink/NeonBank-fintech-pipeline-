-- models/staging/stg_fx_rates.sql
with source as (select * from {{ source('raw', 'fx_rates_raw') }})
select
    s.value:as_of_date::date   as as_of_date,
    r.key                      as currency,
    r.value::float             as rate_to_usd
from source,
     lateral flatten(input => payload:snapshots) s,   -- explode the snapshots array
     lateral flatten(input => s.value:rates)     r    -- explode the rates object
