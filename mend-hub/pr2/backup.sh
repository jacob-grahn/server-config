#!/bin/bash

# Exit script if a command errors
set -e

# Get the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Fetch credentials
mysql_user='root'
mysql_pass=$(yq -e .services.db.envireonment.MYSQL_ROOT_PASSWORD $SCRIPT_DIR/pr2.secrets.yaml)
backup_path="/backups/pr2-db"
backup_file=$(printf -v date '%(%Y-%m-%d)T\n' -1).sql
retention_days='30'

# Create backup
docker exec pr2-db-1 sh -c "exec mysqldump --all-databases -u '$mysql_user' -p '$mysql_password'" > "$backup_path/$backup_file"

# Delete backups older than 30 days
find $backup_path -type f -mtime +"$retention_days" -exec rm -f {} \;