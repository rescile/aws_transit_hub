#!/usr/bin/env bash
set -euo pipefail

# Configuration
DATA_SOURCE="https://raw.githubusercontent.com/boto/botocore/develop/botocore/data/endpoints.json"
OUTPUT_FILE=${OUTPUT_FILE:-"../input/aws.json"}

# Temporary file for storing our intermediate filtered tags
TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

echo "Retrieve aws region endpoints from github..."

# Fetch the current page quietly
RESPONSE=$(curl -s "$DATA_SOURCE")

# Extract tags matching "vX.Y.Z" exactly using jq's regex test, and append to temp file
echo "$RESPONSE" | jq -r '.partitions[0].services | to_entries |
    map({service: .key, region: (.value.endpoints | keys[])}) |
    reduce .[] as $item ({};
        ($item.region | [match("[a-z]{2}-[a-z]+-[0-9]") | .string][0] // $item.region) as $clean_region |
        .[$clean_region] += [$item.service]
    ) |
    map_values(unique | sort)
' >> "$OUTPUT_FILE"

echo "Success! Data written to $OUTPUT_FILE"
