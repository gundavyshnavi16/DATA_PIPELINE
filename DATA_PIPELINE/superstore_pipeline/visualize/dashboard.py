import pandas as pd
import matplotlib.pyplot as plt
import psycopg2

# Connect to Postgres
conn = psycopg2.connect(
    host="postgres",
    database="superstore",
    user="superuser",
    password="superpass"
)

# Load final fact table
query = """
SELECT 
    order_date, 
    total_sales, 
    total_profit, 
    profit_margin_percent 
FROM analytics.fct_daily_sales
ORDER BY order_date
"""

df = pd.read_sql(query, conn)
conn.close()

# Convert dates
df['order_date'] = pd.to_datetime(df['order_date'])

# Rolling average
df['rolling_sales'] = df['total_sales'].rolling(30).mean()

# Plotting
plt.figure(figsize=(12, 8))

# Plot 1: Total Sales
plt.subplot(2, 1, 1)
plt.plot(df['order_date'], df['total_sales'], label='Total Sales', color='blue', linewidth=1)
plt.plot(df['order_date'], df['rolling_sales'], label='30-day Avg', color='orange', linestyle='--')
plt.title('Daily Sales Over Time')
plt.ylabel('Sales')
plt.legend()

# Plot 2: Profit Margin
plt.subplot(2, 1, 2)
plt.plot(df['order_date'], df['profit_margin_percent'], color='green', linewidth=1)
plt.title('Profit Margin % Over Time')
plt.ylabel('% Profit')
plt.xlabel('Date')

plt.tight_layout()
plt.savefig('/app/visualize/sales_dashboard.png')
plt.show()
