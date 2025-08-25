#!/bin/bash

# Print header
echo "Airline|Flight No.|Departure|Duration|Arrival|Base Fare|Tax 1|Tax 2"

# Regex for airline names (allow spaces before/after)
airlines_regex="^(IndiGo|Air India|Akasa Air)$"

block=()
flush_block() {
  # Process a complete block only if it has more than 1 field
  if [ "${#block[@]}" -ge 7 ]; then
    airline="${block[0]}"
    
    # If the flight number is missing, handle it
    if [[ "${block[1]}" =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
      # Flight number is missing, treat the departure as the flight number
      flight_no="Unknown"
      departure="${block[1]}"
      i=2
    else
      flight_no="${block[1]}"
      i=2
    fi

    # Combine additional flight numbers if present
    while [[ "${block[$i]}" =~ ^(AI|IX|QP|6E)-[0-9]+$ ]]; do
      flight_no+=" / ${block[$i]}"
      ((i++))
    done

    duration="${block[$i]}"
    arrival="${block[$i+1]}"
    fare="${block[$i+2]}"
    tax1="${block[$i+3]}"
    tax2="${block[$i+4]}"

    echo "$airline|$flight_no|$departure|$duration|$arrival|$fare|$tax1|$tax2"
  fi
}

while IFS= read -r line || [ -n "$line" ]; do
  clean_line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Detect if the line is an airline name
  if [[ "$clean_line" =~ $airlines_regex ]]; then
    # Flush the previous block if any and reset
    flush_block
    block=()
  fi

  block+=("$clean_line")
done < dump

# Flush the last block
flush_block

