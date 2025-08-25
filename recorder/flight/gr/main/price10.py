import sqlite3
from datetime import datetime
import os

folder_name = os.path.basename(os.getcwd())  # e.g. BOM-BLR-17-05-2025
trip_date = "-".join(folder_name.split('-')[-3:])  # '17-05-2025'
db_file = os.path.join(os.getcwd(), 'flight_prices.db')

def parse_price(price_str):
    return int(price_str.replace('₹', '').replace(',', '').strip())

def main():
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()

    # Tables
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS flights (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            airline TEXT,
            flight_no TEXT,
            departure TEXT,
            duration TEXT,
            arrival TEXT,
            base_fare INTEGER,
            tax1 INTEGER,
            tax2 INTEGER,
            trip_date TEXT,
            last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS price_changes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            flight_id INTEGER,
            old_price INTEGER,
            new_price INTEGER,
            change_time DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (flight_id) REFERENCES flights(id)
        )
    ''')

    conn.commit()

    # Read from latest_price.txt
    with open('latest_price.txt', 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.strip().split('|')
            if len(parts) < 8:
                continue
            airline, flight_no, departure, duration, arrival, base_fare_str, tax1_str, tax2_str = parts
            base_fare = parse_price(base_fare_str)
            tax1 = parse_price(tax1_str)
            tax2 = parse_price(tax2_str)

            # Lookup
            cursor.execute('''
                SELECT id, base_fare FROM flights
                WHERE airline=? AND flight_no=? AND departure=? AND trip_date=?
            ''', (airline, flight_no, departure, trip_date))
            row = cursor.fetchone()

            if row:
                flight_id, old_base = row
                if old_base != base_fare:
                    cursor.execute('''
                        INSERT INTO price_changes (flight_id, old_price, new_price)
                        VALUES (?, ?, ?)
                    ''', (flight_id, old_base, base_fare))

                    cursor.execute('''
                        UPDATE flights SET base_fare=?, tax1=?, tax2=?, last_updated=CURRENT_TIMESTAMP
                        WHERE id=?
                    ''', (base_fare, tax1, tax2, flight_id))

                    print(f"🔁 {flight_no}: ₹{old_base} -> ₹{base_fare}")
            else:
                cursor.execute('''
                    INSERT INTO flights (airline, flight_no, departure, duration, arrival,
                        base_fare, tax1, tax2, trip_date)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (airline, flight_no, departure, duration, arrival, base_fare, tax1, tax2, trip_date))
                print(f"🆕 Added: {flight_no} - ₹{base_fare}")

    conn.commit()

    # Check for recent changes
    cursor.execute('''
        SELECT f.airline, f.flight_no, pc.old_price, pc.new_price, pc.change_time
        FROM price_changes pc
        JOIN flights f ON pc.flight_id = f.id
        WHERE pc.change_time >= datetime('now', '-1 hour')
    ''')

    changes = cursor.fetchall()
    if changes:
        print("\n📌 Recent Changes:")
        for airline, flight_no, old, new, ts in changes:
            print(f"{ts}: {airline} {flight_no} ₹{old} → ₹{new}")
    else:
        print("✅ No changes in the last hour.")

    conn.close()

if __name__ == "__main__":
    main()
