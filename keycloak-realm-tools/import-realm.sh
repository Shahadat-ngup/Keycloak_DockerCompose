#!/bin/bash
# Import a Keycloak realm from a directory using Keycloak 26.3.1

# Usage: ./import-realm.sh <import-dir> [override]
# Example: ./import-realm.sh ./myrealm-export true

set -e

IMPORT_DIR="$1"
OVERRIDE="${2:-true}"  # true (default) or false

if [ -z "$IMPORT_DIR" ]; then
  echo "Usage: $0 <import-dir> [override]"
  echo "override: true | false (default: true)"
  exit 1
fi

# Load DB env vars from .env
set -a
. ../.env
set +a

echo "Stopping Keycloak container..."
docker compose stop keycloak

IMPORT_DIR_ABS="$(realpath "$IMPORT_DIR")"

echo "Importing realm(s) from directory '$IMPORT_DIR_ABS' with override=$OVERRIDE..."
docker compose run --rm \
  -e KC_DB=mysql \
  -e KC_DB_URL="jdbc:mysql://mysql:3306/${MYSQL_DATABASE}" \
  -e KC_DB_USERNAME="${MYSQL_USER}" \
  -e KC_DB_PASSWORD="${MYSQL_PASSWORD}" \
  -v "$IMPORT_DIR_ABS":/tmp/realm-import \
  --entrypoint /opt/keycloak/bin/kc.sh keycloak import \
    --dir /tmp/realm-import \
    --override "$OVERRIDE"

echo "Restarting Keycloak container..."
docker compose start keycloak

echo "Realm(s) imported from $IMPORT_DIR_ABS"