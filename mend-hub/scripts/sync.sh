#!/bin/bash

# Exit script if a command errors
set -e

# Get the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd $SCRIPT_DIR/..

# Fetch any changes from remote repo
git pull

# Run services
./up.sh pr2
./up.sh monitoring
./up.sh pr4
./up.sh pr4-dev
