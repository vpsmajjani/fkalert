import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import re
from datetime import datetime
from collections import defaultdict

st.title("✈️ Flight Price Trend Viewer")

# Upload or use local file
file_path = "price_changes.txt"

flight_prices = defaultdict(list)

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
                flight_prices[flight_no].append((current_date, price))

# Sidebar flight filter
flight_options = list(flight_prices.keys())
selected_flights = st.sidebar.multiselect("Select Flight Numbers to Display", flight_options, default=flight_options[:3])

# Plot
fig, ax = plt.subplots(figsize=(10, 6))

for flight in selected_flights:
    data = sorted(flight_prices[flight], key=lambda x: x[0])
    dates = [d[0] for d in data]
    prices = [d[1] for d in data]
    ax.plot(dates, prices, marker="o", label=flight)

ax.set_title("Flight Price Trend")
ax.set_xlabel("Date")
ax.set_ylabel("Price (₹)")
ax.legend()
ax.grid(True)
fig.autofmt_xdate()

st.pyplot(fig)
