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

# Load old prices for comparison
old_prices = read_price_file('old_price.txt')

print("🔄 Changed Prices (with full line):\n")

# Read and process latest file
with open('latest_price.txt', 'r', encoding='utf-8') as f:
    for line in f:
        parts = line.strip().split('|')
        if len(parts) >= 6:
            code = parts[1].strip()
            new_price = parts[5].strip().replace(',', '').replace('₹', '')
            old_price = old_prices.get(code)
            if old_price and old_price != new_price:
                print(line.strip())  # Print full line from latest file

