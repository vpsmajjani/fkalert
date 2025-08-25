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
                output_lines.append(line.strip())
                output_lines.append(f"🔁 {code}: Old = {old_price_display}, New = {new_price_raw}")
                output_lines.append("")  # Blank line for readability

# Save to file
with open('price_changes.txt', 'w', encoding='utf-8') as out_file:
    out_file.write("\n".join(output_lines))

print("✅ Changes saved to 'price_changes.txt'")

