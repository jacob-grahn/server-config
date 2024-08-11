#!/bin/bash

# Exit script if a command errors
set -e

# Get the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Fetch credentials
mysql_user='root'
mysql_pass=$(yq -e .services.db.envireonment.MYSQL_ROOT_PASSWORD $SCRIPT_DIR/pr2.secrets.yaml)

# Restore backup
docker exec -i pr2-db-1 sh -c "exec mysql -u '$mysql_user' -p '$mysql_pass'" < /backups/pr2-db/latest.sql