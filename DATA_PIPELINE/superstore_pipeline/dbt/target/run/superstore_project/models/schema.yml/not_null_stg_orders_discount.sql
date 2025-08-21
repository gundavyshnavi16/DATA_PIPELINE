select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select discount
from "superstore"."analytics"."stg_orders"
where discount is null



      
    ) dbt_internal_test