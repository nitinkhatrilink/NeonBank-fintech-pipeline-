-- Generate per-category spend columns without repeating code for each category
{% set categories = ['GROCERY', 'TRAVEL', 'DINING', 'UTILITIES', 'ENTERTAINMENT'] %}
select
    account_id,
    {% for cat in categories %}
    sum(case when merchant_category = '{{ cat }}' then abs(amount) else 0 end)
        as spend_{{ cat | lower }}
    {%- if not loop.last %},{% endif %}
    {% endfor %}
from {{ ref('stg_transactions') }}
where direction = 'DEBIT'
group by account_id