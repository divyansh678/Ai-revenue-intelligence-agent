import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st
from sqlalchemy import text

from database import get_engine
from analytics import (
    get_available_years,
    get_available_markets,
    get_available_categories,
    get_executive_kpis,
    get_monthly_revenue,
    get_anomaly_results,
    get_anomaly_rca,
    get_rca_level,
)
from ai_insights import build_context, generate_ai_insight


# --------------------------------------------------
# PAGE CONFIG
# --------------------------------------------------

st.set_page_config(
    page_title="AI Revenue Intelligence Agent",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded",
)


# --------------------------------------------------
# STYLE
# --------------------------------------------------

st.markdown("""
<style>
.stApp {background-color:#0B1120;color:#E5E7EB;}
.block-container {padding-top:1.7rem;padding-bottom:2rem;padding-left:2.5rem;padding-right:2.5rem;}
section[data-testid="stSidebar"] {background-color:#111827;border-right:1px solid #1F2937;}
#MainMenu, footer {visibility:hidden;}
.kpi-card {background:#111827;border:1px solid #1F2937;border-radius:14px;padding:20px;min-height:125px;}
.kpi-title {color:#94A3B8;font-size:12px;font-weight:600;letter-spacing:.04em;margin-bottom:9px;}
.kpi-value {color:#F8FAFC;font-size:28px;font-weight:750;}
.kpi-positive {color:#22C55E;font-size:13px;margin-top:5px;}
.kpi-negative {color:#EF4444;font-size:13px;margin-top:5px;}
.section-title {color:#F8FAFC;font-size:20px;font-weight:650;margin-top:16px;margin-bottom:14px;}
.muted-text {color:#94A3B8;font-size:14px;}
.status-pill {display:inline-block;background:#172033;border:1px solid #26344f;border-radius:999px;padding:5px 10px;color:#CBD5E1;font-size:12px;}
</style>
""", unsafe_allow_html=True)


@st.cache_resource
def load_engine():
    return get_engine()


try:
    engine = load_engine()
    with engine.connect() as conn:
        database_name = conn.execute(text("SELECT DATABASE()")).scalar()
except Exception as exc:
    st.error("MySQL connection failed.")
    st.exception(exc)
    st.stop()


# --------------------------------------------------
# SIDEBAR + FILTERS
# --------------------------------------------------

with st.sidebar:
    st.markdown("## ◈ Revenue AI")
    st.caption("INTELLIGENCE PLATFORM")
    st.divider()

    page = st.radio(
        "Navigation",
        ["Executive Overview", "Anomaly Detection", "Root Cause Analysis", "AI Insights"],
        label_visibility="collapsed",
    )

    st.divider()
    st.markdown("### Filters")

    years = get_available_years(engine)
    markets = get_available_markets(engine)
    categories = get_available_categories(engine)

    year = st.selectbox("Year", ["All"] + [str(x) for x in years])
    market = st.selectbox("Market", ["All Markets"] + [str(x) for x in markets])
    category = st.selectbox("Category", ["All Categories"] + [str(x) for x in categories])

    st.divider()
    st.caption(f"Database: {database_name}")

selected_year = None if year == "All" else int(year)
selected_market = None if market == "All Markets" else market
selected_category = None if category == "All Categories" else category


# --------------------------------------------------
# LOAD SHARED ANALYTICS
# --------------------------------------------------

try:
    kpis = get_executive_kpis(engine, selected_year, selected_market, selected_category)
    monthly = get_monthly_revenue(engine, selected_year, selected_market, selected_category)
    anomalies = get_anomaly_results(engine, selected_year, selected_market, selected_category)
except Exception as exc:
    st.error("Analytics query failed.")
    st.exception(exc)
    st.stop()

total_revenue = float(kpis["total_revenue"] or 0)
total_profit = float(kpis["total_profit"] or 0)
total_orders = int(kpis["total_orders"] or 0)
profit_margin = float(kpis["profit_margin"] or 0)

latest_mom = 0.0
if not monthly.empty:
    valid_mom = monthly["mom_growth"].dropna()
    if not valid_mom.empty:
        latest_mom = float(valid_mom.iloc[-1])

flagged = anomalies[anomalies["high_confidence_anomaly"]].copy() if not anomalies.empty else pd.DataFrame()


# --------------------------------------------------
# HEADER
# --------------------------------------------------

st.markdown("# Revenue Intelligence")
st.markdown(
    '<p class="muted-text">AI-powered revenue monitoring, anomaly detection, root-cause analysis and executive insights.</p>',
    unsafe_allow_html=True,
)
st.markdown(
    f'<span class="status-pill">● MySQL connected · {database_name}</span>',
    unsafe_allow_html=True,
)
st.divider()


def card(title, value, note, negative=False):
    cls = "kpi-negative" if negative else "kpi-positive"
    return f"""
    <div class="kpi-card">
        <div class="kpi-title">{title}</div>
        <div class="kpi-value">{value}</div>
        <div class="{cls}">{note}</div>
    </div>
    """


# --------------------------------------------------
# EXECUTIVE OVERVIEW
# --------------------------------------------------

if page == "Executive Overview":
    st.markdown('<div class="section-title">Executive Overview</div>', unsafe_allow_html=True)

    c1, c2, c3, c4 = st.columns(4)
    c1.markdown(card("TOTAL REVENUE", f"${total_revenue:,.0f}", "● Revenue"), unsafe_allow_html=True)
    c2.markdown(card("TOTAL PROFIT", f"${total_profit:,.0f}", "● Profit", total_profit < 0), unsafe_allow_html=True)
    c3.markdown(card("TOTAL ORDERS", f"{total_orders:,}", "● Orders"), unsafe_allow_html=True)
    c4.markdown(card("PROFIT MARGIN", f"{profit_margin:.2f}%", "● Margin", profit_margin < 0), unsafe_allow_html=True)

    arrow = "▲" if latest_mom >= 0 else "▼"
    st.markdown(
        f'<p class="muted-text">Latest Monthly Revenue Change: '
        f'<span class="{"kpi-positive" if latest_mom >= 0 else "kpi-negative"}">'
        f'{arrow} {abs(latest_mom):.2f}%</span></p>',
        unsafe_allow_html=True,
    )

    st.markdown('<div class="section-title">Revenue Performance</div>', unsafe_allow_html=True)

    if monthly.empty:
        st.info("No revenue data is available for the selected filters.")
    else:
        fig = px.line(monthly, x="year_month_text", y="revenue", markers=True)
        fig.update_traces(
            line=dict(width=3),
            marker=dict(size=6),
            hovertemplate="<b>%{x}</b><br>Revenue: $%{y:,.0f}<extra></extra>",
        )
        fig.update_layout(
            xaxis_title="Month", yaxis_title="Revenue", height=430,
            paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)",
            margin=dict(l=20, r=20, t=20, b=20), showlegend=False,
        )
        fig.update_xaxes(showgrid=False)
        fig.update_yaxes(showgrid=True, tickprefix="$", tickformat=",.0f")
        st.plotly_chart(fig, use_container_width=True)


# --------------------------------------------------
# ANOMALY DETECTION
# --------------------------------------------------

elif page == "Anomaly Detection":
    st.markdown('<div class="section-title">Revenue Anomaly Detection</div>', unsafe_allow_html=True)
    st.caption("High-confidence anomaly = Z-Score anomaly AND Isolation Forest anomaly.")

    total_months = len(anomalies)
    anomaly_count = int(anomalies["high_confidence_anomaly"].sum()) if total_months else 0
    anomaly_rate = anomaly_count * 100.0 / total_months if total_months else 0
    largest_dev = (
        float(flagged["deviation_pct"].abs().max())
        if not flagged.empty and flagged["deviation_pct"].notna().any()
        else 0.0
    )

    a1, a2, a3, a4 = st.columns(4)
    a1.markdown(card("MONTHS ANALYZED", f"{total_months}", "● Monthly observations"), unsafe_allow_html=True)
    a2.markdown(card("HIGH-CONFIDENCE ANOMALIES", f"{anomaly_count}", "● Z-Score + Isolation Forest", anomaly_count > 0), unsafe_allow_html=True)
    a3.markdown(card("ANOMALY RATE", f"{anomaly_rate:.1f}%", "● Flagged months", anomaly_rate > 0), unsafe_allow_html=True)
    a4.markdown(card("LARGEST DEVIATION", f"{largest_dev:.1f}%", "● vs 3-month baseline", largest_dev > 0), unsafe_allow_html=True)

    st.markdown('<div class="section-title">Revenue vs Rolling Baseline</div>', unsafe_allow_html=True)

    if anomalies.empty:
        st.info("No monthly data is available for the selected filters.")
    else:
        fig = go.Figure()
        fig.add_trace(go.Scatter(
            x=anomalies["year_month_text"], y=anomalies["revenue"],
            mode="lines+markers", name="Revenue"
        ))
        fig.add_trace(go.Scatter(
            x=anomalies["year_month_text"], y=anomalies["rolling_mean_3m"],
            mode="lines", name="3-Month Baseline", line=dict(dash="dash")
        ))
        if not flagged.empty:
            fig.add_trace(go.Scatter(
                x=flagged["year_month_text"], y=flagged["revenue"],
                mode="markers", name="High-Confidence Anomaly",
                marker=dict(size=13, symbol="diamond")
            ))
        fig.update_layout(
            height=450, xaxis_title="Month", yaxis_title="Revenue",
            paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)",
            hovermode="x unified",
        )
        fig.update_yaxes(tickprefix="$", tickformat=",.0f")
        st.plotly_chart(fig, use_container_width=True)

        st.markdown('<div class="section-title">Detected Anomalies</div>', unsafe_allow_html=True)
        if flagged.empty:
            st.success("No high-confidence revenue anomaly was detected for the selected filters.")
        else:
            display = flagged[
                ["year_month_text", "revenue", "rolling_mean_3m", "deviation_pct",
                 "z_score", "isolation_score", "anomaly_direction", "severity"]
            ].copy()
            display.columns = [
                "Month", "Revenue", "3M Baseline", "Deviation %", "Z-Score",
                "Isolation Score", "Direction", "Severity"
            ]
            st.dataframe(display, use_container_width=True, hide_index=True)


# --------------------------------------------------
# ROOT CAUSE ANALYSIS
# --------------------------------------------------

elif page == "Root Cause Analysis":
    st.markdown('<div class="section-title">Root Cause Analysis</div>', unsafe_allow_html=True)
    st.caption("Drill through Market → Region → Country → Category → Sub-category → Product → Customer Segment.")

    anomaly_options = flagged["year_month_text"].tolist() if not flagged.empty else []
    if anomaly_options:
        selected_anomaly_month = st.selectbox(
            "Analyze anomaly month",
            anomaly_options,
            index=len(anomaly_options) - 1,
        )
        st.info(f"Analyzing high-confidence anomaly: {selected_anomaly_month}")
    else:
        selected_anomaly_month = st.selectbox(
            "Analyze month",
            monthly["year_month_text"].tolist() if not monthly.empty else ["No data"],
        )
        if selected_anomaly_month == "No data":
            st.warning("No data is available for Root Cause Analysis.")
            st.stop()
        st.info("No high-confidence anomaly exists for these filters, so RCA is showing the selected month.")

    rca = get_anomaly_rca(
        engine, selected_anomaly_month,
        selected_year, selected_market, selected_category
    )

    level_labels = {
        "market": "Market",
        "region": "Region",
        "country": "Country",
        "category": "Category",
        "sub_category": "Sub-category",
        "product_name": "Product",
        "segment": "Customer Segment",
    }

    level = st.selectbox(
        "RCA level",
        list(level_labels.keys()),
        format_func=lambda x: level_labels[x],
    )
    rca_df = rca[level]

    if rca_df.empty:
        st.warning("No RCA rows are available for this selection.")
    else:
        top = rca_df.iloc[0]
        r1, r2, r3 = st.columns(3)
        r1.metric("Top Driver", str(top["dimension_value"]))
        r2.metric("Driver Revenue", f"${float(top['revenue']):,.0f}")
        r3.metric("Driver Profit", f"${float(top['profit']):,.0f}")

        fig = px.bar(
            rca_df.head(10),
            x="revenue",
            y="dimension_value",
            orientation="h",
            hover_data=["profit", "orders", "profit_margin"],
        )
        fig.update_layout(
            height=470, yaxis_title=level_labels[level], xaxis_title="Revenue",
            paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)",
            yaxis={"categoryorder": "total ascending"},
        )
        fig.update_xaxes(tickprefix="$", tickformat=",.0f")
        st.plotly_chart(fig, use_container_width=True)

        st.dataframe(
            rca_df.rename(columns={
                "dimension_value": level_labels[level],
                "revenue": "Revenue",
                "profit": "Profit",
                "orders": "Orders",
                "quantity": "Quantity",
                "profit_margin": "Profit Margin %",
            }),
            use_container_width=True,
            hide_index=True,
        )


# --------------------------------------------------
# AI INSIGHTS
# --------------------------------------------------

elif page == "AI Insights":
    st.markdown('<div class="section-title">AI Business Insights</div>', unsafe_allow_html=True)
    st.caption("Gemini analyzes the calculated metrics; it does not query your database directly.")

    ai_month = None
    if not flagged.empty:
        ai_month = flagged["year_month_text"].iloc[-1]
    elif not monthly.empty:
        ai_month = monthly["year_month_text"].iloc[-1]

    rca_for_ai = {}
    if ai_month:
        rca_for_ai = get_anomaly_rca(
            engine, ai_month,
            selected_year, selected_market, selected_category
        )

    context = build_context(
        kpis=kpis,
        monthly=monthly,
        anomalies=anomalies,
        rca_results=rca_for_ai,
        filters={
            "year": selected_year,
            "market": selected_market,
            "category": selected_category,
        },
    )

    with st.expander("Analytics context sent to Gemini"):
        st.code(context)

    if st.button("Generate AI Executive Insight", type="primary"):
        with st.spinner("Analyzing revenue signals..."):
            insight, error = generate_ai_insight(context)

        if error:
            st.error(error)
            st.caption("Check GEMINI_API_KEY in .env and confirm your account has an available Gemini generate-content model.")
        else:
            st.markdown(insight)
