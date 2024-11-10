#!/bin/bash

# User Agent and URL
UA="pleasenoban"
FETCH=100
ISC_URL="https://isc.sans.edu/api/topips/records/$FETCH/?json"

# Fetch data
response=$(curl -s -A "$UA" "$ISC_URL")

# Extract IPs and reports from the response (assuming JSON)
IP_REPORTS=$(echo "$response" | jq -r '.[] | "\(.source) \(.reports)"')

# Threshold for malicious IPs (you can change this value)
THRESHOLD=50000

# Output the reputation list
REPUTATION_FILE="reputation.list"

# Print header for Suricata compatibility
echo "# Suricata Reputation List" > "$REPUTATION_FILE"
echo "# Generated on $(date)" >> "$REPUTATION_FILE"

# Process IPs and filter them based on the threshold
echo "Malicious IPs (more than $THRESHOLD reports):"
echo "$IP_REPORTS" | while read -r ip reports; do
    if [ "$reports" -gt "$THRESHOLD" ]; then
        # Add IPs with a higher number of reports to the reputation list with a weight
        echo "$ip 100" >> "$REPUTATION_FILE"  # 100 as the weight for high-confidence IPs
        echo "$ip $reports"
    fi
done

echo "Reputation list has been saved to $REPUTATION_FILE."
