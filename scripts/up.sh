#!/bin/bash

# Exit script if a command errors or undefined variable is encountered
set -e
set -u

# Inputs
project_dir=$1

# Computed
project_name=$(basename "$project_dir")

# Go to the directory containing the project
cd "$project_dir"

# Run render script if it exists
if test -f render.sh; then
  ./render.sh
else
  cp $project_name.yaml $project_name.rendered.yaml
fi

# Create secrets file if it does not exist
if ! test -f $project_name.secrets.yaml; then
  touch $project_name.secrets.yaml
fi

# Start project
docker compose \
  -f $project_name.rendered.yaml \
  -f $project_name.secrets.yaml \
  --project-name $project_name \
  up \
  -d \
  --remove-orphans