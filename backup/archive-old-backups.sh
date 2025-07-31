#!/bin/bash

# Directory containing backups
BACKUP_DIR="$HOME/Keycloak-Docker/backup"
cd "$BACKUP_DIR" || exit 1

# Keep the N most recent backups (adjust as needed)
KEEP=5

# List backup files sorted by date, exclude README.md and logs
FILES_TO_ARCHIVE=$(ls -1tr keycloak_backup_*.sql | head -n -"$KEEP")

# Exit if nothing to archive
if [ -z "$FILES_TO_ARCHIVE" ]; then
  echo "Nothing to archive."
  exit 0
fi

# Archive name (e.g., old_backups_July_2025.zip)
ARCHIVE_NAME="old_backups_$(date '+%B_%Y').zip"

# Add to ZIP archive
zip -m "$ARCHIVE_NAME" $FILES_TO_ARCHIVE

# Log it
{
  echo "Archived on $(date '+%Y-%m-%d %H:%M:%S'):"
  echo "$FILES_TO_ARCHIVE"
  echo ""
} >> archive.log

