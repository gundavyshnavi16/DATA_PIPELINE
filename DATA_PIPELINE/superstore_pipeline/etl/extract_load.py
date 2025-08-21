import pandas as pd
import psycopg2

SRC = "data/superstore.csv"  # <-- read inside container only


df = pd.read_csv(SRC, engine="python", encoding="ISO-8859-1")

# Drop Row ID if present, normalize headers
if "Row ID" in df.columns:
    df = df.drop(columns=["Row ID"])
df.columns = [c.lower().replace(" ", "_").replace("-", "_") for c in df.columns]

df["order_date"] = pd.to_datetime(df["order_date"]).dt.date
df["ship_date"] = pd.to_datetime(df["ship_date"]).dt.date

conn = psycopg2.connect(host="postgres", port="5432", database="superstore",
                        user="superuser", password="superpass")
cur = conn.cursor()
cur.execute("TRUNCATE TABLE staging_orders;")

insert_query = """
    INSERT INTO staging_orders (
        order_id, order_date, ship_date, ship_mode,
        customer_id, customer_name, segment, country,
        city, state, postal_code, region,
        product_id, category, sub_category, product_name,
        sales, quantity, discount, profit
    ) VALUES (
        %s, %s, %s, %s,
        %s, %s, %s, %s,
        %s, %s, %s, %s,
        %s, %s, %s, %s,
        %s, %s, %s, %s
    )
"""
#  use copy_expert for large datasets
for _, row in df.iterrows():   
    cur.execute(insert_query, (
        row["order_id"], row["order_date"], row["ship_date"], row["ship_mode"],
        row["customer_id"], row["customer_name"], row["segment"], row["country"],
        row["city"], row["state"], str(row["postal_code"]), row["region"],
        row["product_id"], row["category"], row["sub_category"], row["product_name"],
        float(row["sales"]), int(row["quantity"]), float(row["discount"]), float(row["profit"])
    ))
    
print(" Data loaded into staging_orders")

import datetime

# Create metadata table if it doesn't exist
cur.execute("""
    CREATE TABLE IF NOT EXISTS pipeline_metadata (
        run_id SERIAL PRIMARY KEY,
        run_timestamp TIMESTAMP,
        source_row_count INTEGER,
        rows_loaded INTEGER,
        model_run_status TEXT,
        tests_passed INTEGER,
        tests_failed INTEGER
    )
""")

# Get source row count
source_row_count = len(df)
cur.execute("SELECT COUNT(*) FROM staging_orders;")
rows_loaded = cur.fetchone()[0]

# Insert metadata record
cur.execute("""
    INSERT INTO pipeline_metadata (
        run_timestamp, source_row_count, rows_loaded, model_run_status, tests_passed, tests_failed
    )
    VALUES (%s, %s, %s, %s, %s, %s)
""", (
    datetime.datetime.utcnow(), source_row_count, rows_loaded,
    'pending', 0, 0
))

conn.commit()
cur.close()
conn.close()
