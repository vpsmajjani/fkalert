#!/bin/bash

# Define known airline names
airlines_regex="^(IndiGo|Air India|Akasa Air)$"

echo "Airline|Flight No.|Departure|Duration|Arrival|Base Fare|Tax 1|Tax 2"

block=()
while IFS= read -r line || [ -n "$line" ]; do
  if [[ "$line" =~ $airlines_regex ]]; then
    # If we already have a block, process it
    if [ "${#block[@]}" -gt 0 ]; then
      if [ "${#block[@]}" -eq 8 ]; then
        printf "%s\n" "$(IFS='|'; echo "${block[*]}")"
      fi
      block=()
    fi
  fi
  block+=("$line")
done < dump

# Process the last block
if [ "${#block[@]}" -eq 8 ]; then
  printf "%s\n" "$(IFS='|'; echo "${block[*]}")"
fi

