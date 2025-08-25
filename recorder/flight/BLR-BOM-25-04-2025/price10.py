import shutil
import subprocess
from datetime import datetime

def read_price_file(filepath):
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
    """ Sends an email using mutt command-line mailer. """
    email_command = f"echo '{body}' | mutt -s '{subject}' mannabhanushali@gmail.com"
    try:
        subprocess.run(email_command, shell=True, check=True)
        print("📧 Email sent successfully.")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error sending email: {e}")

# 🔢 Set date string
manual_date = "BLR-BOM-25-04-2025"

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
                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                block = [
                    line.strip(),
                    f"🔁 {code}: Old = {old_price_display}, New = {new_price_raw}  Changes logged at {timestamp}",
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

    # ✉️ Use manual date in subject
    subject = f"✈️ Price Changes Detected for {manual_date}"
    send_email(subject, email_body)
else:
    print("✅ No changes detected. Nothing written to 'price_changes.txt'.")

# Promote latest to old
shutil.copyfile('latest_price.txt', 'old_price.txt')
print("📁 'latest_price.txt' has been copied to 'old_price.txt'")

