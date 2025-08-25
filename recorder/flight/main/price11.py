import sys
import re
import shutil
import subprocess
from datetime import datetime

def extract_trip_segment(url):
    """Extracts the 'trips=' segment from the Flipkart URL."""
    match = re.search(r'trips=([^&]+)', url)
    return match.group(1) if match else "UNKNOWN-TRIP"

def format_trip_date(trip_segment):
    """Extracts and formats the date portion from the trip segment."""
    date_match = re.search(r'\d{8}', trip_segment)
    if date_match:
        return datetime.strptime(date_match.group(), "%d%m%Y").strftime("%d-%m-%Y")
    return "UNKNOWN-DATE"

def read_price_file(filepath):
    """Reads price data from a pipe-separated file."""
    price_map = {}
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.strip().split('|')
            if len(parts) >= 6:
                code = parts[1].strip()
                price = parts[5].strip().replace(',', '').replace('₹', '')
                price_map[code] = price
    return price_map

def send_email(subject, body):
    """Sends an email using mutt command-line mailer."""
    email_command = f"echo '{body}' | mutt -s '{subject}' mannabhanushali@gmail.com"
    try:
        subprocess.run(email_command, shell=True, check=True)
        print("📧 Email sent successfully.")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error sending email: {e}")

# 🎯 Accept URL as input argument
if len(sys.argv) < 2:
    print("❗ Usage: python3 price10.py '<Flipkart_URL>'")
    sys.exit(1)

url = sys.argv[1]
trip_segment = extract_trip_segment(url)
manual_date = format_trip_date(trip_segment)

print(f"✈️ Trip Segment: {trip_segment}")
print(f"📅 Date: {manual_date}")

# Load old prices
old_prices = read_price_file('old_price.txt')

output_lines = []
email_body = ""

print("🔄 Changed Prices (Full line + Old/New comparison):\n")

with open('latest_price.txt', 'r', encoding='utf-8') as f:
    for line in f:
        parts = line.strip().split('|')
        if len(parts) >= 6:
            code = parts[1].strip()
            new_price_raw = parts[5].strip()
            new_price = new_price_raw.replace(',', '').replace('₹', '')
            old_price = old_prices.get(code)

            if old_price and old_price != new_price:
                old_price_display = "₹" + "{:,}".format(int(old_price))

                block = [
                    line.strip(),
                    f"🔁 {code}: Old = {old_price_display}, New = {new_price_raw}",
                    ""
                ]

                for b in block:
                    print(b)

                output_lines.extend(block)
                email_body += "\n".join(block) + "\n"

# Only save if there are changes
if output_lines:
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    output_lines.insert(0, f"🕒 Changes logged at {timestamp}")
    output_lines.insert(1, "-" * 40)

    with open('price_changes.txt', 'a', encoding='utf-8') as out_file:
        out_file.write("\n".join(output_lines) + "\n\n")

    print("✅ Changes appended to 'price_changes.txt'")

    # ✉️ Subject includes trip segment and date
    subject = f"✈️ Price Changes: {trip_segment} on {manual_date}"
    send_email(subject, email_body)
else:
    print("✅ No changes detected. Nothing written to 'price_changes.txt'.")

# Promote latest to old
shutil.copyfile('latest_price.txt', 'old_price.txt')
print("📁 'latest_price.txt' has been copied to 'old_price.txt'")

