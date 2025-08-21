-- This config block tells dbt how to build the model.
-- We're setting it to 'incremental' so it updates fast,
-- and using 'order_date' as the unique key to identify rows.
{{ config(
  materialized = 'incremental',
  unique_key = 'order_date',
  incremental_strategy = 'delete+insert'
) }}

-- This is a temporary block of code (a CTE) to select the data we need.
with daily as (
  select *
  from {{ ref('int_sales_by_date') }} -- We're pulling data from our intermediate sales model.
  {% if is_incremental() %}
    -- This is a clever trick for incremental runs!
    -- We only process data from the last 30 days to make the pipeline run much faster.
    where order_date >= current_date - interval '30 days'
  {% endif %}
)

-- This is the final step where we build our table.
select
  order_date,
  total_sales,
  total_quantity,
  total_profit,
  -- Here we calculate the profit margin as a percentage.
  -- The `nullif` function prevents any 'divide by zero' errors.
  round(total_profit / nullif(total_sales, 0) * 100, 2) as profit_margin_percent
from daily
