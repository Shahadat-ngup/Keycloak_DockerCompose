#!/bin/bash
# Export a Keycloak realm using the Keycloak 26.3.1 container

# Usage: ./export-realm.sh <realm-name> [output-file]
# Example: ./export-realm.sh myrealm /home/shahadat/Keycloak-Docker/keycloak-realm-tools/myrealm-export.json

set -e

REALM_NAME="$1"
EXPORT_FILE="${2:-/home/shahadat/Keycloak-Docker/keycloak-realm-tools/${REALM_NAME}-export.json}"

if [ -z "$REALM_NAME" ]; then
  echo "Usage: $0 <realm-name> [output-file]"
  exit 1
fi

docker compose exec keycloak \
  /opt/keycloak/bin/kc.sh export \
  --realm "$REALM_NAME" \
  --file "/tmp/realm-export.json" \
  --users realm_file

docker compose cp keycloak:/tmp/realm-export.json "$EXPORT_FILE"

echo "Realm '$REALM_NAME' exported to $EXPORT_FILE"