#!/bin/bash
# Import a Keycloak realm using the Keycloak 26.3.1 container

# Usage: ./import-realm.sh <import-file>
# Example: ./import-realm.sh /home/shahadat/Keycloak-Docker/keycloak-realm-tools/myrealm-export.json

set -e

IMPORT_FILE="$1"

if [ -z "$IMPORT_FILE" ]; then
  echo "Usage: $0 <import-file>"
  exit 1
fi

BASENAME=$(basename "$IMPORT_FILE")
docker compose cp "$IMPORT_FILE" keycloak:/tmp/"$BASENAME"

docker compose exec keycloak \
  /opt/keycloak/bin/kc.sh import \
  --file "/tmp/$BASENAME"

echo "Realm imported from $IMPORT_FILE"