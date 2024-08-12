#!/bin/bash

set -e # Exit script if a command errors

# Get the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd $SCRIPT_DIR/..

# Run services
docker compose \
  -f monitoring.yaml \
  --project-name monitoring \
  up \
  -d \
  --remove-orphans
