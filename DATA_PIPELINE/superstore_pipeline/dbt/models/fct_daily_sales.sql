-- select
--     order_date,
--     total_sales,
--     total_quantity,
--     total_profit,
--     round(total_profit / nullif(total_sales,0) * 100, 2) as profit_margin_percent
-- from {{ ref('int_sales_by_date') }}
-- order by order_date
{{ config(
  materialized = 'incremental',
  unique_key = 'order_date',
  incremental_strategy = 'delete+insert'
) }}

with daily as (
  select
    order_date,
    sum(sales)    as total_sales,
    sum(quantity) as total_quantity,
    sum(profit)   as total_profit
  from {{ ref('stg_orders') }}
  {% if is_incremental() %}
    -- Reload only last 30 days (safe window for corrections)
    where order_date >= current_date - interval '30 days' -- if not we can merge (snwoflake, databricks or other warehouses that support merge)
  {% endif %}
  group by order_date
)

select
  order_date,
  total_sales,
  total_quantity,
  total_profit,
  round(total_profit / nullif(total_sales, 0) * 100, 2) as profit_margin_percent
from daily