-- select
--     order_date,
--     total_sales,
--     total_quantity,
--     total_profit,
--     round(total_profit / nullif(total_sales,0) * 100, 2) as profit_margin_percent
-- from "superstore"."analytics"."int_sales_by_date"
-- order by order_date


with daily as (
  select
    order_date,
    sum(sales)    as total_sales,
    sum(quantity) as total_quantity,
    sum(profit)   as total_profit
  from "superstore"."analytics"."stg_orders"
  
    -- Reload only last 30 days (safe window for corrections)
    where order_date >= current_date - interval '30 days' -- if not we can merge (snwoflake, databricks or other warehouses that support merge)
  
  group by order_date
)

select
  order_date,
  total_sales,
  total_quantity,
  total_profit,
  round(total_profit / nullif(total_sales, 0) * 100, 2) as profit_margin_percent
from daily