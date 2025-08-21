{{ config(materialized = 'table') }}

-- Here we're creating an intermediate model to calculate daily sales metrics.
-- This helps keep our final models clean and focused.
with sales_per_date as (
  select
    -- We're summing up sales, quantity, and profit...
    order_date,
    sum(sales)    as total_sales,
    sum(quantity) as total_quantity,
    sum(profit)   as total_profit
  from {{ ref('stg_orders') }} -- ...from our cleaned staging data.
  -- We're grouping all of this data by the order date.
  group by order_date
)

-- Now, we just select everything from our daily summary to create the final table.
select * from sales_per_date
