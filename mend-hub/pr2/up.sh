#!/bin/bash

# Get the directory where the script is located
cd $(dirname "${BASH_SOURCE[0]}")

# Run services
docker compose \
  -f pr2.yaml \
  -f pr2.secrets.yaml \
  --project-name pr2 \
  up \
  -d \
  --remove-orphans