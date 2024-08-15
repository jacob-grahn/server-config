#!/bin/bash

# Go to the directory where the script is located
cd "$(dirname "$0")"

# Stop pr4
docker compose --project-name pr4-dev down
