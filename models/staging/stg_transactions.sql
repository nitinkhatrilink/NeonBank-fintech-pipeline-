-- models/staging/stg_transactions.sql
with source as (select * from {{ source('raw', 'transactions') }})
select
    transaction_id,
    account_id,
    try_to_timestamp_ntz(txn_timestamp)             as txn_timestamp,
    try_to_number(amount, 18, 2)                    as amount,
    upper(trim(currency))                           as currency,
    upper(trim(merchant_category))                  as merchant_category,
    trim(merchant_name)                             as merchant_name,
    upper(trim(channel))                            as channel,
    upper(trim(status))                             as status,
    -- Extract fields from the embedded JSON metadata string
    -- TRY_PARSE_JSON handles the case where metadata is NULL or malformed
    try_parse_json(metadata):device::string         as device,
    try_parse_json(metadata):is_international::boolean as is_international,
    try_parse_json(metadata):mcc::int               as mcc,
    -- Derive debit/credit direction from the sign of amount
    case
        when try_to_number(amount, 18, 2) < 0 then 'DEBIT'
        when try_to_number(amount, 18, 2) > 0 then 'CREDIT'
        else 'ZERO'
    end as direction
from source
where upper(trim(status)) != 'REVERSED' 