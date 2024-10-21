#!/bin/bash

# Exit script if a command errors
set -e

# Go to the script directory
cd "$(dirname "$0")"

# Fetch any changes from remote repo
git pull

# Run services
server_dir=$1
for subdir in "$server_dir"/*/; do
    ./up.sh "$subdir"
done
