#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Error: Invalid number of arguments."
  echo "Required number of arguments: 1"
  exit 1
fi

input_file="$1"
output_file="output.txt"

> "$output_file"

while IFS= read -r line; do
  frame_time=$(echo "$line" | grep -oP '(?<="frame.time": ).+')
  wlan_fc_type=$(echo "$line" | grep -oP '(?<="wlan.fc.type": ).+')
  wlan_fc_subtype=$(echo "$line" | grep -oP '(?<="wlan.fc.subtype": ).+')

  if [[ -n "$frame_time" || -n "$wlan_fc_type" || -n "$wlan_fc_subtype" ]]; then
    echo "\"frame.time\": $frame_time" >> "$output_file"
    echo "\"wlan.fc.type\": $wlan_fc_type" >> "$output_file"
    echo "\"wlan.fc.subtype\": $wlan_fc_subtype" >> "$output_file"
    echo "" >> "$output_file"
  fi
done < "$input_file"
exit 0

