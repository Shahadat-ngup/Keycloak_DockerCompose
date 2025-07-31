# Keycloak Realm Export/Import Tools

This folder contains scripts to **export** and **import** Keycloak realms using the Keycloak 26.3.1 Docker container.

## Usage

### Export a Realm

```bash
./export-realm.sh <realm-name> [output-file]
```
- `<realm-name>`: Name of the realm to export (required)
- `[output-file]`: Path to save the exported JSON (optional, defaults to `<realm-name>-export.json` in this folder)

**Example:**
```bash
./export-realm.sh myrealm
```

### Import a Realm

```bash
./import-realm.sh <import-file>
```
- `<import-file>`: Path to the exported realm JSON file

**Example:**
```bash
./import-realm.sh myrealm-export.json
```

## Notes

- These scripts use `docker compose exec` and `docker compose cp` to interact with the running Keycloak container.
- Make sure your Keycloak container is running and accessible via Docker Compose.
- The scripts assume the service name is `keycloak` (as in your `docker-compose.yml`).

For more details,