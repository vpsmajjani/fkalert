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

old_prices = read_price_file('old_price.txt')
latest_prices = read_price_file('latest_price.txt')

print("🔄 Changed Prices:")
for code, new_price in latest_prices.items():
    old_price = old_prices.get(code)
    if old_price and old_price != new_price:
        print(f"{code}: Old = ₹{old_price}, New = ₹{new_price}")

