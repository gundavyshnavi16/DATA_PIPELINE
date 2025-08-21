-- This query will find any orders where the discount is an invalid value
-- (less than 0% or greater than 100%).

select *
from {{ ref('stg_orders') }}
where discount < 0 or discount > 1