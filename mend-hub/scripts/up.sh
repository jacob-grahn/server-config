#!/bin/bash

# Exit script if a command errors or undefined variable is encountered
set -e
set -u

# Inputs
project=$1

# Go to the directory containing the project
cd "$(dirname "$0")/../$project"

# Run render script if it exists
if test -f render.sh; then
  ./render.sh
else
  cp $project.yaml $project.rendered.yaml
fi

# Create secrets file if it does not exist
if ! test -f $project.secrets.yaml; then
  touch $project.secrets.yaml
fi

# Start project
docker compose \
  -f $project.rendered.yaml \
  -f $project.secrets.yaml \
  --project-name $project \
  up \
  -d \
  --remove-orphans