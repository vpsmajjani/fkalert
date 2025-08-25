import shutil
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

# Load old prices
old_prices = read_price_file('old_price.txt')

output_lines = []

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

# Only save if there are changes
if output_lines:
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    output_lines.insert(0, f"🕒 Changes logged at {timestamp}")
    output_lines.insert(1, "-" * 40)

    with open('price_changes.txt', 'a', encoding='utf-8') as out_file:
        out_file.write("\n".join(output_lines) + "\n\n")

    print("✅ Changes appended to 'price_changes.txt'")
else:
    print("✅ No changes detected. Nothing written to 'price_changes.txt'.")

# Promote latest to old
shutil.copyfile('latest_price.txt', 'old_price.txt')
print("📁 'latest_price.txt' has been copied to 'old_price.txt'")

