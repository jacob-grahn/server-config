#!/bin/bash

# Exit script if a command errors
set -e

# Go to the script directory
cd "$(dirname "$0")"

# Fetch any changes from remote repo
git pull

# Run services
./up.sh pr2
./up.sh monitoring
./up.sh pr4
./up.sh pr4-dev
./up.sh caddy
