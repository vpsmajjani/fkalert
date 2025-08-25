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

print("🔄 Changed Prices (Full line + Old/New comparison):\n")

# Read latest and compare
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
                print(f"{line.strip()}")
                print(f"🔁 {code}: Old = {old_price_display}, New = {new_price_raw}")
                print()

