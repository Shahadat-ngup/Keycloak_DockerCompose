#!/bin/bash
# Export a Keycloak realm to a directory using Keycloak 26.3.1

# Usage: ./export-realm.sh <realm-name> [export-dir] [users-strategy]
# Example: ./export-realm.sh myrealm ./myrealm-export realm_file

set -e

REALM_NAME="$1"
EXPORT_DIR="${2:-/home/shahadat/Keycloak-Docker/keycloak-realm-tools/${REALM_NAME}-export}"
USERS_STRATEGY="${3:-realm_file}"  # Options: different_files, skip, realm_file, same_file

if [ -z "$REALM_NAME" ]; then
  echo "Usage: $0 <realm-name> [export-dir] [users-strategy]"
  echo "users-strategy: different_files | skip | realm_file | same_file (default: realm_file)"
  exit 1
fi

# Load DB env vars from .env
set -a
. ../.env
set +a

echo "Stopping Keycloak container..."
docker compose stop keycloak

# Use a Docker volume to persist export files
EXPORT_DIR_ABS="$(realpath "$EXPORT_DIR")"
mkdir -p "$EXPORT_DIR_ABS"

echo "Exporting realm '$REALM_NAME' to directory '$EXPORT_DIR_ABS' with users strategy '$USERS_STRATEGY'..."
docker compose run --rm \
  -e KC_DB=mysql \
  -e KC_DB_URL="jdbc:mysql://mysql:3306/${MYSQL_DATABASE}" \
  -e KC_DB_USERNAME="${MYSQL_USER}" \
  -e KC_DB_PASSWORD="${MYSQL_PASSWORD}" \
  -v "$EXPORT_DIR_ABS":/tmp/realm-export \
  --entrypoint /opt/keycloak/bin/kc.sh keycloak export \
    --dir /tmp/realm-export \
    --realm "$REALM_NAME" \
    --users "$USERS_STRATEGY"

echo "Restarting Keycloak container..."
docker compose start keycloak

echo "Realm '$REALM_NAME' exported to $EXPORT_DIR_ABS"