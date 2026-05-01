#!/usr/bin/env bash

# Configuration
SOURCE_NAME="Official AWS Pricing Index"
URL="https://raw.githubusercontent.com/boto/botocore/develop/botocore/data/endpoints.json"
FILE="input/aws_region_data.json"
ETAG_FILE="generators/aws_region_data.etag"
MOD_DATE_FILE="generators/aws_region_data.last_mod"

RESPONSE_HEADERS=$(curl -s -I \
    --etag-compare "$ETAG_FILE" \
    --etag-save "$ETAG_FILE" \
    "$URL")

STATUS=$(echo "$RESPONSE_HEADERS" | grep HTTP | tail -1 | awk '{print $2}')

echo "------------------------------------------"
echo "SOURCE: $SOURCE_NAME"

if [ "$STATUS" -eq 200 ]; then
    curl -s -o "$FILE" "$URL"
    NEW_DATE=$(echo "$RESPONSE_HEADERS" | grep -i "last-modified:" | cut -d' ' -f2- | tr -d '\r')
    echo "$NEW_DATE" > "$MOD_DATE_FILE"
    echo "STATUS: New version downloaded!"
elif [ "$STATUS" -eq 304 ]; then
    SAVED_DATE=$(cat "$MOD_DATE_FILE" 2>/dev/null || echo "Unknown")
    echo "STATUS: No update needed (Cached)"
    echo "LAST UPDATED: $SAVED_DATE"
else
    echo "STATUS: Error (HTTP $STATUS)"
    exit 1
fi
echo "------------------------------------------"
