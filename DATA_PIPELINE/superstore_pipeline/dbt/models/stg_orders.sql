-- This model serves as our staging layer.
-- It's the first step where we pull raw data from our source table
-- to prepare it for further cleaning and transformation.

-- We define a temporary block of code (called a CTE) to select all the raw data.
with source as (
    select * from public.staging_orders -- This is where our initial data is located.
)

-- This is our final query.
-- We are selecting each column explicitly from our temporary block above.
-- This is a good practice to ensure the column order is always consistent.
select
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales,
    quantity,
    discount,
    profit
from source -- We pull from the temporary source block we just defined.
