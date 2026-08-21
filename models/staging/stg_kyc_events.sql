-- models/staging/stg_kyc_events.sql
with source as (select * from {{ source('raw', 'kyc_events') }})
select
    event_id,
    customer_id,
    upper(trim(kyc_status))     as kyc_status,
    try_to_date(effective_from) as effective_from,
    try_to_number(risk_score)   as risk_score
from source