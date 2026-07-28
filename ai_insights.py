import os
from dotenv import load_dotenv

load_dotenv()


def build_context(kpis, monthly, anomalies, rca_results, filters):
    revenue = float(kpis.get("total_revenue", 0) or 0)
    profit = float(kpis.get("total_profit", 0) or 0)
    orders = int(kpis.get("total_orders", 0) or 0)
    margin = float(kpis.get("profit_margin", 0) or 0)

    latest_mom = 0.0
    if not monthly.empty and "mom_growth" in monthly:
        valid = monthly["mom_growth"].dropna()
        if not valid.empty:
            latest_mom = float(valid.iloc[-1])

    anomaly_rows = []
    if not anomalies.empty:
        flagged = anomalies[anomalies["high_confidence_anomaly"]]
        for _, row in flagged.tail(8).iterrows():
            anomaly_rows.append(
                f"- {row['year_month_text']}: revenue ${row['revenue']:,.0f}, "
                f"deviation {row['deviation_pct']:.2f}%, "
                f"z-score {row['z_score']:.2f}, "
                f"{row['anomaly_direction']}, severity {row['severity']}"
            )

    driver_rows = []
    for level, df in rca_results.items():
        if df is None or df.empty:
            continue
        top = df.iloc[0]
        driver_rows.append(
            f"- {level}: {top['dimension_value']} | "
            f"revenue ${top['revenue']:,.0f} | "
            f"profit ${top['profit']:,.0f} | "
            f"margin {top['profit_margin']:.2f}%"
        )

    return f"""
FILTERS
Year: {filters.get('year') or 'All'}
Market: {filters.get('market') or 'All'}
Category: {filters.get('category') or 'All'}

EXECUTIVE METRICS
Revenue: ${revenue:,.0f}
Profit: ${profit:,.0f}
Orders: {orders:,}
Profit margin: {margin:.2f}%
Latest month-over-month revenue growth: {latest_mom:.2f}%

HIGH-CONFIDENCE ANOMALIES
{chr(10).join(anomaly_rows) if anomaly_rows else '- No high-confidence anomaly detected for these filters.'}

ROOT-CAUSE / DRIVER SNAPSHOT
{chr(10).join(driver_rows) if driver_rows else '- No RCA rows available.'}
""".strip()

def _choose_model(client):
    return "gemini-3.6-flash"


def generate_ai_insight(context):
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        return None, "GEMINI_API_KEY is missing from your .env file."

    try:
        from google import genai
        client = genai.Client(api_key=api_key)

        model = _choose_model(client)
        print("Selected model:", model)

        prompt = f"""
You are a senior revenue intelligence analyst supporting executives.

Use ONLY the supplied analytics. Do not invent causes, numbers, products,
markets, or explanations that are not supported by the data.

DATA:
{context}

Write a concise report using these exact headings:

### Executive Summary
### Revenue & Profit Signals
### Anomaly Interpretation
### Root-Cause Signals
### Recommended Actions

For recommended actions, give 3 to 5 practical actions.
Clearly distinguish observed facts from hypotheses.
"""

        response = client.models.generate_content(
            model=model,
            contents=prompt,
        )
        print("Response received")
        
        text_value = getattr(response, "text", None)
        if not text_value:
            return None, "Gemini returned an empty response."

        return text_value, None

    except Exception as exc:
        return None, f"Gemini request failed: {exc}"
