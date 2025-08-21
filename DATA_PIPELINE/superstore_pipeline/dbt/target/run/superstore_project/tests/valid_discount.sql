select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      -- This query will find any orders where the discount is an invalid value
-- (less than 0% or greater than 100%).

select *
from "superstore"."analytics"."stg_orders"
where discount < 0 or discount > 1
      
    ) dbt_internal_test