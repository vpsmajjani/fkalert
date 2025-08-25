import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import re
from datetime import datetime
from collections import defaultdict

st.set_page_config(layout="wide")
st.title("✈️ Flight Price Trend Viewer (Multi-Date Support)")

# Load from price_changes.txt
file_path = "price_changes.txt"
flight_data = []

with open(file_path, "r", encoding="utf-8") as f:
    current_date = None
    for line in f:
        line = line.strip()
        if line.startswith("🕒 Changes logged at"):
            match = re.search(r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}", line)
            if match:
                current_date = datetime.strptime(match.group(), "%Y-%m-%d %H:%M:%S")
        elif line.startswith("🔁") and current_date:
            match = re.search(r"🔁 (.+?): .*?New = ₹([\d,]+)", line)
            if match:
                flight_no = match.group(1)
                price = int(match.group(2).replace(",", ""))
                flight_data.append({"Date": current_date.date(), "Flight": flight_no, "Price": price, "Timestamp": current_date})

# Convert to DataFrame
df = pd.DataFrame(flight_data)

# Sidebar filters
with st.sidebar:
    st.header("🔍 Filter")
    unique_flights = df["Flight"].unique().tolist()
    selected_flights = st.multiselect("Flight Number(s)", unique_flights, default=unique_flights[:5])

    unique_dates = df["Date"].unique()
    selected_dates = st.multiselect("Date(s)", sorted(unique_dates), default=sorted(unique_dates))

# Apply filters
filtered_df = df[df["Flight"].isin(selected_flights) & df["Date"].isin(selected_dates)]

if filtered_df.empty:
    st.warning("No data for selected filters.")
else:
    st.markdown("### 📈 Flight Price Chart")

    fig, ax = plt.subplots(figsize=(12, 6))

    for flight in filtered_df["Flight"].unique():
        data = filtered_df[filtered_df["Flight"] == flight].sort_values("Timestamp")
        ax.plot(data["Timestamp"], data["Price"], marker="o", label=flight)

    ax.set_title("Flight Prices Over Time")
    ax.set_xlabel("DateTime")
    ax.set_ylabel("Price (₹)")
    ax.legend()
    ax.grid(True)
    fig.autofmt_xdate()

    st.pyplot(fig)

    with st.expander("📊 Raw Data"):
        st.dataframe(filtered_df.sort_values("Timestamp"))

    with st.expander("📁 Download CSV"):
        st.download_button("Download Filtered Data as CSV", filtered_df.to_csv(index=False), "flight_prices.csv", "text/csv")
