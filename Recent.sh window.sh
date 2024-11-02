#!/bin/bash

# Step 1: Define the user-agent with your GitHub username
USER_AGENT="kingliltaj"

# Step 2: Fetch data from the SANS API for recent domains
curl --user-agent 'kingliltaj' 'https://isc.sans.edu/api/recentdomains?json' |jq '. []'

jq -r 'map(select(.domainname != null and .ip != null)) | .[] | "alert http any any -> any any (msg:\"Suspicious domain access: \(.domainname)\"; content:\"\(.domainname)\"; http_host; sid:\(100000 + (.ip | gsub("\\."; ""; "g") | tonumber)); rev:1;)"' > suricata_rules.rules

# Step 3: Create Suricata rules from the fetched domain data
> suricata.rules # Clear previous rules
SID=1000001 # Starting SID for Suricata rules
while IFS=, read -r domain date; do
    echo "alert dns any any -> any any (msg:\"Alert for $domain\"; content:\"$domain\"; nocase; sid:$SID; rev:1;)" >> suricata.rules
    ((SID++)) # Increment SID for each rule
done < recent_domains.csv

# Optional: Testing by generating traffic
# Uncomment the lines below to capture traffic and generate pings to test Suricata rules
# Replace 'recentdomain.tld' with actual domains from recent_domains.csv for testing
# sudo tcpdump -c 15 -i eth0 -w out.pcap & ping -c 3 recentdomain.tld

# Step 4: Clean up entries older than a month
# (This requires a file to track unique entries, create recent.list if needed)
if [ -f recent.list ]; then
    find recent.list -mtime +30 -exec rm {} \;
fi

# Note: Add this script to cron to run daily
# To set this up, run `crontab -e` and add:
# 0 0 * * * /path/to/your/recent.sh
