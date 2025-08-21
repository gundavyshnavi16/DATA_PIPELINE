{{ config(
  materialized = 'incremental',
  unique_key = 'order_date',
  incremental_strategy = 'delete+insert'
) }}

with daily as (
  select *
  from {{ ref('int_sales_by_date') }}
  {% if is_incremental() %}
    where order_date >= current_date - interval '30 days'
  {% endif %}
)

select
  order_date,
  total_sales,
  total_quantity,
  total_profit,
  round(total_profit / nullif(total_sales, 0) * 100, 2) as profit_margin_percent
from daily;
