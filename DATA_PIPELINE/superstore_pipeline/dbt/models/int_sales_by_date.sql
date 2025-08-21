{{ config(materialized = 'table') }}

with sales_per_date as (
  select
    order_date,
    sum(sales)    as total_sales,
    sum(quantity) as total_quantity,
    sum(profit)   as total_profit
  from {{ ref('stg_orders') }}
  group by order_date
)

select * from sales_per_date
