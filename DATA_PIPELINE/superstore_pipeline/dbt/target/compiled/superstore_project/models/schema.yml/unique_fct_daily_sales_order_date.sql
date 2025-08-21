
    
    

select
    order_date as unique_field,
    count(*) as n_records

from "superstore"."analytics"."fct_daily_sales"
where order_date is not null
group by order_date
having count(*) > 1


