#!/bin/bash

# Exit script if a command errors
set -e

# Get the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Fetch credentials
mysql_user='root'
mysql_pass=$(yq $SCRIPT_DIR/pr2.secrets.yaml services.db.envireonment.MYSQL_ROOT_PASSWORD)

# Restore backup
docker exec -i pr2-db sh -c "exec mysql -u '$mysql_user' -p '$mysql_pass'" < /backups/pr2-db/latest.sql