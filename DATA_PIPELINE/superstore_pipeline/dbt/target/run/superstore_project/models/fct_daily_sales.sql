
      
        
            delete from "superstore"."analytics"."fct_daily_sales"
            where (
                order_date) in (
                select (order_date)
                from "fct_daily_sales__dbt_tmp143155429035"
            );

        
    

    insert into "superstore"."analytics"."fct_daily_sales" ("order_date", "total_sales", "total_quantity", "total_profit", "profit_margin_percent")
    (
        select "order_date", "total_sales", "total_quantity", "total_profit", "profit_margin_percent"
        from "fct_daily_sales__dbt_tmp143155429035"
    )
  