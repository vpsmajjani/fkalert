#!/bin/bash

echo "Airline|Flight No.|Departure|Duration|Arrival|Base Fare|Tax 1|Tax 2"

airlines_regex="^(IndiGo|Air India|Akasa Air)$"
block=()

flush_block() {
  if [ "${#block[@]}" -ge 8 ]; then
    # Merge extra fields (like dual flight numbers)
    airline="${block[0]}"
    flight_no="${block[1]}"
    i=2

    # If next value looks like another flight number (e.g., starts with AI- or IX-), append it
    while [[ "${block[$i]}" =~ ^(AI|IX|QP|6E)-[0-9]+$ ]]; do
      flight_no+=" / ${block[$i]}"
      ((i++))
    done

    departure="${block[$i]}"
    duration="${block[$i+1]}"
    arrival="${block[$i+2]}"
    fare="${block[$i+3]}"
    tax1="${block[$i+4]}"
    tax2="${block[$i+5]}"

    echo "$airline|$flight_no|$departure|$duration|$arrival|$fare|$tax1|$tax2"
  fi
}

while IFS= read -r line || [ -n "$line" ]; do
  if [[ "$line" =~ $airlines_regex ]]; then
    flush_block
    block=()
  fi
  block+=("$line")
done < dump2

flush_block

