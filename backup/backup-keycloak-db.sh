#!/bin/bash
# Automated MySQL backup for Keycloak (Docker Compose)
# Usage: ./backup-keycloak-db.sh

# Load environment variables from .env (use absolute path for cron)
set -a
. /home/shahadat/Keycloak-Docker/.env
set +a

# Set backup directory and filename
backup_dir="/home/shahadat/Keycloak-Docker/backup"
date_str=$(date +%F_%H-%M-%S)
backup_file="$backup_dir/keycloak_backup_$date_str.sql"

# Run mysqldump inside the mysql container (no sudo, for cron)
docker compose exec mysql mysqldump -u$MYSQL_USER -p"$MYSQL_PASSWORD" $MYSQL_DATABASE > "$backup_file"

if [ $? -eq 0 ]; then
    echo "Backup successful: $backup_file"
else
    echo "Backup failed!"
    exit 1
fi
