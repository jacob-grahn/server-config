#!/bin/bash

set -e # Exit script if a command errors

# Get the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd $SCRIPT_DIR/..

# Fetch any changes from remote repo
git pull

# Run services
docker compose \
  -f pr2/pr2.yaml \
  -f pr2/pr2.secrets.yaml \
  --project-name pr2 \
  up \
  -d \
  --remove-orphans
