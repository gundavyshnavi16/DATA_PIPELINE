
  create view "superstore"."analytics"."int_sales_by_date__dbt_tmp"
    
    
  as (
    with sales_per_date as (
    select
        order_date,
        sum(sales) as total_sales,
        sum(quantity) as total_quantity,
        sum(profit) as total_profit
    from "superstore"."analytics"."stg_orders"
    group by order_date
)

select * from sales_per_date
order by order_date
  );