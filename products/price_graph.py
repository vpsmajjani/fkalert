import sqlite3
from pathlib import Path
from datetime import timedelta

import pandas as pd
import streamlit as st
import plotly.graph_objects as go
import plotly.express as px

# -----------------------------
# Page config
# -----------------------------
st.set_page_config(page_title="Flipkart Price Tracker", layout="wide")

# Optional: button styling
st.markdown("""
<style>
div.stButton > button {
  background-color: #5e1376; color: #fff; border-radius: 10px;
  padding: 0.40rem 0.90rem; border: 0; font-weight: 600;
}
div.stButton > button:hover { background-color: #781a95; }
</style>
""", unsafe_allow_html=True)

# -----------------------------
# Header
# -----------------------------
col1, col2 = st.columns([1, 5])
with col1:
    st.image("https://cdn-icons-png.flaticon.com/512/1170/1170576.png", width=50)
with col2:
    st.markdown("### **Flipkart Product Price Tracker**")
    st.caption("Track product prices, ratings, and trends over time.")

# -----------------------------
# Load data
# -----------------------------
DB_PATH = "limited_product_prices.db"
if not Path(DB_PATH).exists():
    st.error("Database 'limited_product_prices.db' not found in the working directory.")
    st.stop()

conn = sqlite3.connect(DB_PATH)
query = "SELECT * FROM limited_product_price_history"
df = pd.read_sql_query(query, conn)

# Expected columns: id, file_name, timestamp, price, rating, url
df.columns = ["id", "file_name", "timestamp", "price", "rating", "url"]

# Normalize timestamp and sort
df["timestamp"] = pd.to_datetime(df["timestamp"].astype(str).str.replace("_", " "), errors="coerce")
df = df.dropna(subset=["timestamp"]).sort_values("timestamp")

# -----------------------------
# Derive clean product names that are searchable in the multiselect
# -----------------------------
# Start from file_name; if empty, fall back to URL path segment
def derive_product(row):
    name = str(row.get("file_name") or "").strip()
    if not name:
        u = row.get("url")
        if isinstance(u, str) and u.startswith("http"):
            parts = [p for p in u.split("/") if p]
            # take the last non-empty segment as a fallback
            if len(parts) >= 1:
                name = parts[-1]
            else:
                name = "Unknown"
        else:
            name = "Unknown"
    # Clean up typical slug formats so typing like "mouse" works
    if name.startswith("price_"):
        name = name[len("price_"):]
    name = name.replace("-", " ").replace("_", " ")
    return name

df["product"] = df.apply(derive_product, axis=1)

# Canonical option values (unchanged identifiers) and human labels (searchable)
# Use the original df["file_name"] or slug as the internal value to keep uniqueness
df["product_value"] = df["file_name"].fillna(df["product"])
all_values = sorted(df["product_value"].dropna().astype(str).unique().tolist())

# Build value -> label map that the Multiselect will display (the search matches this label)
label_map = {}
for _, row in df[["product_value", "product"]].drop_duplicates().iterrows():
    value = str(row["product_value"])
    label = str(row["product"]).strip()
    # Optional: shorten very long labels
    label_map[value] = (label[:80] + "…") if len(label) > 80 else label

# -----------------------------
# Sidebar controls (single Multiselect only)
# -----------------------------
default_products = all_values[:1] if all_values else []

selected_products = st.sidebar.multiselect(
    "Select products to compare",
    options=all_values,
    default=st.session_state.get("selected_products", default_products),
    format_func=lambda v: label_map.get(str(v), str(v)),
    key="selected_products",
    help="Start typing in this box to filter the list (e.g., mouse)."
)

if not selected_products:
    st.warning("Please select at least one product.")
    st.stop()

# Map selections back to displayed labels to show in UI
selected_labels = [label_map.get(v, v) for v in selected_products]

# Subset using the internal values
sub = df[df["product_value"].isin(selected_products)].copy()
min_ts = sub["timestamp"].min()
max_ts = sub["timestamp"].max()
if pd.isna(min_ts) or pd.isna(max_ts):
    st.warning("No valid timestamp data.")
    st.stop()

# Sidebar date range picker
start_date, end_date = st.sidebar.date_input(
    "Select date range",
    [min_ts.date(), max_ts.date()],
    min_value=min_ts.date(),
    max_value=max_ts.date()
)

# Persist sidebar selection so "Reset" can restore it
st.session_state.sidebar_dates = (start_date, end_date)

# Price alert
alert_price = st.sidebar.number_input("Set price alert (notify if price below)", min_value=0, value=0, step=1)

# Download all data
with st.sidebar:
    st.download_button(
        label="📥 Download All Data (CSV)",
        data=df.to_csv(index=False).encode("utf-8"),
        file_name="all_product_prices.csv",
        mime="text/csv"
    )

# -----------------------------
# Quick ranges
# -----------------------------
def calc_quick_ranges(min_ts, max_ts):
    dmin, dmax = min_ts.date(), max_ts.date()
    return {
        "All": (dmin, dmax),
        "1Y": (max(dmin, dmax - timedelta(days=365)), dmax),
        "6M": (max(dmin, dmax - timedelta(days=182)), dmax),
        "3M": (max(dmin, dmax - timedelta(days=92)), dmax),
        "1M": (max(dmin, dmax - timedelta(days=31)), dmax),
        "7D": (max(dmin, dmax - timedelta(days=7)), dmax),
    }

qr = calc_quick_ranges(min_ts, max_ts)

# Initialize active dates with sidebar selection
if "current_dates" not in st.session_state:
    st.session_state.current_dates = (start_date, end_date)
active_start, active_end = st.session_state.current_dates

# -----------------------------
# Filtered view (use label for readability)
# -----------------------------
filtered_df = sub[
    (sub["timestamp"].dt.date >= active_start) &
    (sub["timestamp"].dt.date <= active_end)
].copy()

# Attach the pretty label for plotting/legends
filtered_df["product_label"] = filtered_df["product_value"].map(label_map)

st.write(f"**📌 Selected Products:** `{', '.join(selected_labels)}`")
st.write(f"**📅 Date Range:** {active_start} to {active_end}")

last_updated = df["timestamp"].max()
st.caption(f"🕒 Last update: {last_updated.strftime('%Y-%m-%d %H:%M:%S')}")

if filtered_df.empty:
    st.warning("No price data available for the selected product(s) and date range.")
    st.stop()

# -----------------------------
# Price chart
# -----------------------------
fig = go.Figure()
palette = px.colors.qualitative.Pastel + px.colors.qualitative.Set2
legend_products = sorted(filtered_df["product_label"].dropna().unique().tolist())
color_map = {p: palette[i % len(palette)] for i, p in enumerate(legend_products)}

for product in legend_products:
    product_df = filtered_df[filtered_df["product_label"] == product].sort_values("timestamp")
    if product_df.empty:
        continue

    col = color_map[product]
    if isinstance(col, str) and col.startswith("rgb("):
        fill_col = col.replace("rgb", "rgba").replace(")", ",0.25)")
    else:
        fill_col = "rgba(155, 89, 182, 0.25)"  # fallback

    fig.add_trace(go.Scatter(
        x=product_df["timestamp"],
        y=product_df["price"],
        mode="lines+markers",
        name=product,
        line_shape="hv",
        line=dict(width=2, color=color_map[product]),
        marker=dict(size=4, color=color_map[product]),
        fill="tozeroy",
        fillcolor=fill_col,
        hovertemplate="<b>%{x|%a %b %d %Y}</b><br>Price: ₹%{y:.0f}<extra></extra>",
    ))

fig.update_layout(
    title="Price Trends Comparison",
    xaxis_title="",
    yaxis_title="Price (INR)",
    hovermode="x unified",
    legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="left", x=0),
    margin=dict(l=60, r=20, t=60, b=90),
    plot_bgcolor="white",
)

fig.update_xaxes(
    range=[pd.to_datetime(active_start), pd.to_datetime(active_end) + pd.Timedelta(days=1)],
    tickangle=45,
    tickformat="%b %d",
    showgrid=False,
    showline=True,
    linecolor="rgba(0,0,0,0.3)",
    ticks="outside",
    tickcolor="rgba(0,0,0,0.3)",
    ticklen=6,
    automargin=True,
    nticks=30,
)

fig.update_yaxes(
    showgrid=True,
    gridcolor="rgba(0,0,0,0.06)",
    zeroline=False,
    showline=True,
    linecolor="rgba(0,0,0,0.3)"
)

st.plotly_chart(fig, use_container_width=True)

# -----------------------------
# Range buttons
# -----------------------------
st.markdown("<div style='height:8px;'></div>", unsafe_allow_html=True)
c1, c2, c3, c4, c5, c6, c7 = st.columns([1,1,1,1,1,1,1])
if c1.button("All", key="btn_all_bottom"):
    st.session_state.current_dates = qr["All"]
if c2.button("1Y", key="btn_1y_bottom"):
    st.session_state.current_dates = qr["1Y"]
if c3.button("6M", key="btn_6m_bottom"):
    st.session_state.current_dates = qr["6M"]
if c4.button("3M", key="btn_3m_bottom"):
    st.session_state.current_dates = qr["3M"]
if c5.button("1M", key="btn_1m_bottom"):
    st.session_state.current_dates = qr["1M"]
if c6.button("7D", key="btn_7d_bottom"):
    st.session_state.current_dates = qr["7D"]
if c7.button("Reset", key="btn_reset_bottom"):
    st.session_state.current_dates = st.session_state.sidebar_dates

if (active_start, active_end) != st.session_state.current_dates:
    st.rerun()

# -----------------------------
# Optional: rating trend chart
# -----------------------------
if st.checkbox("Show rating trend chart"):
    fig_rating = px.line(
        filtered_df.sort_values("timestamp"),
        x="timestamp", y="rating", color="product_label",
        title="Product Rating Trend Over Time",
        markers=False
    )
    fig_rating.update_traces(line_shape="hv", fill="tozeroy", opacity=0.25,
                             hovertemplate="<b>%{x|%a %b %d %Y}</b><br>Rating: %{y:.2f}<extra></extra>")
    fig_rating.update_xaxes(
        range=[pd.to_datetime(active_start), pd.to_datetime(active_end) + pd.Timedelta(days=1)],
        tickangle=45, tickformat="%b %d", automargin=True
    )
    fig_rating.update_yaxes(showgrid=True, gridcolor="rgba(0,0,0,0.06)")
    st.plotly_chart(fig_rating, use_container_width=True)

# -----------------------------
# Product stats and links
# -----------------------------
for value in selected_products:
    label = label_map.get(value, value)
    st.write(f"**📊 Price Summary for `{label}`**")

    product_df = filtered_df[filtered_df["product_value"] == value].sort_values("timestamp")
    if product_df.empty:
        st.info("No data for this product in the selected date range.")
        continue

    max_price_row = product_df.loc[product_df["price"].idxmax()]
    min_price_row = product_df.loc[product_df["price"].idxmin()]
    current_price_row = product_df.iloc[-1]

    max_price = float(max_price_row["price"])
    min_price = float(min_price_row["price"])
    avg_price = float(product_df["price"].mean())
    current_price = float(current_price_row["price"])
    previous_price = float(product_df["price"].iloc[-2]) if len(product_df) >= 2 else current_price
    product_url = current_price_row.get("url")
    rating = current_price_row.get("rating")

    col1, col2, col3 = st.columns(3)
    col1.metric("💰 Min Price", f"₹{min_price:.2f}", f"on {min_price_row['timestamp'].date()}")
    col2.metric("📈 Max Price", f"₹{max_price:.2f}", f"on {max_price_row['timestamp'].date()}")
    col3.metric("📊 Avg Price", f"₹{avg_price:.2f}")

    st.write(f"**Current Price (Latest):** ₹{current_price:.2f} on {current_price_row['timestamp'].date()}")

    if pd.notnull(rating):
        st.write(f"**⭐ Latest Rating:** {rating}")

    if alert_price > 0 and current_price < alert_price:
        st.success(f"🔔 Price Alert! Current price ₹{current_price:.2f} is below your alert threshold ₹{alert_price}")

    price_diff = current_price - previous_price
    if price_diff > 0:
        pct_change = (price_diff / previous_price) * 100 if previous_price else 0
        st.error(f"📈 Price Increased: ₹{price_diff:.2f} ({pct_change:.2f}%)")
    elif price_diff < 0:
        pct_change = (price_diff / previous_price) * 100 if previous_price else 0
        st.success(f"📉 Price Dropped: ₹{abs(price_diff):.2f} ({abs(pct_change):.2f}%)")
    else:
        st.info("⏸️ Price Unchanged")

    st.info(f"💰 Lowest price ₹{min_price:.2f} on {min_price_row['timestamp'].date()}")

    if isinstance(product_url, str) and product_url.startswith("http"):
        st.markdown(f"[🛒 Buy Now]({product_url})", unsafe_allow_html=True)

    csv = product_df.to_csv(index=False).encode("utf-8")
    st.download_button(
        label=f"📥 Download {label} Price History CSV",
        data=csv,
        file_name=f"{label.replace(' ', '_')}_price_history.csv",
        mime="text/csv",
        key=f"download_{value}"
    )

# -----------------------------
# Raw data table
# -----------------------------
with st.expander("🔍 Show raw data table for selected products"):
    st.dataframe(filtered_df.sort_values(["product_label", "timestamp"]))
