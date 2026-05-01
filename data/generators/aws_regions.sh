#!/bin/bash

# Configuration
SOURCE_NAME="GitHub (jsonmaur/aws-regions)"
URL="https://raw.githubusercontent.com/jsonmaur/aws-regions/master/regions.json"
FILE="regions.json"
ETAG_FILE="regions.etag"
MOD_DATE_FILE="regions.last_mod"

# 1. Fetch headers to check status and last-modified date
RESPONSE_HEADERS=$(curl -s -I \
    --etag-compare "$ETAG_FILE" \
    --etag-save "$ETAG_FILE" \
    "$URL")

# Extract the HTTP status code
STATUS=$(echo "$RESPONSE_HEADERS" | grep HTTP | tail -1 | awk '{print $2}')

echo "------------------------------------------"
echo "SOURCE: $SOURCE_NAME"
echo "URL:    $URL"

if [ "$STATUS" -eq 200 ]; then
    # File changed: Download it and save the new Last-Modified date
    curl -s -o "$FILE" "$URL"
    NEW_DATE=$(echo "$RESPONSE_HEADERS" | grep -i "last-modified:" | cut -d' ' -f2- | tr -d '\r')
    echo "$NEW_DATE" > "$MOD_DATE_FILE"
    
    echo "STATUS: New version downloaded!"
    echo "FILE UPDATED ON: $NEW_DATE"

elif [ "$STATUS" -eq 304 ]; then
    # No change: Read the saved date
    SAVED_DATE=$(cat "$MOD_DATE_FILE" 2>/dev/null || echo "Unknown")
    
    echo "STATUS: No update needed (Cached)"
    echo "LAST KNOWN UPDATE: $SAVED_DATE"

else
    echo "STATUS: Error (HTTP $STATUS)"
    exit 1
fi
echo "------------------------------------------"
