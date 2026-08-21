-- models/staging/stg_loans.sql
with source as (select * from {{ source('raw', 'loans') }})
select
    loan_id,
    customer_id,
    upper(trim(loan_type))                                 as loan_type,
    try_to_number(principal_amount, 18, 2)                 as principal_amount,
    try_to_number(interest_rate, 5, 2)                     as interest_rate,
    try_to_number(term_months)                             as term_months,
    try_to_date(issued_date)                               as issued_date,
    coalesce(try_to_number(outstanding_balance, 18, 2), 0) as outstanding_balance,
    upper(trim(status))                                    as status,
    case when upper(trim(status)) = 'DEFAULTED' then true else false end as is_default
from source