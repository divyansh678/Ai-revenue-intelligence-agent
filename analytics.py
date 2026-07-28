import numpy as np
import pandas as pd
from sqlalchemy import text
from sklearn.ensemble import IsolationForest


# --------------------------------------------------
# FILTER HELPERS
# --------------------------------------------------

def _filter_sql(year=None, market=None, category=None):
    conditions = []
    params = {}

    if year is not None:
        conditions.append("d.year = :year")
        params["year"] = int(year)

    if market is not None:
        conditions.append("l.market = :market")
        params["market"] = market

    if category is not None:
        conditions.append("p.category = :category")
        params["category"] = category

    where_clause = ""
    if conditions:
        where_clause = "WHERE " + " AND ".join(conditions)

    return where_clause, params


def _base_joins():
    # fact_sales.date_key and dim_date.date_key are both INT in your schema.
    return """
        JOIN dim_date d
            ON f.date_key = d.date_key
        JOIN dim_location l
            ON f.location_key = l.location_key
        JOIN dim_product p
            ON f.product_key = p.product_key
        JOIN dim_customer c
            ON f.customer_key = c.customer_key
    """


# --------------------------------------------------
# FILTER VALUES
# --------------------------------------------------

def get_available_years(engine):
    df = pd.read_sql(
        text("SELECT DISTINCT year FROM dim_date ORDER BY year"),
        engine,
    )
    return df["year"].dropna().astype(int).tolist()


def get_available_markets(engine):
    df = pd.read_sql(
        text("""
            SELECT DISTINCT market
            FROM dim_location
            WHERE market IS NOT NULL
            ORDER BY market
        """),
        engine,
    )
    return df["market"].dropna().tolist()


def get_available_categories(engine):
    df = pd.read_sql(
        text("""
            SELECT DISTINCT category
            FROM dim_product
            WHERE category IS NOT NULL
            ORDER BY category
        """),
        engine,
    )
    return df["category"].dropna().tolist()


# --------------------------------------------------
# EXECUTIVE OVERVIEW
# --------------------------------------------------

def get_executive_kpis(engine, year=None, market=None, category=None):
    where_clause, params = _filter_sql(year, market, category)

    query = text(f"""
        SELECT
            COALESCE(SUM(f.sales), 0) AS total_revenue,
            COALESCE(SUM(f.profit), 0) AS total_profit,
            COUNT(DISTINCT f.order_id) AS total_orders,
            COALESCE(SUM(f.quantity), 0) AS total_quantity,
            CASE
                WHEN COALESCE(SUM(f.sales), 0) = 0 THEN 0
                ELSE SUM(f.profit) * 100.0 / SUM(f.sales)
            END AS profit_margin
        FROM fact_sales f
        {_base_joins()}
        {where_clause}
    """)

    return pd.read_sql(query, engine, params=params).iloc[0]


def get_monthly_revenue(engine, year=None, market=None, category=None):
    where_clause, params = _filter_sql(year, market, category)

    query = text(f"""
        SELECT
            d.year_month_text,
            MIN(d.full_date) AS month_date,
            SUM(f.sales) AS revenue,
            SUM(f.profit) AS profit,
            COUNT(DISTINCT f.order_id) AS orders
        FROM fact_sales f
        {_base_joins()}
        {where_clause}
        GROUP BY d.year_month_text
        ORDER BY MIN(d.full_date)
    """)

    df = pd.read_sql(query, engine, params=params)

    if not df.empty:
        df["mom_growth"] = df["revenue"].pct_change() * 100
    else:
        df["mom_growth"] = pd.Series(dtype=float)

    return df


# --------------------------------------------------
# ANOMALY DETECTION
# Preserves notebook approach:
# 3-month rolling baseline + deviation + Z-Score +
# Isolation Forest(contamination=0.10, random_state=42).
# High-confidence anomaly = Z-Score AND Isolation Forest.
# --------------------------------------------------

def get_anomaly_results(engine, year=None, market=None, category=None):
    df = get_monthly_revenue(engine, year, market, category).copy()

    if df.empty:
        for col in [
            "rolling_mean_3m", "deviation_pct", "z_score",
            "zscore_anomaly", "isolation_score",
            "isolation_anomaly", "high_confidence_anomaly",
            "anomaly_direction", "severity"
        ]:
            df[col] = pd.Series(dtype=object)
        return df

    revenue = df["revenue"].astype(float)

    # Rolling baseline uses previous months so the current month is compared
    # against history rather than helping create its own baseline.
    df["rolling_mean_3m"] = revenue.shift(1).rolling(
        window=3, min_periods=2
    ).mean()

    df["deviation_pct"] = np.where(
        df["rolling_mean_3m"].notna() & (df["rolling_mean_3m"] != 0),
        (revenue - df["rolling_mean_3m"]) * 100.0 / df["rolling_mean_3m"],
        np.nan,
    )

    std = revenue.std(ddof=0)
    if pd.isna(std) or std == 0:
        df["z_score"] = 0.0
    else:
        df["z_score"] = (revenue - revenue.mean()) / std

    df["zscore_anomaly"] = df["z_score"].abs() >= 2.0

    if len(df) >= 4 and revenue.nunique() > 1:
        model = IsolationForest(
            contamination=0.10,
            random_state=42,
        )
        x = revenue.to_numpy().reshape(-1, 1)
        prediction = model.fit_predict(x)
        df["isolation_score"] = model.decision_function(x)
        df["isolation_anomaly"] = prediction == -1
    else:
        df["isolation_score"] = 0.0
        df["isolation_anomaly"] = False

    # Notebook's high-confidence rule.
    df["high_confidence_anomaly"] = (
        df["zscore_anomaly"] & df["isolation_anomaly"]
    )

    df["anomaly_direction"] = np.select(
        [
            df["high_confidence_anomaly"] & (df["deviation_pct"] < 0),
            df["high_confidence_anomaly"] & (df["deviation_pct"] >= 0),
        ],
        ["Revenue Drop", "Revenue Spike"],
        default="Normal",
    )

    abs_z = df["z_score"].abs()
    df["severity"] = np.select(
        [
            df["high_confidence_anomaly"] & (abs_z >= 3),
            df["high_confidence_anomaly"] & (abs_z >= 2.5),
            df["high_confidence_anomaly"],
        ],
        ["Critical", "High", "Moderate"],
        default="Normal",
    )

    return df


# --------------------------------------------------
# ROOT CAUSE ANALYSIS
# --------------------------------------------------

def get_rca_level(
    engine,
    dimension,
    year=None,
    market=None,
    category=None,
    year_month_text=None,
    parent_filters=None,
    limit=15,
):
    allowed_dimensions = {
        "market": ("l.market", "Market"),
        "region": ("l.region", "Region"),
        "country": ("l.country", "Country"),
        "state": ("l.state", "State"),
        "category": ("p.category", "Category"),
        "sub_category": ("p.sub_category", "Sub-category"),
        "product_name": ("p.product_name", "Product"),
        "segment": ("c.segment", "Segment"),
    }

    if dimension not in allowed_dimensions:
        raise ValueError(f"Unsupported RCA dimension: {dimension}")

    dim_col, dim_label = allowed_dimensions[dimension]
    where_clause, params = _filter_sql(year, market, category)

    conditions = []
    if where_clause:
        conditions.append(where_clause.replace("WHERE ", "", 1))

    if year_month_text:
        conditions.append("d.year_month_text = :year_month_text")
        params["year_month_text"] = year_month_text

    parent_filters = parent_filters or {}
    for key, value in parent_filters.items():
        if value is None or key not in allowed_dimensions:
            continue
        parent_col, _ = allowed_dimensions[key]
        pname = f"parent_{key}"
        conditions.append(f"{parent_col} = :{pname}")
        params[pname] = value

    final_where = ""
    if conditions:
        final_where = "WHERE " + " AND ".join(conditions)

    query = text(f"""
        SELECT
            {dim_col} AS dimension_value,
            SUM(f.sales) AS revenue,
            SUM(f.profit) AS profit,
            COUNT(DISTINCT f.order_id) AS orders,
            SUM(f.quantity) AS quantity,
            CASE
                WHEN SUM(f.sales) = 0 THEN 0
                ELSE SUM(f.profit) * 100.0 / SUM(f.sales)
            END AS profit_margin
        FROM fact_sales f
        {_base_joins()}
        {final_where}
        AND {dim_col} IS NOT NULL
        GROUP BY {dim_col}
        ORDER BY revenue DESC
        LIMIT {int(limit)}
    """ if final_where else f"""
        SELECT
            {dim_col} AS dimension_value,
            SUM(f.sales) AS revenue,
            SUM(f.profit) AS profit,
            COUNT(DISTINCT f.order_id) AS orders,
            SUM(f.quantity) AS quantity,
            CASE
                WHEN SUM(f.sales) = 0 THEN 0
                ELSE SUM(f.profit) * 100.0 / SUM(f.sales)
            END AS profit_margin
        FROM fact_sales f
        {_base_joins()}
        WHERE {dim_col} IS NOT NULL
        GROUP BY {dim_col}
        ORDER BY revenue DESC
        LIMIT {int(limit)}
    """)

    df = pd.read_sql(query, engine, params=params)
    df.attrs["dimension_label"] = dim_label
    return df


def get_anomaly_rca(engine, anomaly_month, year=None, market=None, category=None):
    levels = [
        "market", "region", "country",
        "category", "sub_category", "product_name", "segment"
    ]

    results = {}
    for level in levels:
        results[level] = get_rca_level(
            engine=engine,
            dimension=level,
            year=year,
            market=market,
            category=category,
            year_month_text=anomaly_month,
            limit=15,
        )

    return results
