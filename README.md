# AI Revenue Intelligence Agent

A Streamlit + MySQL revenue analytics application with:

- Executive KPI dashboard
- Year / Market / Category filtering
- Monthly revenue and MoM growth
- Revenue anomaly detection
  - 3-month rolling baseline
  - deviation %
  - Z-Score
  - Isolation Forest (`contamination=0.10`, `random_state=42`)
  - high-confidence anomaly = Z-Score AND Isolation Forest
- Root Cause Analysis
  - Market
  - Region
  - Country
  - Category
  - Sub-category
  - Product
  - Customer Segment
- Gemini executive insights grounded in calculated analytics

## Project files

- `app.py` - Streamlit UI
- `analytics.py` - SQL analytics, anomaly detection and RCA
- `database.py` - MySQL connection
- `ai_insights.py` - Gemini integration
- `.env.example` - environment-variable template
- `requirements.txt` - Python dependencies

## Setup

1. Put these files in your project folder.
2. Keep your real `.env` file in the same folder.
3. Install dependencies:

   `pip install -r requirements.txt`

4. Start the app:

   `streamlit run app.py`

## Required database tables

- fact_sales
- dim_date
- dim_location
- dim_product
- dim_customer

The project uses direct integer key joins such as:

`fact_sales.date_key = dim_date.date_key`

## Security

Never commit your real `.env` file or Gemini API key to GitHub.
