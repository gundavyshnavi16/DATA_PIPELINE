select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      -- A test fails if it returns rows.
-- This query will find any orders where the shipping happened before the order was placed.

select *
from "superstore"."analytics"."stg_orders"
where ship_date < order_date
      
    ) dbt_internal_test