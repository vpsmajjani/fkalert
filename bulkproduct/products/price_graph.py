import sqlite3
import pandas as pd
import streamlit as st
import plotly.express as px

# Page config
st.set_page_config(page_title="Flipkart Price Tracker", layout="wide")
st.title("📈 Flipkart Product Price Tracker")

# Connect to DB and load data
conn = sqlite3.connect("product_prices.db")
query = "SELECT * FROM product_price_history"
df = pd.read_sql_query(query, conn)

# Rename columns
df.columns = ["id", "file_name", "timestamp", "price", "rating", "url"]

# Normalize timestamp
df["timestamp"] = pd.to_datetime(df["timestamp"].str.replace("_", " "), errors="coerce")

# Extract product name fallback
df["product"] = df["file_name"]
df.loc[df["product"].isnull() | (df["product"] == ""), "product"] = df["url"].apply(
    lambda x: x.split("/")[3] if isinstance(x, str) and x.startswith("http") else "Unknown"
)

# Sidebar: Multi-product select (default 1st product)
product_list = sorted(df["product"].unique())
selected_products = st.sidebar.multiselect("Select products to compare", product_list, default=product_list[:1])

if not selected_products:
    st.warning("Please select at least one product.")
    st.stop()

# Sidebar: Date range filter
min_date = df[df["product"].isin(selected_products)]["timestamp"].min().date()
max_date = df[df["product"].isin(selected_products)]["timestamp"].max().date()
start_date, end_date = st.sidebar.date_input("Select date range", [min_date, max_date], min_value=min_date, max_value=max_date)

# Sidebar: Price alert
alert_price = st.sidebar.number_input("Set price alert (notify if price below)", min_value=0, value=0, step=1)

# Filter by products + date
filtered_df = df[
    (df["product"].isin(selected_products)) &
    (df["timestamp"].dt.date >= start_date) &
    (df["timestamp"].dt.date <= end_date)
]

st.markdown(f"## 📌 Currently Selected Products: `{', '.join(selected_products)}`")
st.markdown(f"### Date range: {start_date} to {end_date}")

if filtered_df.empty:
    st.warning("No price data available for the selected product(s) and date range.")
    st.stop()

# Plot price comparison
fig = px.line(title="Price Trends Comparison")
for product in selected_products:
    product_df = filtered_df[filtered_df["product"] == product].sort_values("timestamp")
    fig.add_scatter(
        x=product_df["timestamp"],
        y=product_df["price"],
        mode='lines+markers',
        name=product
    )
fig.update_layout(xaxis_title="Timestamp", yaxis_title="Price (INR)")
st.plotly_chart(fig, use_container_width=True)

# Product stats and links
for product in selected_products:
    st.markdown(f"### 📊 Price Summary for `{product}`")
    product_df = filtered_df[filtered_df["product"] == product].sort_values("timestamp")
    if product_df.empty:
        st.write("No data for this product in the selected date range.")
        continue

    # Get rows for min, max, current price
    max_price_row = product_df.loc[product_df["price"].idxmax()]
    min_price_row = product_df.loc[product_df["price"].idxmin()]
    current_price_row = product_df.iloc[-1]

    max_price = max_price_row["price"]
    min_price = min_price_row["price"]
    avg_price = product_df["price"].mean()
    current_price = current_price_row["price"]
    product_url = current_price_row["url"]

    st.write(f"**Max Price:** ₹{max_price:.2f} on {max_price_row['timestamp'].date()}")
    st.write(f"**Min Price:** ₹{min_price:.2f} on {min_price_row['timestamp'].date()}")
    st.write(f"**Average Price:** ₹{avg_price:.2f}")
    st.write(f"**Current Price (Latest):** ₹{current_price:.2f} on {current_price_row['timestamp'].date()}")

    # 🔔 Price alert
    if alert_price > 0 and current_price < alert_price:
        st.success(f"�� Price Alert! Current price ₹{current_price:.2f} is below your alert threshold ₹{alert_price}")

    # 🔁 Price change
    if len(product_df) >= 2:
        previous_price = product_df["price"].iloc[-2]
        price_diff = current_price - previous_price
        pct_change = (price_diff / previous_price) * 100 if previous_price else 0
        if price_diff > 0:
            st.warning(f"📈 Price Increased by ₹{price_diff:.2f} ({pct_change:.2f}%) since last update")
        elif price_diff < 0:
            st.success(f"📉 Price Dropped by ₹{abs(price_diff):.2f} ({abs(pct_change):.2f}%) since last update")
        else:
            st.info("Price remained the same since last update")

    # ✅ Best price highlight (same as min price)
    st.info(f"💰 Lowest price ₹{min_price:.2f} on {min_price_row['timestamp'].date()}")

    # 🛒 "Buy Now" link
    if product_url and isinstance(product_url, str) and product_url.startswith("http"):
        st.markdown(f"[🛒 Buy Now]({product_url})", unsafe_allow_html=True)

    # 💾 Download CSV
    csv = product_df.to_csv(index=False).encode("utf-8")
    st.download_button(
        label=f"Download {product} Price History CSV",
        data=csv,
        file_name=f"{product}_price_history.csv",
        mime="text/csv",
        key=f"download_{product}"
    )

# Optional: raw data
if st.checkbox("Show raw data table for selected products"):
    st.write(filtered_df.sort_values(["product", "timestamp"]))
