#!/bin/bash

# Get the directory where the script is located
cd $(dirname "${BASH_SOURCE[0]}")

# Run services
docker compose \
  -f monitoring.yaml \
  --project-name monitoring \
  up \
  -d \
  --remove-orphans
