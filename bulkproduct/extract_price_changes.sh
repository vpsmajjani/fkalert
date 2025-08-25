#!/bin/bash

INPUT_FILE="allpricehistory.txt"
OUTPUT_FILE="price_changes.csv"

# Header
echo "product_id,old_price,new_price,old_timestamp,new_timestamp" > "$OUTPUT_FILE"

# Process each product
awk -F, '
{
    gsub(/ /, "", $1);
    product=$1;
    timestamp=$2;
    price=$3;
    
    if (price != "") {
        key = product;
        if (!(key in first_time)) {
            first_price[key] = price;
            first_time[key] = timestamp;
        } else {
            last_price[key] = price;
            last_time[key] = timestamp;
        }
    }
}
END {
    for (k in first_price) {
        if (last_price[k] && first_price[k] != last_price[k]) {
            print k "," first_price[k] "," last_price[k] "," first_time[k] "," last_time[k];
        }
    }
}
' "$INPUT_FILE" >> "$OUTPUT_FILE"

echo "✅ Price change report saved to: $OUTPUT_FILE"
