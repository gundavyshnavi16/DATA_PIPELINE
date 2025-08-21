select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select profit
from "superstore"."analytics"."stg_orders"
where profit is null



      
    ) dbt_internal_test