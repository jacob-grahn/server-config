#!/bin/bash

# Exit script if a command errors
set -e

# Get the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Fetch credentials
mysql_user='root'
mysql_pass=$(yq -r -e .services.db.environment.MYSQL_ROOT_PASSWORD $SCRIPT_DIR/pr2.secrets.yaml)
backup_path="/backups/pr2-db-backups"
backup_file=$(date '+%Y-%m-%d').sql
retention_days='30'

# Create backup
docker exec pr2-db-1 sh -c "exec mysqldump --all-databases -u$mysql_user -p\"$mysql_pass\"" > "$backup_path/$backup_file"

# Delete backups older than 30 days
find $backup_path -type f -mtime +"$retention_days" -exec rm -f {} \;