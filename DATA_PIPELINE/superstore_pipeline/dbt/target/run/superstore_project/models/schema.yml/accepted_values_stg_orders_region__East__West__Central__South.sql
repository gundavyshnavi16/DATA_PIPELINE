select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        region as value_field,
        count(*) as n_records

    from "superstore"."analytics"."stg_orders"
    group by region

)

select *
from all_values
where value_field not in (
    'East','West','Central','South'
)



      
    ) dbt_internal_test