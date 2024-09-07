#!/bin/bash

# Exit script if a command errors
set -e

# Get the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Fetch credentials
mysql_user='root'
mysql_pass=$(yq -r -e .services.pr2-mysql.environment.MYSQL_ROOT_PASSWORD $SCRIPT_DIR/pr2.secrets.yaml)
backup_path="/backups/pr2-mysql-backups"

# Ask which version to restore
echo "Available backups: $(ls $backup_path)"
read -p 'Backup file: ' backup_file

# Restore backup
docker exec -i pr2-db-1 sh -c "exec mysql -u$mysql_user -p\"$mysql_pass\"" < "$backup_path/$backup_file"