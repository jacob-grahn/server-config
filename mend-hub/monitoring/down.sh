#!/bin/bash

# Go to the directory where the script is located
cd "$(dirname "$0")"

# Stop services
docker compose --project-name monitoring down
