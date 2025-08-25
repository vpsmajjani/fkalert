import sqlite3
import pandas as pd
import streamlit as st
import matplotlib.pyplot as plt

# Set Streamlit app title
st.title("📈 Flipkart Product Price Tracker")

# Connect to SQLite database
conn = sqlite3.connect("product_prices.db")

# Load the table
query = "SELECT * FROM product_price_history"
df = pd.read_sql_query(query, conn)

# Rename columns
df.columns = ["id", "file_name", "timestamp", "price", "rating", "url"]

# Normalize timestamp (replace "_" with space)
df["timestamp"] = pd.to_datetime(df["timestamp"].str.replace("_", " "), errors="coerce")

# Extract product name from file or URL as fallback
df["product"] = df["file_name"]
df.loc[df["product"].isnull() | (df["product"] == ""), "product"] = df["url"].apply(
    lambda x: x.split("/")[3] if isinstance(x, str) and x.startswith("http") else "Unknown"
)

# Sidebar - select a product
product_list = sorted(df["product"].unique())
selected_product = st.sidebar.selectbox("Select a product", product_list)

# Filter data for the selected product
filtered_df = df[df["product"] == selected_product].sort_values("timestamp")

# Calculate max, min, avg, and current prices
max_price = filtered_df["price"].max()
min_price = filtered_df["price"].min()
avg_price = filtered_df["price"].mean()
current_price = filtered_df["price"].iloc[-1] if not filtered_df.empty else None

# Display the stats in Streamlit
st.markdown(f"### Price Summary for {selected_product}")
st.write(f"**Max Price:** ₹{max_price:.2f}")
st.write(f"**Min Price:** ₹{min_price:.2f}")
st.write(f"**Average Price:** ₹{avg_price:.2f}")
if current_price is not None:
    st.write(f"**Current Price (Latest):** ₹{current_price:.2f}")
else:
    st.write("No price data available.")

# Plotting
fig, ax = plt.subplots()
ax.plot(filtered_df["timestamp"], filtered_df["price"], marker='o', linestyle='-')
ax.set_title(f"Price Trend for: {selected_product}")
ax.set_xlabel("Timestamp")
ax.set_ylabel("Price (INR)")
plt.xticks(rotation=45)
plt.tight_layout()

# Display chart
st.pyplot(fig)

# Optional: Show raw data
if st.checkbox("Show raw data table"):
    st.write(filtered_df)
