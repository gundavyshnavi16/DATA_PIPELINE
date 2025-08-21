select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select profit_margin_percent
from "superstore"."analytics"."fct_daily_sales"
where profit_margin_percent is null



      
    ) dbt_internal_test