select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_quantity
from "superstore"."analytics"."fct_daily_sales"
where total_quantity is null



      
    ) dbt_internal_test