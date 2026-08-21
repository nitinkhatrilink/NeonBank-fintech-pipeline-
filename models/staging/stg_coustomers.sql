-- models/staging/stg_customers.sql
with source as (
    select * from {{ source('raw', 'customers') }}
),
cleaned as (
    select
        customer_id,
        -- Fix inconsistent casing from different entry operators
        initcap(trim(first_name))   as first_name,
        initcap(trim(last_name))    as last_name,
        lower(trim(email))          as email,
        upper(trim(country_code))   as country_code,
        try_to_date(date_of_birth, 'YYYY-MM-DD') as date_of_birth,
        -- Two date formats in the same column: YYYY-MM-DD and DD/MM/YYYY
        -- TRY_TO_DATE returns NULL for values that don't match; COALESCE picks the first non-null
        coalesce(
            try_to_date(signup_date, 'YYYY-MM-DD'),
            try_to_date(signup_date, 'DD/MM/YYYY')
        )                           as signup_date,
        -- Normalise: true/TRUE/1/Y/yes -> TRUE ; false/0/N/no -> FALSE ; else NULL
        case
            when lower(trim(is_active)) in ('true',  '1', 'y', 'yes') then true
            when lower(trim(is_active)) in ('false', '0', 'n', 'no')  then false
            else null
        end                         as is_active,
        LOADEDAT
    from source
),
deduped as (
    -- Keep the most recently loaded record per customer_id.
    -- ROW_NUMBER + WHERE rn = 1 is the canonical dedup pattern.
    select
        *,
        row_number() over (
            partition by customer_id
            order by     LOADEDAT desc
        ) as rn
    from cleaned
)
select
    customer_id, first_name, last_name, email,
    signup_date, country_code, date_of_birth, is_active
from deduped
where rn = 1   -- eliminates duplicate customer records