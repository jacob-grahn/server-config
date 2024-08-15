#!/bin/bash

# Example usage:
# ./fetch-ghcr-tag.sh 'ghcr.io/jacob-grahn/platform-racing-4-client-web' '.*-main-.*'

# Exit script if a command errors
set -e

# Accept image path and pattern as inputs
image_path="$1"
pattern="$2"

# Extract the registry and repository from the image path
registry="${image_path%%/*}"
repo="${image_path#*/}"

# Fetch a token
token=$(curl --fail -s https://ghcr.io/token\?scope\="repository:$registry/$repo:pull" | jq '.token' -r)

# Fetch list of tags
tags_response=$(curl --fail -s -H "Authorization: Bearer $token" "https://${registry}/v2/${repo}/tags/list")

# Filter tags by pattern and sort
tags=$(echo "$tags_response" | jq -r ".tags[] | select(test(\"$pattern\"))" | sort -r)

# Alphabetically, the top tag is the newest (this only works because we are tagging with the date)
newest_tag=$(echo $tags | cut -d " " -f 1)

# Output the result
echo $newest_tag