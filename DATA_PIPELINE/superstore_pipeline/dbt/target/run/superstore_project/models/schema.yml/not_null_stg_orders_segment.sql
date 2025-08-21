select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select segment
from "superstore"."analytics"."stg_orders"
where segment is null



      
    ) dbt_internal_test