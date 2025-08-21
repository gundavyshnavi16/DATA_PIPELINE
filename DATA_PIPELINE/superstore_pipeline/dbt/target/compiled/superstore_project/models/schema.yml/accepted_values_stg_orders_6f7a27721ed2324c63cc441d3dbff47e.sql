
    
    

with all_values as (

    select
        quantity as value_field,
        count(*) as n_records

    from "superstore"."analytics"."stg_orders"
    group by quantity

)

select *
from all_values
where value_field not in (
    '1','2','3','4','5','6','7','8','9','10'
)


