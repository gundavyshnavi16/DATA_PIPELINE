select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_profit
from "superstore"."analytics"."fct_daily_sales"
where total_profit is null



      
    ) dbt_internal_test