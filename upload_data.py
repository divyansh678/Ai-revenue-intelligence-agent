import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus

# ==========================
# Aiven MySQL Configuration
# ==========================
host = "mysql-3a255e0a-divyanshtv357.g.aivencloud.com"
port = "10823"
user = "avnadmin"
password = "AVNS_9WMGJVbg3PEiEIOIhaS"   # <-- Replace with your password
database = "defaultdb"

password = quote_plus(password)

engine = create_engine(
    f"mysql+mysqlconnector://{user}:{password}@{host}:{port}/{database}",
    connect_args={
        "ssl_disabled": False
    }
)

# ==========================
# Read CSV
# ==========================
df = pd.read_csv("Processed_SuperStoreOrders.csv")

print("Rows :", len(df))
print("Columns :", list(df.columns))

# ==========================
# Keep only columns that exist in stg_sales
# ==========================
columns = [
    "order_id",
    "order_date",
    "ship_date",
    "ship_mode",
    "customer_name",
    "segment",
    "state",
    "country",
    "market",
    "region",
    "product_id",
    "category",
    "sub_category",
    "product_name",
    "sales",
    "quantity",
    "discount",
    "profit",
    "shipping_cost",
    "order_priority",
    "order_year",
    "order_quarter",
    "month_number",
    "month_name",
    "year_month_text",
    "shipping_days",
    "profit_margin"
]

df = df[columns]

# ==========================
# Upload
# ==========================

import numpy as np

# Replace inf and -inf with NULL
df.replace([np.inf, -np.inf], np.nan, inplace=True)



df.to_sql(
    "stg_sales",
    con=engine,
    if_exists="append",
    index=False,
    chunksize=1000,
    method="multi"
)

print("Data uploaded successfully.")