import sqlite3
import pandas as pd
import streamlit as st
import matplotlib.pyplot as plt

st.title("📈 Flipkart Product Price Tracker")

# Connect to SQLite database
conn = sqlite3.connect("limited_product_prices.db")
query = "SELECT * FROM limited_product_price_history"
df = pd.read_sql_query(query, conn)
df.columns = ["id", "file_name", "timestamp", "price", "rating", "url"]
df["timestamp"] = pd.to_datetime(df["timestamp"].str.replace("_", " "), errors="coerce")

# Extract product name
df["product"] = df["file_name"]
df.loc[df["product"].isnull() | (df["product"] == ""), "product"] = df["url"].apply(
    lambda x: x.split("/")[3] if isinstance(x, str) and x.startswith("http") else "Unknown"
)

product_list = sorted(df["product"].unique())

# Auto-focus the selectbox
st.sidebar.markdown(
    """
    <style>
        div[data-baseweb="select"] > div {
            outline: 2px solid #1a73e8 !important;
        }
    </style>
    <script>
        const sel = window.parent.document.querySelector('div[data-baseweb="select"]');
        if (sel) sel.focus();
    </script>
    """,
    unsafe_allow_html=True
)

# Product selector
selected_product = st.sidebar.selectbox("Select a product", product_list, key="product_select")

# Filter data and plot
filtered_df = df[df["product"] == selected_product].sort_values("timestamp")
fig, ax = plt.subplots()
ax.plot(filtered_df["timestamp"], filtered_df["price"], marker='o', linestyle='-')
ax.set_title(f"Price Trend for: {selected_product}")
ax.set_xlabel("Timestamp")
ax.set_ylabel("Price (INR)")
plt.xticks(rotation=45)
plt.tight_layout()
st.pyplot(fig)

if st.checkbox("Show raw data table"):
    st.write(filtered_df)
