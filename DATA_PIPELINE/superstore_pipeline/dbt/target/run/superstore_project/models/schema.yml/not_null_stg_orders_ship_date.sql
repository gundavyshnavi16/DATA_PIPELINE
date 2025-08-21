select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ship_date
from "superstore"."analytics"."stg_orders"
where ship_date is null



      
    ) dbt_internal_test