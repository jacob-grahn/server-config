#!/bin/bash

# Exit script if a command errors
set -e

# Get the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Fetch password
mysql_pass=$(yq -r -e '.services."pr2-mysql".environment.MYSQL_ROOT_PASSWORD' $SCRIPT_DIR/pr2.secrets.yaml)

# Connect to mysql
docker run -it --network pr2-backend --rm -e MYSQL_PWD=$mysql_pass mysql mysql -h pr2-mysql -u root