-- models/staging/stg_accounts.sql
with source as (select * from {{ source('raw', 'accounts') }})
select
    account_id,
    customer_id,
    upper(trim(account_type))         as account_type,
    upper(trim(currency))             as currency,
    try_to_date(opened_date)          as opened_date,
    try_to_number(balance, 18, 2)     as balance,       -- preserves negative values
    upper(trim(status))               as status
from source
